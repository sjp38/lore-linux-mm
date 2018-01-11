Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3293E6B0271
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 13:11:55 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id g81so2391139ioa.14
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 10:11:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s23sor10281007ioe.21.2018.01.11.10.11.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 10:11:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
References: <201801091939.JDJ64598.HOMFQtOFSOVLFJ@I-love.SAKURA.ne.jp>
 <201801102049.BGJ13564.OOOMtJLSFQFVHF@I-love.SAKURA.ne.jp>
 <20180110124519.GU1732@dhcp22.suse.cz> <201801102237.BED34322.QOOJMFFFHVLSOt@I-love.SAKURA.ne.jp>
 <20180111135721.GC1732@dhcp22.suse.cz> <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 11 Jan 2018 10:11:52 -0800
Message-ID: <CA+55aFwj+x42UtTg4AEbgdW2p6TaZRPjT+BpN1qDrrBh1G8aRA@mail.gmail.com>
Subject: Re: [mm? 4.15-rc7] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Jan 11, 2018 at 6:11 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> I retested with some debug printk() patch.

Could you perhaps enable KASAN too?

> [   38.988178] Out of memory: Kill process 354 (b.out) score 7 or sacrifice child
> [   38.991145] Killed process 354 (b.out) total-vm:2099260kB, anon-rss:23288kB, file-rss:8kB, shmem-rss:0kB
> [   38.996277] oom_reaper: started reaping
> [   38.999033] BUG: unable to handle kernel paging request at c130d86d
> [   39.001802] IP: _raw_spin_lock_irqsave+0x1c/0x40

The "Code:" line shows the whole function in this case:

   0:   55                      push   %ebp
   1:   89 c1                   mov    %eax,%ecx
   3:   89 e5                   mov    %esp,%ebp
   5:   56                      push   %esi
   6:   53                      push   %ebx
   7:   9c                      pushf
   8:   58                      pop    %eax
   9:   66 66 66 90             nop
   d:   89 c6                   mov    %eax,%esi
   f:   fa                      cli
  10:   66 66 90                nop
  13:   66 90                   nop
  15:   31 c0                   xor    %eax,%eax
  17:   bb 01 00 00 00          mov    $0x1,%ebx
  1c:   3e 0f b1 19             cmpxchg %ebx,%ds:*(%ecx)
 <-- trapping instruction
  20:   85 c0                   test   %eax,%eax
  22:   75 06                   jne    0x2a
  24:   89 f0                   mov    %esi,%eax
  26:   5b                      pop    %ebx
  27:   5e                      pop    %esi
  28:   5d                      pop    %ebp
  29:   c3                      ret

although it isn't all that interesting since it's just
"_raw_spin_lock_irqsave". The odd "nop" instructions are because of
paravirtualization support leaving room for rewriting the eflags
operations.

Anyway, %ecx is garbage - it *should* be "&memcg->move_lock",
apparently. The caller does:

  again:
        memcg = page->mem_cgroup;
        if (unlikely(!memcg))
                return NULL;

        if (atomic_read(&memcg->moving_account) <= 0)
                return memcg;

        spin_lock_irqsave(&memcg->move_lock, flags);
        if (memcg != page->mem_cgroup) {
                spin_unlock_irqrestore(&memcg->move_lock, flags);
                goto again;
        }

What's a bit odd is how the access to "memcg->move_lock" seems to
trap, but we did that atomic_read() from memcg->moving_account ok.

The reason seems to be that this is actually a valid kernel pointer,
but it's read-protected:

> [   39.004069] *pde = 01f88063 *pte = 0130d161
> [   39.006250] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC

That "0003" means that it was a protection fault on a write. The
"*pte" thing agrees. It's the normal 1:1 mapping of the physical page
0130d000 (which matches the virtual address c130d86d), but it's
presumably a kernel code pointer and this RO.

So presumably "page->mem_cgroup" was just a random pointer. Which
probably means that "page" itself is not actually a page pointer, sinc
eI assume there was no memory hotplug going on here?

> [   39.022885] EIP: _raw_spin_lock_irqsave+0x1c/0x40
> [   39.037889] Call Trace:
> [   39.043562]  lock_page_memcg+0x25/0x80
> [   39.045421]  page_remove_rmap+0x87/0x2e0
> [   39.047315]  try_to_unmap_one+0x20e/0x590
> [   39.049198]  rmap_walk_file+0x13c/0x250
> [   39.051012]  rmap_walk+0x32/0x60
> [   39.052619]  try_to_unmap+0x4d/0x100
> [   39.059849]  shrink_page_list+0x3a2/0x1000
> [   39.061678]  shrink_inactive_list+0x1b2/0x440
> [   39.063539]  shrink_node_memcg+0x34a/0x770
> [   39.065297]  shrink_node+0xbb/0x2e0
> [   39.066920]  do_try_to_free_pages+0xba/0x320
> [   39.068752]  try_to_free_pages+0x11d/0x330
> [   39.072084]  __alloc_pages_slowpath+0x303/0x6d9
> [   39.075932]  __alloc_pages_nodemask+0x16d/0x180
> [   39.077809]  do_anonymous_page+0xab/0x4f0
> [   39.079551]  handle_mm_fault+0x531/0x8d0
> [   39.084422]  __do_page_fault+0x1ea/0x4d0
> [   39.087666]  do_page_fault+0x1a/0x20
> [   39.089184]  common_exception+0x6f/0x76

Looks like the page pointer came from shrink_inactive_list() doing
isolate_lru_pages().

Scary. It all seems to just mean that the page LRU queues are corrupted.

Most (all?) of your other oopses seem to have somewhat similar
patterns: shrink_inactive_list() -> rmap_walk_file() -> oops due to
garbage.

> Overall, memory corruption is strongly suspected.

Yeah, this very much looks like some internal VM memory corruption.

Which is why I'm wondering if enabling KASAN might help find the
actual access that causes the corruption. Or at least an _earlier_
access that is closer to it than these that all seem to be fairly far
removed from where it actually all started..

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

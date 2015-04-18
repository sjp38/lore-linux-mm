Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7E86B0032
	for <linux-mm@kvack.org>; Sat, 18 Apr 2015 18:16:35 -0400 (EDT)
Received: by wiun10 with SMTP id n10so54346850wiu.1
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 15:16:35 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id ud6si25134563wjc.214.2015.04.18.15.16.33
        for <linux-mm@kvack.org>;
        Sat, 18 Apr 2015 15:16:34 -0700 (PDT)
Date: Sun, 19 Apr 2015 00:16:31 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150418221631.GC7972@pd.tnic>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <20150418220803.GB7972@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150418220803.GB7972@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, lkml <linux-kernel@vger.kernel.org>

Forgot to CC lkml for archiving purposes, here's the whole thread in
one:

---
Hi guys,

so I'm running some intermediate state of linus/master + tip/master from
Thursday and probably I shouldn't be even taking such splat seriously
and wait until 4.1-rc1 has been done but let me report it just in case
so that it is out there, in case someone else sees it too.

I don't have a reproducer yet except the fact that it happened twice
already, the second time while watching the new Star Wars teaser on
youtube (current->comm is "AudioThread" probably from chrome, as shown
in the splat below).

And srsly, to VM_BUG_ON_PAGE() while I'm watching the new Star Wars
teaser - you must be kidding me people!

Anyway, just FYI, someone might have an idea...

So here's the state of what I was running:

---
commit 3963e69e59fa4e36ac164e8cd520811135d868d3
Merge: 34c9a0ffc75a 11664e41b11e
Author: Borislav Petkov <bp@suse.de>
Date:   Thu Apr 16 13:39:44 2015 +0200

    Merge remote-tracking branch 'tip/master' into rc0+

commit 11664e41b11ed447f598424dd83ecf65400be5a1 (refs/remotes/tip/master)
Merge: 61a7fd4deb61 2df8406a439b
Author: Ingo Molnar <mingo@kernel.org>
Date:   Thu Apr 16 09:20:52 2015 +0200

    Merge branch 'sched/urgent'

commit eea3a00264cf243a28e4331566ce67b86059339d
Merge: e7c82412433a e693d73c20ff
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed Apr 15 16:39:15 2015 -0700

    Merge branch 'akpm' (patches from Andrew)

    Merge second patchbomb from Andrew Morton:

---

and here's the splat:

---

[115258.861335] page:ffffea0010a15040 count:0 mapcount:1 mapping:          (null) index:0x0
[115258.869511] flags: 0x8000000000008014(referenced|dirty|tail)
[115258.874159] page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
[115258.874177] ------------[ cut here ]------------
[115258.874179] kernel BUG at mm/swap.c:134!
[115258.874182] invalid opcode: 0000 [#1] 
[115258.874183] PREEMPT 
[115258.874184] SMP 

[115258.874187] Modules linked in:
[115258.874189]  nls_iso8859_15
[115258.874190]  nls_cp437
[115258.874192]  ipt_MASQUERADE
[115258.874193]  nf_nat_masquerade_ipv4
[115258.874194]  iptable_mangle
[115258.874195]  iptable_nat
[115258.874196]  nf_conntrack_ipv4
[115258.874198]  nf_defrag_ipv4
[115258.874199]  nf_nat_ipv4
[115258.874200]  nf_nat
[115258.874201]  nf_conntrack
[115258.874202]  iptable_filter
[115258.874204]  ip_tables
[115258.874205]  x_tables
[115258.874206]  tun
[115258.874207]  sha256_ssse3
[115258.874209]  sha256_generic
[115258.874211]  binfmt_misc
[115258.874212]  ipv6
[115258.874213]  vfat
[115258.874214]  fat
[115258.874215]  fuse
[115258.874216]  dm_crypt
[115258.874217]  dm_mod
[115258.874219]  kvm_amd
[115258.874243]  kvm crc32_pclmul aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd amd64_edac_mod edac_core fam15h_power k10temp amdkfd amd_iommu_v2 radeon drm_kms_helper ttm cfbfillrect cfbimgblt cfbcopyarea acpi_cpufreq
[115258.874248] CPU: 0 PID: 2904 Comm: AudioThread Not tainted 4.0.0+ #1
[115258.874250] Hardware name: To be filled by O.E.M. To be filled by O.E.M./M5A97 EVO R2.0, BIOS 1503 01/16/2013
[115258.874252] task: ffff8803e8278000 ti: ffff8803f8a04000 task.ti: ffff8803f8a04000
[115258.874262] RIP: 0010:[<ffffffff8113fcb9>]  [<ffffffff8113fcb9>] put_compound_page+0x3b9/0x480
[115258.874264] RSP: 0018:ffff8803f8a07b98  EFLAGS: 00010246
[115258.874266] RAX: 000000000000003d RBX: ffffea0010a15040 RCX: 0000000000000000
[115258.874268] RDX: ffffffff8109f016 RSI: ffffffff810bb33f RDI: ffffffff810bae60
[115258.874270] RBP: ffff8803f8a07bb8 R08: 0000000000000001 R09: 0000000000000001
[115258.874271] R10: 0000000000000001 R11: 0000000000000001 R12: ffffea0010a15000
[115258.874273] R13: ffff8803f8a07e28 R14: ffffea0010a15040 R15: 0000000000000000
[115258.874276] FS:  00007f206f2af700(0000) GS:ffff88042c600000(0000) knlGS:0000000000000000
[115258.874278] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[115258.874280] CR2: 00007f2095443310 CR3: 000000041e866000 CR4: 00000000000406f0
[115258.874281] Stack:
[115258.874287]  ffff8803f8a07e60 ffffea0010a151c0 ffff8803f8a07e28 ffffea0010a15040
[115258.874292]  ffff8803f8a07c28 ffffffff8113ffd0 0000000100000000 00000000ffffffff
[115258.874296]  ffff8803f8a07de8 ffff8803f8a07e60 ffff8803f8a07be8 ffff8803f8a07be8
[115258.874298] Call Trace:
[115258.874304]  [<ffffffff8113ffd0>] release_pages+0x250/0x270
[115258.874311]  [<ffffffff811736c5>] free_pages_and_swap_cache+0x95/0xb0
[115258.874317]  [<ffffffff8115ddc0>] tlb_flush_mmu_free+0x40/0x60
[115258.874323]  [<ffffffff8115fcac>] unmap_single_vma+0x69c/0x730
[115258.874331]  [<ffffffff81160594>] unmap_vmas+0x54/0xb0
[115258.874335]  [<ffffffff81165a38>] unmap_region+0xa8/0x110
[115258.874342]  [<ffffffff811679ea>] do_munmap+0x1ea/0x3f0
[115258.874346]  [<ffffffff81167c33>] ? vm_munmap+0x43/0x80
[115258.874350]  [<ffffffff81167c41>] vm_munmap+0x51/0x80
[115258.874354]  [<ffffffff81168bee>] SyS_munmap+0xe/0x20
[115258.874359]  [<ffffffff816918db>] system_call_fastpath+0x16/0x73
[115258.874424] Code: 81 48 89 df e8 29 c9 01 00 0f 0b 48 c7 c6 00 81 8a 81 4c 89 e7 e8 18 c9 01 00 0f 0b 48 c7 c6 d8 96 8b 81 48 89 df e8 07 c9 01 00 <0f> 0b 48 c7 c6 30 97 8b 81 48 89 df e8 f6 c8 01 00 0f 0b 48 c7 
[115258.874428] RIP  [<ffffffff8113fcb9>] put_compound_page+0x3b9/0x480
[115258.874429]  RSP <ffff8803f8a07b98>
[115258.898487] ---[ end trace 6ec080e8a6ee9fb1 ]---

Thanks!

-- 
On Sat, Apr 18, 2015 at 4:56 PM, Borislav Petkov <bp@alien8.de> wrote:
>
> so I'm running some intermediate state of linus/master + tip/master from
> Thursday and probably I shouldn't be even taking such splat seriously
> and wait until 4.1-rc1 has been done but let me report it just in case
> so that it is out there, in case someone else sees it too.
>
> I don't have a reproducer yet except the fact that it happened twice
> already, the second time while watching the new Star Wars teaser on
> youtube (current->comm is "AudioThread" probably from chrome, as shown
> in the splat below).

Hmm. The only recent commit in this area seems to be 822fc61367f0
("mm: don't call __page_cache_release for hugetlb") although I don't
see why it would cause anything like that. But it changes code that
has been stable for many years, which makes me wonder how valid it is
(__put_compound_page() has been unchanged since 2011, and now suddenly
it grew that "!PageHuge()" test).

So quite frankly, I'd almost suggest changing that

        if (!PageHuge(page))
                __page_cache_release(page);

back to the old unconditional __page_cache_release(page), and maybe add a single

        WARN_ON_ONCE(PageHuge(page));

just to see if that condition actually happens. The new comment says
it shouldn't happen and that the change shouldn't matter, but...

Of course, your recent BUG_ON may well be entirely unrelated to this
change in mm/swap.c, but it *is* in kind of the same area, and the
timing would match too...

             Linus

---
[115258.861335] page:ffffea0010a15040 count:0 mapcount:1 mapping:
    (null) index:0x0
[115258.869511] flags: 0x8000000000008014(referenced|dirty|tail)
[115258.874159] page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
[115258.874179] kernel BUG at mm/swap.c:134!
[115258.874262] RIP: put_compound_page+0x3b9/0x480


---
On Sat, Apr 18, 2015 at 05:27:49PM -0400, Linus Torvalds wrote:
> On Sat, Apr 18, 2015 at 4:56 PM, Borislav Petkov <bp@alien8.de> wrote:
> >
> > so I'm running some intermediate state of linus/master + tip/master from
> > Thursday and probably I shouldn't be even taking such splat seriously
> > and wait until 4.1-rc1 has been done but let me report it just in case
> > so that it is out there, in case someone else sees it too.
> >
> > I don't have a reproducer yet except the fact that it happened twice
> > already, the second time while watching the new Star Wars teaser on
> > youtube (current->comm is "AudioThread" probably from chrome, as shown
> > in the splat below).

I would guess it's related to sound: the most common source of PTE-mapeed
compund pages into userspace.

> Hmm. The only recent commit in this area seems to be 822fc61367f0
> ("mm: don't call __page_cache_release for hugetlb") although I don't
> see why it would cause anything like that. But it changes code that
> has been stable for many years, which makes me wonder how valid it is
> (__put_compound_page() has been unchanged since 2011, and now suddenly
> it grew that "!PageHuge()" test).
> 
> So quite frankly, I'd almost suggest changing that
> 
>         if (!PageHuge(page))
>                 __page_cache_release(page);
> 
> back to the old unconditional __page_cache_release(page), and maybe add a single
> 
>         WARN_ON_ONCE(PageHuge(page));
> 
> just to see if that condition actually happens. The new comment says
> it shouldn't happen and that the change shouldn't matter, but...
> 
> Of course, your recent BUG_ON may well be entirely unrelated to this
> change in mm/swap.c, but it *is* in kind of the same area, and the
> timing would match too...

Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
cause. I don't see why the commit could broke anything, but it worth
trying to revert and test.

Borislav, could you try?


> ---
> [115258.861335] page:ffffea0010a15040 count:0 mapcount:1 mapping:
>     (null) index:0x0
> [115258.869511] flags: 0x8000000000008014(referenced|dirty|tail)
> [115258.874159] page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
> [115258.874179] kernel BUG at mm/swap.c:134!
> [115258.874262] RIP: put_compound_page+0x3b9/0x480
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

---
On Sat, Apr 18, 2015 at 5:56 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
> cause. I don't see why the commit could broke anything, but it worth
> trying to revert and test.

Ahh, yes, that does look like a more likely culprit.

         Linus


---

On Sat, Apr 18, 2015 at 05:59:53PM -0400, Linus Torvalds wrote:
> On Sat, Apr 18, 2015 at 5:56 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> >
> > Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
> > cause. I don't see why the commit could broke anything, but it worth
> > trying to revert and test.
> 
> Ahh, yes, that does look like a more likely culprit.

Reverted and building... will report in the next days.

Thanks guys.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

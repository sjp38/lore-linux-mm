Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D60046B004D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 23:55:22 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb30so6806642vcb.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 20:55:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50B4145C.3010406@gmail.com>
References: <1352721091-27022-1-git-send-email-walken@google.com>
	<50A16212.8090507@gmail.com>
	<50B4145C.3010406@gmail.com>
Date: Mon, 26 Nov 2012 20:55:21 -0800
Message-ID: <CANN689H4e6dPBtA645ergWM_9HOS1jCWDaZcM3QHpAWDZGAZ2g@mail.gmail.com>
Subject: Re: [PATCH 0/3] fix missing rb_subtree_gap updates on vma insert/erase
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 26, 2012 at 5:16 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> I've built today's -next, and got the following BUG pretty quickly (2-3 hours):
>
> [ 1556.479284] BUG: unable to handle kernel paging request at 0000000000412000
> [ 1556.480036] IP: [<ffffffff81238184>] validate_mm+0x34/0x130
> [ 1556.480036] PGD 31739067 PUD 4fbc4067 PMD 1c936067 PTE 0
> [ 1556.480036] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1556.480036] Dumping ftrace buffer:
> [ 1556.480036]    (ftrace buffer empty)
> [ 1556.480036] CPU 0
> [ 1556.480036] Pid: 10274, comm: trinity-child29 Tainted: G        W    3.7.0-rc6-next-20121126-sasha-00015-gb04382b-dirty #201
> [ 1556.480036] RIP: 0010:[<ffffffff81238184>]  [<ffffffff81238184>] validate_mm+0x34/0x130
> [ 1556.480036] RSP: 0018:ffff88004fbc7d08  EFLAGS: 00010206
> [ 1556.480036] RAX: 0000000000412000 RBX: 0000000000000000 RCX: 0000000000000000
> [ 1556.512120] RDX: 0000000000000000 RSI: ffff88001c1a6008 RDI: ffff88001c1a6000
> [ 1556.512120] RBP: ffff88004fbc7d38 R08: ffff8800371e7808 R09: ffff88004fb56cf0
> [ 1556.512120] R10: 0000000000000001 R11: 0000000000001000 R12: ffff88001c1a6000
> [ 1556.512120] R13: ffff8800371e7b00 R14: 0000000000000000 R15: ffff88001c1a6000
> [ 1556.512120] FS:  00007f4e0f8e3700(0000) GS:ffff8800bfc00000(0000) knlGS:0000000000000000
> [ 1556.512120] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1556.512120] CR2: 0000000000412000 CR3: 000000002faec000 CR4: 00000000000406f0
> [ 1556.512120] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1556.512120] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1556.512120] Process trinity-child29 (pid: 10274, threadinfo ffff88004fbc6000, task ffff88004fbb0000)
> [ 1556.512120] Stack:
> [ 1556.512120]  ffff8800bf80aa80 ffff88001c1a6000 ffff88004fb56cf0 ffff8800371e7818
> [ 1556.512120]  ffff8800371e7808 ffff88001c1a6000 ffff88004fbc7d88 ffffffff8123843c
> [ 1556.512120]  0000000000000001 ffff88004fb56da8 ffff880000000000 ffff8800371e7818
> [ 1556.512120] Call Trace:
> [ 1556.512120]  [<ffffffff8123843c>] vma_link+0xcc/0xf0
> [ 1556.512120]  [<ffffffff8123a8ac>] mmap_region+0x40c/0x5a0
> [ 1556.512120]  [<ffffffff8123aceb>] do_mmap_pgoff+0x2ab/0x310
> [ 1556.512120]  [<ffffffff8122477c>] ? vm_mmap_pgoff+0x6c/0xb0
> [ 1556.512120]  [<ffffffff81224794>] vm_mmap_pgoff+0x84/0xb0
> [ 1556.512120]  [<ffffffff81239483>] sys_mmap_pgoff+0x193/0x1a0
> [ 1556.512120]  [<ffffffff81182b08>] ? trace_hardirqs_on_caller+0x118/0x140
> [ 1556.512120]  [<ffffffff810729ad>] sys_mmap+0x1d/0x20
> [ 1556.512120]  [<ffffffff83c88418>] tracesys+0xe1/0xe6
> [ 1556.512120] Code: 31 f6 41 55 41 54 49 89 fc 53 31 db 48 83 ec 08 4c 8b 2f 4d 85 ed 74 75 0f 1f 80 00 00 00 00 49 8b 85 88 00 00
> 00 48 85 c0 74 0e <48> 8b 38 31 f6 48 83 c7 08 e8 0e bc a4 02 49 8b 45 78 4d 8d 7d
> [ 1556.512120] RIP  [<ffffffff81238184>] validate_mm+0x34/0x130
> [ 1556.512120]  RSP <ffff88004fbc7d08>
> [ 1556.512120] CR2: 0000000000412000
> [ 1557.729958] ---[ end trace d2a29e98cc9e2568 ]---
>
> The bit that's failing is:
>
>         struct vm_area_struct *vma = mm->mmap; // mm->mmap = 0x412000
>         while (vma) {
>                 struct anon_vma_chain *avc;
>                 vma_lock_anon_vma(vma); // BOOM!
>
>
> Thanks,
> Sasha

Thanks for the report.

I believe we actually have mm->mmap = ffff8800371e7b00 (r13); That
first vma has its anon_vma field pointing to 0000000000412000 (rax)
and we fault while trying to read anon_vma->root.

I don't see what could cause vma->anon_vma to be an invalid non-null
value. This looks very much like there might be some kind of memory
corruption occuring, but I can't tell where it would come from.

Going back into your previous reports, we also never really identified
the root cause of your two reports at the start of the thread with
subject: "mm: NULL ptr deref in anon_vma_interval_tree_verify" (on Oct
18th and Oct 25th). At some point we thought that taking the anon_vma
lock in validate_mm would prevent a race and fix the issue, but
further inspection convinced us that this shouldn't be necessary - so,
in the end, we still don't know what caused us to crash in these two
cases either (and, I was tempted to suggest memory corruption at the
time too).

So, I'm not sure what to do.

One thing to keep in mind is that CONFIG_DEBUG_VM_RB was only recently
introduced (between v3.6 and v3.7-rc1); before that the code existed
only as an #ifdef in mm/mmap.c. So, it might help if you could run
your trinity test on these few kernel versions:

- first, on v3.6, after editing mm/mmap.c to replace #undef
DEBUG_MM_RB with #define DEBUG_MM_RB;
(if this fails here, then what we have is a latent bug that
CONFIG_DEBUG_VM_RB just happened to reveal)

- then, on v3.7-rc1 with no further changes
(if this fails here, then the issue is likely with my rbtree intervals
stuff that made it into v3.7-rc1)

- finally, on the akpm-base branch in linux-next tree
(if this fails here, then the issue may be some corruption caused by
one of the trees other than -mm)

Sorry to request this; I'm really not sure what else to try at this point :/

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

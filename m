Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA776B0031
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 22:26:35 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so4718842pde.14
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 19:26:34 -0800 (PST)
Received: from mail-pb0-x231.google.com (mail-pb0-x231.google.com [2607:f8b0:400e:c01::231])
        by mx.google.com with ESMTPS id bq5si10442777pbb.18.2014.02.08.19.26.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 19:26:32 -0800 (PST)
Received: by mail-pb0-f49.google.com with SMTP id up15so4797121pbc.8
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 19:26:31 -0800 (PST)
Date: Sat, 8 Feb 2014 19:25:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shm: hang in shmem_fallocate
In-Reply-To: <52F6898A.50101@oracle.com>
Message-ID: <alpine.LSU.2.11.1402081841160.26825@eggly.anvils>
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sat, 8 Feb 2014, Sasha Levin wrote:
> On 12/15/2013 11:01 PM, Sasha Levin wrote:
> > Hi all,
> > 
> > While fuzzing with trinity inside a KVM tools guest running latest -next,
> > I've noticed that
> > quite often there's a hang happening inside shmem_fallocate. There are
> > several processes stuck
> > trying to acquire inode->i_mutex (for more than 2 minutes), while the
> > process that holds it has
> > the following stack trace:
> 
> [snip]
> 
> This still happens. For the record, here's a better trace:

Thanks for the reminder, and for the better trace: I don't find those
traces where _every_ line is a "? " very useful (and whenever I puzzle
over one of those, I wonder if it's inevitable, or something we got
just slightly wrong in working out the frames... another time).

> 
> [  507.124903] CPU: 60 PID: 10864 Comm: trinity-c173 Tainted: G        W
> 3.14.0-rc1-next-20140207-sasha-00007-g03959f6-dirty #2
> [  507.124903] task: ffff8801f1e38000 ti: ffff8801f1e40000 task.ti:
> ffff8801f1e40000
> [  507.124903] RIP: 0010:[<ffffffff81ae924f>]  [<ffffffff81ae924f>]
> __delay+0xf/0x20
> [  507.124903] RSP: 0000:ffff8801f1e418a8  EFLAGS: 00000202
> [  507.124903] RAX: 0000000000000001 RBX: ffff880524cf9f40 RCX:
> 00000000e9adc2c3
> [  507.124903] RDX: 000000000000010f RSI: ffffffff8129813c RDI:
> 00000000ffffffff
> [  507.124903] RBP: ffff8801f1e418a8 R08: 0000000000000000 R09:
> 0000000000000000
> [  507.124903] R10: 0000000000000001 R11: 0000000000000000 R12:
> 00000000000affe0
> [  507.124903] R13: 0000000086c42710 R14: ffff8801f1e41998 R15:
> ffff8801f1e41ac8
> [  507.124903] FS:  00007ff708073700(0000) GS:ffff88052b400000(0000)
> knlGS:0000000000000000
> [  507.124903] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  507.124903] CR2: 000000000089d010 CR3: 00000001f1e2c000 CR4:
> 00000000000006e0
> [  507.124903] DR0: 0000000000696000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  507.124903] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000600
> [  507.124903] Stack:
> [  507.124903]  ffff8801f1e418d8 ffffffff811af053 ffff880524cf9f40
> ffff880524cf9f40
> [  507.124903]  ffff880524cf9f58 ffff8807275b1000 ffff8801f1e41908
> ffffffff84447580
> [  507.124903]  ffffffff8129813c ffffffff811ea882 00003ffffffff000
> 00007ff705eb2000
> [  507.124903] Call Trace:
> [  507.124903]  [<ffffffff811af053>] do_raw_spin_lock+0xe3/0x170
> [  507.124903]  [<ffffffff84447580>] _raw_spin_lock+0x60/0x80
> [  507.124903]  [<ffffffff8129813c>] ? zap_pte_range+0xec/0x580
> [  507.124903]  [<ffffffff811ea882>] ? smp_call_function_single+0x242/0x270
> [  507.124903]  [<ffffffff8129813c>] zap_pte_range+0xec/0x580
> [  507.124903]  [<ffffffff810ca710>] ? flush_tlb_mm_range+0x280/0x280
> [  507.124903]  [<ffffffff81adbd67>] ? cpumask_next_and+0xa7/0xd0
> [  507.124903]  [<ffffffff810ca710>] ? flush_tlb_mm_range+0x280/0x280
> [  507.124903]  [<ffffffff812989ce>] unmap_page_range+0x3fe/0x410
> [  507.124903]  [<ffffffff81298ae1>] unmap_single_vma+0x101/0x120
> [  507.124903]  [<ffffffff81298cb9>] zap_page_range_single+0x119/0x160
> [  507.124903]  [<ffffffff811a87b8>] ? trace_hardirqs_on+0x8/0x10
> [  507.124903]  [<ffffffff812ddb8a>] ? memcg_check_events+0x7a/0x170
> [  507.124903]  [<ffffffff81298d73>] ? unmap_mapping_range+0x73/0x180
> [  507.124903]  [<ffffffff81298dfe>] unmap_mapping_range+0xfe/0x180
> [  507.124903]  [<ffffffff812790c7>] truncate_inode_page+0x37/0x90
> [  507.124903]  [<ffffffff812861aa>] shmem_undo_range+0x6aa/0x770
> [  507.124903]  [<ffffffff81298e68>] ? unmap_mapping_range+0x168/0x180
> [  507.124903]  [<ffffffff81286288>] shmem_truncate_range+0x18/0x40
> [  507.124903]  [<ffffffff81286599>] shmem_fallocate+0x99/0x2f0
> [  507.124903]  [<ffffffff8129487e>] ? madvise_vma+0xde/0x1c0
> [  507.124903]  [<ffffffff811aa5d2>] ? __lock_release+0x1e2/0x200
> [  507.124903]  [<ffffffff812ee006>] do_fallocate+0x126/0x170
> [  507.124903]  [<ffffffff81294894>] madvise_vma+0xf4/0x1c0
> [  507.124903]  [<ffffffff81294ae8>] SyS_madvise+0x188/0x250
> [  507.124903]  [<ffffffff84452450>] tracesys+0xdd/0xe2
> [  507.124903] Code: 66 66 66 66 90 48 c7 05 a4 66 04 05 e0 92 ae 81 c9 c3 66
> 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 ff 15 89 66 04 05 <c9>
> c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8d 04
> 
> I'm still trying to figure it out. To me it seems like a series of calls to
> shmem_truncate_range() takes so long that one of the tasks triggers a hung
> task. We don't actually hang in any specific
> shmem_truncate_range() for too long though.

Okay, we're doing a FALLOC_FL_PUNCH_HOLE on tmpfs (via MADV_REMOVE).

This trace shows clearly that unmap_mapping_range is being called from
truncate_inode_range: that's supposed to be a rare inefficient fallback,
normally all the mapped pages being unmapped by the prior call to
unmap_mapping_range in shmem_fallocate itself.

Now it's conceivable that there's some kind of off-by-one wrap-around
case which doesn't behave as intended, but I was fairly careful there:
you have to be because the different functions involved have different
calling conventions and needs.  It would be interesting to know the
arguments to madvise() and to shmem_fallocate() to rule that out,
but my guess is that's not the problem.

Would trinity be likely to have a thread or process repeatedly faulting
in pages from the hole while it is being punched?

That's what it looks like to me, but I'm not sure what to do about it,
if anything.  It's a pity that shmem_fallocate is holding i_mutex over
this holepunch that never completes, and that locks out others wanting
i_mutex; but whether it's a serious matter in the scale of denials of
service, I'm not so sure.

Note that straight truncation does not suffer from the same problem:
because there the faulters get a SIGBUS when they try to access
beyond end of file, and need the i_mutex to re-extend the file.

Does this happen with other holepunch filesystems?  If it does not,
I'd suppose it's because the tmpfs fault-in-newly-created-page path
is lighter than a consistent disk-based filesystem's has to be.
But we don't want to make the tmpfs path heavier to match them.

My old commit, d0823576bf4b "mm: pincer in truncate_inode_pages_range",
subsequently copied into shmem_undo_range, can be blamed.  It seemed a
nice idea at the time, to guarantee an instant during the holepunch when
the entire hole is empty, whatever userspace does afterwards; but perhaps
we should revert to sweeping out the pages without looking back.

I don't want to make that change (and I don't want to make it in
shmem_undo_range without doing the same in truncate_inode_pages_range),
but it might be the right thing to do: linux-fsdevel Cc'ed for views.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

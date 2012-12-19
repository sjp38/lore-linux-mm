Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B9E266B0068
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 20:36:42 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so929055pad.25
        for <linux-mm@kvack.org>; Tue, 18 Dec 2012 17:36:42 -0800 (PST)
Date: Tue, 18 Dec 2012 17:36:45 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm, ksm: NULL ptr deref in unstable_tree_search_insert
In-Reply-To: <50D1158F.5070905@oracle.com>
Message-ID: <alpine.LNX.2.00.1212181728400.1091@eggly.anvils>
References: <50D1158F.5070905@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 18 Dec 2012, Sasha Levin wrote:

> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest, running latest linux-next kernel, I've
> stumbled on the following:
> 
> [  127.959264] BUG: unable to handle kernel NULL pointer dereference at 0000000000000110
> [  127.960379] IP: [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
> [  127.960379] PGD cc54067 PUD cc55067 PMD 0
> [  127.960379] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  127.960379] Dumping ftrace buffer:
> [  127.960379]    (ftrace buffer empty)
> [  127.960379] CPU 0
> [  127.960379] Pid: 3174, comm: ksmd Tainted: G        W    3.7.0-next-20121218-sasha-00023-g8e46e86 #220
> [  127.978032] RIP: 0010:[<ffffffff81185b60>]  [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
> [  127.978032] RSP: 0018:ffff8800137abb78  EFLAGS: 00010046
> [  127.978032] RAX: 0000000000000086 RBX: 0000000000000110 RCX: 0000000000000001
> [  127.978032] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000110
> [  127.978032] RBP: ffff8800137abc18 R08: 0000000000000002 R09: 0000000000000000
> [  127.978032] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
> [  127.978032] R13: 0000000000000002 R14: ffff8800137b0000 R15: 0000000000000000
> [  127.978032] FS:  0000000000000000(0000) GS:ffff8800bfc00000(0000) knlGS:0000000000000000
> [  127.978032] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  127.978032] CR2: 0000000000000110 CR3: 000000000cc51000 CR4: 00000000000406f0
> [  127.978032] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  127.978032] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  127.978032] Process ksmd (pid: 3174, threadinfo ffff8800137aa000, task ffff8800137b0000)
> [  127.978032] Stack:
> [  127.978032]  ffff8800137abba8 ffffffff863d8b50 ffff8800137b0948 ffffffff863d8b50
> [  127.978032]  ffff8800137abbb8 ffffffff81180a12 ffff8800137abbb8 ffffffff81180a9e
> [  127.978032]  ffff8800137abbe8 ffffffff8118108e ffff8800137abc18 0000000000000000
> [  127.978032] Call Trace:
> [  127.978032]  [<ffffffff81180a12>] ? get_lock_stats+0x22/0x70
> [  127.978032]  [<ffffffff81180a9e>] ? put_lock_stats.isra.16+0xe/0x40
> [  127.978032]  [<ffffffff8118108e>] ? lock_release_holdtime+0x11e/0x130
> [  127.978032]  [<ffffffff811889aa>] lock_acquire+0x1ca/0x270
> [  127.978032]  [<ffffffff8125992f>] ? unstable_tree_search_insert+0x9f/0x260
> [  127.978032]  [<ffffffff83cd7337>] down_read+0x47/0x90
> [  127.978032]  [<ffffffff8125992f>] ? unstable_tree_search_insert+0x9f/0x260
> [  127.978032]  [<ffffffff8125992f>] unstable_tree_search_insert+0x9f/0x260
> [  127.978032]  [<ffffffff8125af27>] cmp_and_merge_page+0xe7/0x1e0
> [  127.978032]  [<ffffffff8125b085>] ksm_do_scan+0x65/0xa0
> [  127.978032]  [<ffffffff8125b12f>] ksm_scan_thread+0x6f/0x2d0
> [  127.978032]  [<ffffffff8113de40>] ? abort_exclusive_wait+0xb0/0xb0
> [  127.978032]  [<ffffffff8125b0c0>] ? ksm_do_scan+0xa0/0xa0
> [  127.978032]  [<ffffffff8113cbd3>] kthread+0xe3/0xf0
> [  127.978032]  [<ffffffff8113caf0>] ? __kthread_bind+0x40/0x40
> [  127.978032]  [<ffffffff83cdae7c>] ret_from_fork+0x7c/0xb0
> [  127.978032]  [<ffffffff8113caf0>] ? __kthread_bind+0x40/0x40
> [  127.978032] Code: 00 83 3d c3 2b b0 05 00 0f 85 d5 09 00 00 be f9 0b 00 00 48 c7 c7 1c d0 b2 84 89 55 88 e8 89 82 f8 ff 8b 55
> 88 e9 b9 09 00 00 90 <48> 81 3b 60 59 22 86 b8 01 00 00 00 44 0f 44 e8 41 83 fc 01 77
> [  127.978032] RIP  [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
> [  127.978032]  RSP <ffff8800137abb78>
> [  127.978032] CR2: 0000000000000110
> [  127.978032] ---[ end trace 3dc1b0c5db8c1230 ]---
> 
> The relevant piece of code is:
> 
> 	static struct page *get_mergeable_page(struct rmap_item *rmap_item)
> 	{
> 	        struct mm_struct *mm = rmap_item->mm;
> 	        unsigned long addr = rmap_item->address;
> 	        struct vm_area_struct *vma;
> 	        struct page *page;
> 	
> 	        down_read(&mm->mmap_sem);
> 
> Where 'mm' is NULL. I'm not really sure how it happens though.

Thanks, yes, I got that, and it's not peculiar to fuzzing at all:
I'm testing the fix at the moment, but just hit something else too
(ksmd oops on NULL p->mm in task_numa_fault i.e. task_numa_placement).

For the moment, you're safer not to run KSM: configure it out or don't
set it to run.  Fixes to follow later, I'll try to remember to Cc you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

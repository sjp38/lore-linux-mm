Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 12FC26B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 11:32:58 -0500 (EST)
Date: Wed, 19 Dec 2012 17:32:53 +0100
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: mm, ksm: NULL ptr deref in unstable_tree_search_insert
Message-ID: <20121219163251.GD4381@thinkpad-work.redhat.com>
References: <50D1158F.5070905@oracle.com>
 <alpine.LNX.2.00.1212181728400.1091@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212181728400.1091@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 18 Dec 2012, Hugh Dickins wrote:
> On Tue, 18 Dec 2012, Sasha Levin wrote:
> 
> > Hi all,
> > 
> > While fuzzing with trinity inside a KVM tools guest, running latest linux-next kernel, I've
> > stumbled on the following:
> > 
> > [  127.959264] BUG: unable to handle kernel NULL pointer dereference at 0000000000000110
> > [  127.960379] IP: [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
> > [  127.960379] PGD cc54067 PUD cc55067 PMD 0
> > [  127.960379] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [  127.960379] Dumping ftrace buffer:
> > [  127.960379]    (ftrace buffer empty)
> > [  127.960379] CPU 0
> > [  127.960379] Pid: 3174, comm: ksmd Tainted: G        W    3.7.0-next-20121218-sasha-00023-g8e46e86 #220
> > [  127.978032] RIP: 0010:[<ffffffff81185b60>]  [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
> > [  127.978032] RSP: 0018:ffff8800137abb78  EFLAGS: 00010046
> > [  127.978032] RAX: 0000000000000086 RBX: 0000000000000110 RCX: 0000000000000001
> > [  127.978032] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000110
> > [  127.978032] RBP: ffff8800137abc18 R08: 0000000000000002 R09: 0000000000000000
> > [  127.978032] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
> > [  127.978032] R13: 0000000000000002 R14: ffff8800137b0000 R15: 0000000000000000
> > [  127.978032] FS:  0000000000000000(0000) GS:ffff8800bfc00000(0000) knlGS:0000000000000000
> > [  127.978032] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  127.978032] CR2: 0000000000000110 CR3: 000000000cc51000 CR4: 00000000000406f0
> > [  127.978032] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [  127.978032] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > [  127.978032] Process ksmd (pid: 3174, threadinfo ffff8800137aa000, task ffff8800137b0000)
> > [  127.978032] Stack:
> > [  127.978032]  ffff8800137abba8 ffffffff863d8b50 ffff8800137b0948 ffffffff863d8b50
> > [  127.978032]  ffff8800137abbb8 ffffffff81180a12 ffff8800137abbb8 ffffffff81180a9e
> > [  127.978032]  ffff8800137abbe8 ffffffff8118108e ffff8800137abc18 0000000000000000
> > [  127.978032] Call Trace:
> > [  127.978032]  [<ffffffff81180a12>] ? get_lock_stats+0x22/0x70
> > [  127.978032]  [<ffffffff81180a9e>] ? put_lock_stats.isra.16+0xe/0x40
> > [  127.978032]  [<ffffffff8118108e>] ? lock_release_holdtime+0x11e/0x130
> > [  127.978032]  [<ffffffff811889aa>] lock_acquire+0x1ca/0x270
> > [  127.978032]  [<ffffffff8125992f>] ? unstable_tree_search_insert+0x9f/0x260
> > [  127.978032]  [<ffffffff83cd7337>] down_read+0x47/0x90
> > [  127.978032]  [<ffffffff8125992f>] ? unstable_tree_search_insert+0x9f/0x260
> > [  127.978032]  [<ffffffff8125992f>] unstable_tree_search_insert+0x9f/0x260
> > [  127.978032]  [<ffffffff8125af27>] cmp_and_merge_page+0xe7/0x1e0
> > [  127.978032]  [<ffffffff8125b085>] ksm_do_scan+0x65/0xa0
> > [  127.978032]  [<ffffffff8125b12f>] ksm_scan_thread+0x6f/0x2d0
> > [  127.978032]  [<ffffffff8113de40>] ? abort_exclusive_wait+0xb0/0xb0
> > [  127.978032]  [<ffffffff8125b0c0>] ? ksm_do_scan+0xa0/0xa0
> > [  127.978032]  [<ffffffff8113cbd3>] kthread+0xe3/0xf0
> > [  127.978032]  [<ffffffff8113caf0>] ? __kthread_bind+0x40/0x40
> > [  127.978032]  [<ffffffff83cdae7c>] ret_from_fork+0x7c/0xb0
> > [  127.978032]  [<ffffffff8113caf0>] ? __kthread_bind+0x40/0x40
> > [  127.978032] Code: 00 83 3d c3 2b b0 05 00 0f 85 d5 09 00 00 be f9 0b 00 00 48 c7 c7 1c d0 b2 84 89 55 88 e8 89 82 f8 ff 8b 55
> > 88 e9 b9 09 00 00 90 <48> 81 3b 60 59 22 86 b8 01 00 00 00 44 0f 44 e8 41 83 fc 01 77
> > [  127.978032] RIP  [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
> > [  127.978032]  RSP <ffff8800137abb78>
> > [  127.978032] CR2: 0000000000000110
> > [  127.978032] ---[ end trace 3dc1b0c5db8c1230 ]---
> > 
> > The relevant piece of code is:
> > 
> > 	static struct page *get_mergeable_page(struct rmap_item *rmap_item)
> > 	{
> > 	        struct mm_struct *mm = rmap_item->mm;
> > 	        unsigned long addr = rmap_item->address;
> > 	        struct vm_area_struct *vma;
> > 	        struct page *page;
> > 	
> > 	        down_read(&mm->mmap_sem);
> > 
> > Where 'mm' is NULL. I'm not really sure how it happens though.
> 
> Thanks, yes, I got that, and it's not peculiar to fuzzing at all:
> I'm testing the fix at the moment, but just hit something else too
> (ksmd oops on NULL p->mm in task_numa_fault i.e. task_numa_placement).
> 
> For the moment, you're safer not to run KSM: configure it out or don't
> set it to run.  Fixes to follow later, I'll try to remember to Cc you.
> 

Thanks to trinity inside of KVM guest, I've reproduced it too.

[ 1193.299397] Call Trace:
[ 1193.328506]  [<ffffffff811785c7>] ksm_scan_thread+0x967/0xd70
[ 1193.397097]  [<ffffffff810818d0>] ? wake_up_bit+0x40/0x40
[ 1193.461528]  [<ffffffff81177c60>] ? run_store+0x2b0/0x2b0
[ 1193.525962]  [<ffffffff81080fb0>] kthread+0xc0/0xd0
[ 1193.584157]  [<ffffffff81080ef0>] ? kthread_create_on_node+0x120/0x120
[ 1193.662101]  [<ffffffff8165c3ac>] ret_from_fork+0x7c/0xb0
[ 1193.726535]  [<ffffffff81080ef0>] ? kthread_create_on_node+0x120/0x120
[ 1193.804475] Code: fe 4a cc ff 48 83 c4 08 5b 5d c3 0f 1f 80 00 00 00 00 66
66 66 66 90 55 48 89 e5 53 48 89 fb 48 83 ec 08 e8 9a 0a 00 00 48 89 d8 <f0>
48 ff 00 79 05 e8 9c 4a cc ff 48 83 c4 08 5b 5d c3 55 48 89 
[ 1194.030380] RIP  [<ffffffff81651ed9>] down_read+0x19/0x2b
[ 1194.094816]  RSP <ffff880122a73de8>
[ 1194.136385] CR2: 00007fb4c6e01268
[ 1194.176280] ---[ end trace 17dda1cb9a62bc36 ]---

With enabled CONFIG_NUMA_BALANCING this one, but not sure if we should use
new numasched code or ksm:

[ 4706.859796] Call Trace:
[ 4706.888904]  [<ffffffff811577d5>] do_numa_page+0xe5/0x130
[ 4706.953335]  [<ffffffff81157a79>] handle_pte_fault+0x259/0xa50
[ 4707.023012]  [<ffffffffa008a025>] ? kvm_set_spte_hva+0x25/0x30 [kvm]
[ 4707.098878]  [<ffffffff8115903e>] handle_mm_fault+0x26e/0x660
[ 4707.167470]  [<ffffffff811775a2>] ?
__mmu_notifier_invalidate_range_end+0x72/0x90
[ 4707.256850]  [<ffffffff8112e68e>] ? unlock_page+0x2e/0x40
[ 4707.321283]  [<ffffffff811779d5>] break_ksm+0x75/0xa0
[ 4707.381560]  [<ffffffff81177c0d>] break_cow+0x5d/0x80
[ 4707.441833]  [<ffffffff811794c7>] ksm_scan_thread+0xc87/0xd70
[ 4707.510427]  [<ffffffff810818e0>] ? wake_up_bit+0x40/0x40
[ 4707.574860]  [<ffffffff81178840>] ? run_store+0x2b0/0x2b0
[ 4707.639294]  [<ffffffff81080fc0>] kthread+0xc0/0xd0
[ 4707.697489]  [<ffffffff81080f00>] ? kthread_create_on_node+0x120/0x120
[ 4707.775435]  [<ffffffff8165d8ec>] ret_from_fork+0x7c/0xb0
[ 4707.839869]  [<ffffffff81080f00>] ? kthread_create_on_node+0x120/0x120
[ 4707.917806] Code: f8 65 48 8b 1c 25 40 c7 00 00 e9 11 00 00 00 48 8b 5d e8
4c 8b 65 f0 4c 8b 6d f8 c9 c3 0f 1f 00 84 d2 74 2c 48 8b 83 98 02 00 00 <8b>
80 68 03 00 00 3b 83 94 07 00 00 74 d6 89 83 94 07 00 00 48 
[ 4708.143711] RIP  [<ffffffff81098db3>] task_numa_fault+0x43/0xa0
[ 4708.214389]  RSP <ffff880122a1fbc8>
[ 4708.255957] CR2: 0000000000000368
[ 4708.295722] ---[ end trace 5ffe704785995d40 ]---

I am starting looking into it.

thanks!
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

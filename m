Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 55A3E6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 11:09:31 -0500 (EST)
Date: Tue, 17 Nov 2009 16:09:22 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] prevent deadlock in __unmap_hugepage_range() when
	alloc_huge_page() fails.
Message-ID: <20091117160922.GB29804@csn.ul.ie>
References: <1257872456.3227.2.camel@dhcp-100-19-198.bos.redhat.com> <20091116121253.d86920a0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091116121253.d86920a0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Larry Woodman <lwoodman@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Adam Litke <agl@us.ibm.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 16, 2009 at 12:12:53PM -0800, Andrew Morton wrote:
> On Tue, 10 Nov 2009 12:00:56 -0500
> Larry Woodman <lwoodman@redhat.com> wrote:
> 
> > 
> > hugetlb_fault() takes the mm->page_table_lock spinlock then calls
> > hugetlb_cow().  If the alloc_huge_page() in hugetlb_cow() fails due to
> > an insufficient huge page pool it calls unmap_ref_private() with the
> > mm->page_table_lock held.  unmap_ref_private() then calls
> > unmap_hugepage_range() which tries to acquire the mm->page_table_lock.
> > 
> > 
> > [<ffffffff810928c3>] print_circular_bug_tail+0x80/0x9f 
> >  [<ffffffff8109280b>] ? check_noncircular+0xb0/0xe8
> >  [<ffffffff810935e0>] __lock_acquire+0x956/0xc0e
> >  [<ffffffff81093986>] lock_acquire+0xee/0x12e
> >  [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
> >  [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
> >  [<ffffffff814c348d>] _spin_lock+0x40/0x89
> >  [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
> >  [<ffffffff8111afee>] ? alloc_huge_page+0x218/0x318
> >  [<ffffffff8111a7a6>] unmap_hugepage_range+0x3e/0x84
> >  [<ffffffff8111b2d0>] hugetlb_cow+0x1e2/0x3f4
> >  [<ffffffff8111b935>] ? hugetlb_fault+0x453/0x4f6
> >  [<ffffffff8111b962>] hugetlb_fault+0x480/0x4f6
> >  [<ffffffff8111baee>] follow_hugetlb_page+0x116/0x2d9
> >  [<ffffffff814c31a7>] ? _spin_unlock_irq+0x3a/0x5c
> >  [<ffffffff81107b4d>] __get_user_pages+0x2a3/0x427
> >  [<ffffffff81107d0f>] get_user_pages+0x3e/0x54
> >  [<ffffffff81040b8b>] get_user_pages_fast+0x170/0x1b5
> >  [<ffffffff81160352>] dio_get_page+0x64/0x14a
> >  [<ffffffff8116112a>] __blockdev_direct_IO+0x4b7/0xb31
> >  [<ffffffff8115ef91>] blkdev_direct_IO+0x58/0x6e
> >  [<ffffffff8115e0a4>] ? blkdev_get_blocks+0x0/0xb8
> >  [<ffffffff810ed2c5>] generic_file_aio_read+0xdd/0x528
> >  [<ffffffff81219da3>] ? avc_has_perm+0x66/0x8c
> >  [<ffffffff81132842>] do_sync_read+0xf5/0x146
> >  [<ffffffff8107da00>] ? autoremove_wake_function+0x0/0x5a
> >  [<ffffffff81211857>] ? security_file_permission+0x24/0x3a
> >  [<ffffffff81132fd8>] vfs_read+0xb5/0x126
> >  [<ffffffff81133f6b>] ? fget_light+0x5e/0xf8
> >  [<ffffffff81133131>] sys_read+0x54/0x8c
> >  [<ffffffff81011e42>] system_call_fastpath+0x16/0x1b
> 
> Confused.
> 
> That code is very old, alloc_huge_page() failures are surely common and
> afaict the bug will lead to an instantly dead box.  So why haven't
> people hit this bug before now?
> 

Failures like that can happen when the workload is calling fork() with
MAP_PRIVATE and the child is writing with a small hugepage pool. I reran the
tests used at the time the code was written and they don't trigger warnings or
problems in the normal case other than the note that the child got killed. It
required PROVE_LOCKING to be set which is not set on the default configs I
normally use when I don't suspect locking problems.

I can confirm that with PROVE_LOCKING set that the warnings do trigger but
the machine doesn't lockup and I see in dmesg. Bit of a surprise really,
you'd think a double taking of a spinlock would result in damage.

[  111.031795] PID 2876 killed due to inadequate hugepage pool

Applying the patch does fix that problem but there is a very similar
problem remaining in the same path. More on this later.

> > This can be fixed by dropping the mm->page_table_lock around the call 
> > to unmap_ref_private() if alloc_huge_page() fails, its dropped right below
> > in the normal path anyway:
> > 
> 
> Why is that safe?  What is the page_table_lock protecting in here?
> 

The lock is there from 2005 and it was to protect against against concurrent
PTE updates. However, it is probably unnecessary protection as this whole
path should be protected by the hugetlb_instantiation_mutex. There was locking
that was left behind that may be unnecessary after that mutex was introducted
but is left in place for the day someone decides to tackle that mutex.

I don't think this patch solves everything with the page_table_lock in
that path because it's also possible from the COW path to enter the buddy
allocator with the spinlock still held with setups like

1. create a mapping of 3 huge pages
2. allow the system to dynamically allocate 6 huge pages
3. fork() and fault in the child
	with preempt and DEBUG_SPINLOCK_SLEEP set, a different
	warning can still trigger

Here is alternative patch below which extends Larry's patch to drop the
spinlock earlier and retake as required. Because it involves page table
updates, I've added Hugh to the cc because he knows all the rules and
gotchas backwards.

==== CUT HERE ====
hugetlb: prevent deadlock in __unmap_hugepage_range() when alloc_huge_page() fails.

hugetlb_fault() takes the mm->page_table_lock spinlock then calls
hugetlb_cow(). If the alloc_huge_page() in hugetlb_cow() fails due to an
insufficient huge page pool it calls unmap_ref_private() with the
mm->page_table_lock held. unmap_ref_private() then calls
unmap_hugepage_range() which tries to acquire the mm->page_table_lock.

[<ffffffff810928c3>] print_circular_bug_tail+0x80/0x9f
 [<ffffffff8109280b>] ? check_noncircular+0xb0/0xe8
 [<ffffffff810935e0>] __lock_acquire+0x956/0xc0e
 [<ffffffff81093986>] lock_acquire+0xee/0x12e
 [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
 [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
 [<ffffffff814c348d>] _spin_lock+0x40/0x89
 [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
 [<ffffffff8111afee>] ? alloc_huge_page+0x218/0x318
 [<ffffffff8111a7a6>] unmap_hugepage_range+0x3e/0x84
 [<ffffffff8111b2d0>] hugetlb_cow+0x1e2/0x3f4
 [<ffffffff8111b935>] ? hugetlb_fault+0x453/0x4f6
 [<ffffffff8111b962>] hugetlb_fault+0x480/0x4f6
 [<ffffffff8111baee>] follow_hugetlb_page+0x116/0x2d9
 [<ffffffff814c31a7>] ? _spin_unlock_irq+0x3a/0x5c
 [<ffffffff81107b4d>] __get_user_pages+0x2a3/0x427
 [<ffffffff81107d0f>] get_user_pages+0x3e/0x54
 [<ffffffff81040b8b>] get_user_pages_fast+0x170/0x1b5
 [<ffffffff81160352>] dio_get_page+0x64/0x14a
 [<ffffffff8116112a>] __blockdev_direct_IO+0x4b7/0xb31
 [<ffffffff8115ef91>] blkdev_direct_IO+0x58/0x6e
 [<ffffffff8115e0a4>] ? blkdev_get_blocks+0x0/0xb8
 [<ffffffff810ed2c5>] generic_file_aio_read+0xdd/0x528
 [<ffffffff81219da3>] ? avc_has_perm+0x66/0x8c
 [<ffffffff81132842>] do_sync_read+0xf5/0x146
 [<ffffffff8107da00>] ? autoremove_wake_function+0x0/0x5a
 [<ffffffff81211857>] ? security_file_permission+0x24/0x3a
 [<ffffffff81132fd8>] vfs_read+0xb5/0x126
 [<ffffffff81133f6b>] ? fget_light+0x5e/0xf8
 [<ffffffff81133131>] sys_read+0x54/0x8c
 [<ffffffff81011e42>] system_call_fastpath+0x16/0x1b

This can be fixed by dropping the mm->page_table_lock around the call to
unmap_ref_private() if alloc_huge_page() fails, its dropped right below in
the normal path anyway. However, earlier in the that function, it's also
possible to call into the page allocator with the same spinlock held.

What this patch does is drop the spinlock before the page allocator is
potentially entered. The check for page allocation failure can be made
without the page_table_lock as well as the copy of the huge page. Even if
the PTE changed while the spinlock was held, the consequence is that a huge
page is copied unnecessarily. This resolves both the double taking of the
lock and sleeping with the spinlock held.

[mel@csn.ul.ie: Cover also the case where process can sleep with spinlock]
Signed-off-by: Larry Woodman <lwooman@redhat.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Cc: Adam Litke <agl@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: David Gibson <david@gibson.dropbear.id.au>
--- 
 mm/hugetlb.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 450493d..2ef66a2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2293,6 +2293,9 @@ retry_avoidcopy:
 		outside_reserve = 1;
 
 	page_cache_get(old_page);
+
+	/* Drop page_table_lock as buddy allocator may be called */
+	spin_unlock(&mm->page_table_lock);
 	new_page = alloc_huge_page(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
@@ -2310,19 +2313,25 @@ retry_avoidcopy:
 			if (unmap_ref_private(mm, vma, old_page, address)) {
 				BUG_ON(page_count(old_page) != 1);
 				BUG_ON(huge_pte_none(pte));
+				spin_lock(&mm->page_table_lock);
 				goto retry_avoidcopy;
 			}
 			WARN_ON_ONCE(1);
 		}
 
+		/* Caller expects lock to be held */
+		spin_lock(&mm->page_table_lock);
 		return -PTR_ERR(new_page);
 	}
 
-	spin_unlock(&mm->page_table_lock);
 	copy_huge_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);
-	spin_lock(&mm->page_table_lock);
 
+	/*
+	 * Retake the page_table_lock to check for racing updates
+	 * before the page tables are altered
+	 */
+	spin_lock(&mm->page_table_lock);
 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
 		/* Break COW */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

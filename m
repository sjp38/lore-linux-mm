Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2555C6B0036
	for <linux-mm@kvack.org>; Sun, 11 May 2014 08:31:54 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so6318230pab.17
        for <linux-mm@kvack.org>; Sun, 11 May 2014 05:31:53 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id or1si7130616pac.132.2014.05.11.05.31.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 May 2014 05:31:53 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so6317740pab.22
        for <linux-mm@kvack.org>; Sun, 11 May 2014 05:31:52 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: Re: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
Date: Sun, 11 May 2014 20:31:40 +0800
Message-Id: <1399811500-14472-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, nasa4836@gmail.com, mgorman@suse.de, zhangyanfei@cn.fujitsu.com, aarcange@redhat.com, fabf@skynet.be, sasha.levin@oracle.com, oleg@redhat.com, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, gorcunov@gmail.com, cl@linux.com, dave.hansen@linux.intel.com, toshi.kani@hp.com, paul.gortmaker@windriver.com, srivatsa.bhat@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

>Your original __mod_zone_page_state happened to be correct;
>but you have no understanding of why it was correct, so its
>comment was very wrong, even after you changed the irq wording.
>
>This series just propagates your misunderstanding further,
>while providing an object lesson in how not to present a series.
>
>Sorry, you have quickly developed an unenviable reputation for
>patches which waste developers' time: please consider your
>patches much more carefully before posting them.

Hi, Hugh.

I'm sorry for my misunderstanding in the previous patches. I should
have given them more thought. I'm really sorry. {palmface} X 3

And I am really appreciated for your detailed comments and your patience
with me such a noob;-) Today I've spent some time on digging into
the history to figure out what is under the hood.

>I'd prefer to let Christoph write the definitive version,
>but my first stab at it would be:
>
>/*
> * For use when we know that interrupts are disabled,
> * or when we know that preemption is disabled and that
> * particular counter cannot be updated from interrupt context.
> */

 Seconded. Christoph, would you please write a comment? I've written
 a new one based on Hugh's, would you please also take a look? Thanks.

>Once upon a time, from 2.6.16 to 2.6.32, there was indeed a relevant
>and helpful comment in __page_set_anon_rmap():
>        /*
>         * nr_mapped state can be updated without turning off
>         * interrupts because it is not modified via interrupt.
>         */
>        __inc_page_state(nr_mapped);
>
>The comment survived the replacement of nr_mapped, but eventually
>it got cleaned away completely.
>
>It is safe to use the irq-unsafe __mod_zone_page_stat on counters
>which are never modified via interrupt.
>You are right that the comment is not good enough, but I don't trust
>your version either.  Since percpu variables are involved, it's important
>that preemption be disabled too (see comment above __inc_zone_state).

Thanks for clarifying this. I checked the history, this is my understanding
, correct me if I am wrong, thanks!

__mod_zone_page_stat() should be called with irq-off, this is a strongest
gurantee for safety. For a weaker gurantee, preemte-disable is needed and
in this situation, the item counter in question should not be modified in
interrupt context.

It is essential to have such gurantees, because __mod_zone_page_stat()
is a two-step operation : read-percpu-couter-then-modify-it.
(Need comments. Christoph, do I misunderstand it?)

For for all other call sites of __mod_zone_page_stat() in the patch,
I think your comment is right, it is because they are not modified in
interrupt context, so we could safely use __mod_zone_page_stat().
 
But for the call site in page_add_new_anon_rmap(), I think my previous
wording is appropriate: mlocked_vma_newpage() is only called in fault path
by page_add_new_anon_rmap() on a *new* page, which is initially only visible
via the pagetables, and the pte is locked while calling page_add_new_anon_rmap(),
so we are not afraid of others seeing it a this point, not even modifying it.
so whether is could be modified in interrupt context or not does matter, but it
is not the key point here.

I've renewed the patch. And in this patch, I also change page_add_new_anon_rmap to
use __mod_zone_page_stat(), since they are quite relative to be in one patch.

Thanks for your review. I am appreciated for your comments. Andrew, Christoph,
would you please review it? Thansk.

-----<8-----
mm: use the light version __mod_zone_page_state in mlocked_vma_newpage()

mlocked_vma_newpage() is only called in fault path by
page_add_new_anon_rmap(), which is called on a *new* page.
And such page is initially only visible via the pagetables, and the
pte is locked while calling page_add_new_anon_rmap(), so we need not
use an irq-safe mod_zone_page_state() here, using a light-weight version
__mod_zone_page_state() would be OK.

This patch also documents __mod_zone_page_state() and some of its
callsites.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/internal.h |  9 ++++++++-
 mm/rmap.c     | 11 +++++++++++
 mm/vmstat.c   |  5 ++++-
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 07b6736..7140c9b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -196,7 +196,14 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
 		return 0;
 
 	if (!TestSetPageMlocked(page)) {
-		mod_zone_page_state(page_zone(page), NR_MLOCK,
+		/*
+		 * We use the irq-unsafe __mod_zone_page_stat because
+		 * 1. this counter is not modified in interrupt context, and
+		 * 2. pte lock is held, and this a newpage, which is initially
+		 *    only visible via the pagetables. So this would exclude
+		 *    racy processes from preemting us and to modify it.
+		 */
+		__mod_zone_page_state(page_zone(page), NR_MLOCK,
 				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..0700253 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -986,6 +986,12 @@ void do_page_add_anon_rmap(struct page *page,
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
 	if (first) {
+		/*
+		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
+		 * 1. these counters are not modified in interrupt context, and
+		 * 2. pte lock is held, this would exclude racy processes from
+		 *    preemting us and to modify these counters.
+		 */
 		if (PageTransHuge(page))
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
@@ -1077,6 +1083,11 @@ void page_remove_rmap(struct page *page)
 	/*
 	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
 	 * and not charged by memcg for now.
+	 *
+	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
+	 * 1. these counters are not modified in interrupt context, and
+	 * 2. pte lock is held, this would exclude racy processes from
+	 *    preemting us and to modify these counters.
 	 */
 	if (unlikely(PageHuge(page)))
 		goto out;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 302dd07..e6db98d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -207,7 +207,10 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 }
 
 /*
- * For use when we know that interrupts are disabled.
+ * For use when we know that either
+ *  1. interrupts are disabled, or
+ *  2. preemption is disabled and that particular counter cannot be
+ *     updated from interrupt context.
  */
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

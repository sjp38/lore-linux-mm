Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 805246B1E63
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:45:05 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g63-v6so760315pfc.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 21:45:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a72sor48169813pge.21.2018.11.19.21.45.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 21:45:03 -0800 (PST)
Date: Mon, 19 Nov 2018 21:44:41 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Memory hotplug softlock issue
In-Reply-To: <20181120015644.GA5727@MiWiFi-R3L-srv>
Message-ID: <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
References: <20181115143204.GV23831@dhcp22.suse.cz> <20181116012433.GU2653@MiWiFi-R3L-srv> <20181116091409.GD14706@dhcp22.suse.cz> <20181119105202.GE18471@MiWiFi-R3L-srv> <20181119124033.GJ22247@dhcp22.suse.cz> <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz> <20181119173312.GV22247@dhcp22.suse.cz> <alpine.LSU.2.11.1811191215290.15640@eggly.anvils> <20181119205907.GW22247@dhcp22.suse.cz> <20181120015644.GA5727@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On Tue, 20 Nov 2018, Baoquan He wrote:
> On 11/19/18 at 09:59pm, Michal Hocko wrote:
> > On Mon 19-11-18 12:34:09, Hugh Dickins wrote:
> > > I'm glad that I delayed, what I had then (migration_waitqueue instead
> > > of using page_waitqueue) was not wrong, but what I've been using the
> > > last couple of months is rather better (and can be put to use to solve
> > > similar problems in collapsing pages on huge tmpfs. but we don't need
> > > to get into that at this time): put_and_wait_on_page_locked().
> > > 
> > > What I have not yet done is verify it on latest kernel, and research
> > > the interested Cc list (Linus and Tim Chen come immediately to mind),
> > > and write the commit comment. I have some testing to do on the latest
> > > kernel today, so I'll throw put_and_wait_on_page_locked() in too,
> > > and post tomorrow I hope.
> > 
> > Cool, it seems that Baoquan has a reliable test case to trigger the
> > pathological case.
> 
> Yes. I will test Hugh's patch.

Thanks: I've completed some of the retesting now, so it would probably
help us all better if I post the patch in this thread, even without
completing its description and links and Cc list yet - there isn't
even a problem description below, I still have to paste that in from
the unposted patch that I made six months ago.  Here is today's...


[PATCH] mm: put_and_wait_on_page_locked() while page is migrated

We have all assumed that it is essential to hold a page reference while
waiting on a page lock: partly to guarantee that there is still a struct
page when MEMORY_HOTREMOVE is configured, but also to protect against
reuse of the struct page going to someone who then holds the page locked
indefinitely, when the waiter can reasonably expect timely unlocking.

But in fact, so long as wait_on_page_bit_common() does the put_page(),
and is careful not to rely on struct page contents thereafter, there is
no need to hold a reference to the page while waiting on it.  That does
mean that this case cannot go back through the loop: but that's fine for
the page migration case, and even if used more widely, is limited by the
"Stop walking if it's locked" optimization in wake_page_function().

Add interface put_and_wait_on_page_locked() to do this, using negative
value of the lock arg to wait_on_page_bit_common() to implement it.
No interruptible or killable variant needed yet, but they might follow:
I have a vague notion that reporting -EINTR should take precedence over
return from wait_on_page_bit_common() without knowing the page state,
so arrange it accordingly - but that may be nothing but pedantic.

shrink_page_list()'s __ClearPageLocked(): that was a surprise! this
survived a lot of testing before that showed up.  It does raise the
question: should is_page_cache_freeable() and __remove_mapping() now
treat a PG_waiters page as if an extra reference were held?  Perhaps,
but I don't think it matters much, since shrink_page_list() already
had to win its trylock_page(), so waiters are not very common there: I
noticed no difference when trying the bigger change, and it's surely not
needed while put_and_wait_on_page_locked() is only for page migration.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pagemap.h |  2 ++
 mm/filemap.c            | 53 ++++++++++++++++++++++++++++++++---------
 mm/huge_memory.c        |  6 ++---
 mm/migrate.c            | 12 ++++------
 mm/vmscan.c             | 11 +++++----
 5 files changed, 57 insertions(+), 27 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 226f96f0dee0..e2d7039af6a3 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -537,6 +537,8 @@ static inline int wait_on_page_locked_killable(struct page *page)
 	return wait_on_page_bit_killable(compound_head(page), PG_locked);
 }
 
+extern void put_and_wait_on_page_locked(struct page *page);
+
 /* 
  * Wait for a page to complete writeback
  */
diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8ee02c..ef82119032d8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -981,7 +981,14 @@ static int wake_page_function(wait_queue_entry_t *wait, unsigned mode, int sync,
 	if (wait_page->bit_nr != key->bit_nr)
 		return 0;
 
-	/* Stop walking if it's locked */
+	/*
+	 * Stop walking if it's locked.
+	 * Is this safe if put_and_wait_on_page_locked() is in use?
+	 * Yes: the waker must hold a reference to this page, and if PG_locked
+	 * has now already been set by another task, that task must also hold
+	 * a reference to the *same usage* of this page; so there is no need
+	 * to walk on to wake even the put_and_wait_on_page_locked() callers.
+	 */
 	if (test_bit(key->bit_nr, &key->page->flags))
 		return -1;
 
@@ -1050,13 +1057,14 @@ static void wake_up_page(struct page *page, int bit)
 }
 
 static inline int wait_on_page_bit_common(wait_queue_head_t *q,
-		struct page *page, int bit_nr, int state, bool lock)
+		struct page *page, int bit_nr, int state, int lock)
 {
 	struct wait_page_queue wait_page;
 	wait_queue_entry_t *wait = &wait_page.wait;
 	bool thrashing = false;
 	unsigned long pflags;
 	int ret = 0;
+	bool bit_is_set;
 
 	if (bit_nr == PG_locked &&
 	    !PageUptodate(page) && PageWorkingset(page)) {
@@ -1067,7 +1075,7 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 	}
 
 	init_wait(wait);
-	wait->flags = lock ? WQ_FLAG_EXCLUSIVE : 0;
+	wait->flags = lock > 0 ? WQ_FLAG_EXCLUSIVE : 0;
 	wait->func = wake_page_function;
 	wait_page.page = page;
 	wait_page.bit_nr = bit_nr;
@@ -1084,14 +1092,17 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 
 		spin_unlock_irq(&q->lock);
 
-		if (likely(test_bit(bit_nr, &page->flags))) {
+		bit_is_set = test_bit(bit_nr, &page->flags);
+		if (lock < 0)
+			put_page(page);
+
+		if (likely(bit_is_set))
 			io_schedule();
-		}
 
-		if (lock) {
+		if (lock > 0) {
 			if (!test_and_set_bit_lock(bit_nr, &page->flags))
 				break;
-		} else {
+		} else if (lock == 0) {
 			if (!test_bit(bit_nr, &page->flags))
 				break;
 		}
@@ -1100,6 +1111,17 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 			ret = -EINTR;
 			break;
 		}
+
+		if (lock < 0) {
+			/*
+			 * We can no longer safely access page->flags:
+			 * even if CONFIG_MEMORY_HOTREMOVE is not enabled,
+			 * there is a risk of waiting forever on a page reused
+			 * for something that keeps it locked indefinitely.
+			 * But best check for -EINTR above before breaking.
+			 */
+			break;
+		}
 	}
 
 	finish_wait(q, wait);
@@ -1124,17 +1146,26 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 void wait_on_page_bit(struct page *page, int bit_nr)
 {
 	wait_queue_head_t *q = page_waitqueue(page);
-	wait_on_page_bit_common(q, page, bit_nr, TASK_UNINTERRUPTIBLE, false);
+	wait_on_page_bit_common(q, page, bit_nr, TASK_UNINTERRUPTIBLE, 0);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
 int wait_on_page_bit_killable(struct page *page, int bit_nr)
 {
 	wait_queue_head_t *q = page_waitqueue(page);
-	return wait_on_page_bit_common(q, page, bit_nr, TASK_KILLABLE, false);
+	return wait_on_page_bit_common(q, page, bit_nr, TASK_KILLABLE, 0);
 }
 EXPORT_SYMBOL(wait_on_page_bit_killable);
 
+void put_and_wait_on_page_locked(struct page *page)
+{
+	wait_queue_head_t *q;
+
+	page = compound_head(page);
+	q = page_waitqueue(page);
+	wait_on_page_bit_common(q, page, PG_locked, TASK_UNINTERRUPTIBLE, -1);
+}
+
 /**
  * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
  * @page: Page defining the wait queue of interest
@@ -1264,7 +1295,7 @@ void __lock_page(struct page *__page)
 {
 	struct page *page = compound_head(__page);
 	wait_queue_head_t *q = page_waitqueue(page);
-	wait_on_page_bit_common(q, page, PG_locked, TASK_UNINTERRUPTIBLE, true);
+	wait_on_page_bit_common(q, page, PG_locked, TASK_UNINTERRUPTIBLE, 1);
 }
 EXPORT_SYMBOL(__lock_page);
 
@@ -1272,7 +1303,7 @@ int __lock_page_killable(struct page *__page)
 {
 	struct page *page = compound_head(__page);
 	wait_queue_head_t *q = page_waitqueue(page);
-	return wait_on_page_bit_common(q, page, PG_locked, TASK_KILLABLE, true);
+	return wait_on_page_bit_common(q, page, PG_locked, TASK_KILLABLE, 1);
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 622cced74fd9..832ab11badc2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1501,8 +1501,7 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 		if (!get_page_unless_zero(page))
 			goto out_unlock;
 		spin_unlock(vmf->ptl);
-		wait_on_page_locked(page);
-		put_page(page);
+		put_and_wait_on_page_locked(page);
 		goto out;
 	}
 
@@ -1538,8 +1537,7 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 		if (!get_page_unless_zero(page))
 			goto out_unlock;
 		spin_unlock(vmf->ptl);
-		wait_on_page_locked(page);
-		put_page(page);
+		put_and_wait_on_page_locked(page);
 		goto out;
 	}
 
diff --git a/mm/migrate.c b/mm/migrate.c
index f7e4bfdc13b7..acda06f99754 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -327,16 +327,13 @@ void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
 
 	/*
 	 * Once page cache replacement of page migration started, page_count
-	 * *must* be zero. And, we don't want to call wait_on_page_locked()
-	 * against a page without get_page().
-	 * So, we use get_page_unless_zero(), here. Even failed, page fault
-	 * will occur again.
+	 * is zero; but we must not call put_and_wait_on_page_locked() without
+	 * a ref. Use get_page_unless_zero(), and just fault again if it fails.
 	 */
 	if (!get_page_unless_zero(page))
 		goto out;
 	pte_unmap_unlock(ptep, ptl);
-	wait_on_page_locked(page);
-	put_page(page);
+	put_and_wait_on_page_locked(page);
 	return;
 out:
 	pte_unmap_unlock(ptep, ptl);
@@ -370,8 +367,7 @@ void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
 	if (!get_page_unless_zero(page))
 		goto unlock;
 	spin_unlock(ptl);
-	wait_on_page_locked(page);
-	put_page(page);
+	put_and_wait_on_page_locked(page);
 	return;
 unlock:
 	spin_unlock(ptl);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62ac0c488624..85d9dde31153 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1459,11 +1459,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		/*
 		 * At this point, we have no other references and there is
 		 * no way to pick any more up (removed from LRU, removed
-		 * from pagecache). Can use non-atomic bitops now (and
-		 * we obviously don't have to worry about waking up a process
-		 * waiting on the page lock, because there are no references.
+		 * from pagecache). Usually we can use non-atomic bitops now,
+		 * but beware: earlier calls to put_and_wait_on_page_locked()
+		 * might still be waiting.
 		 */
-		__ClearPageLocked(page);
+		if (unlikely(PageWaiters(page)))
+			unlock_page(page);
+		else
+			__ClearPageLocked(page);
 free_it:
 		nr_reclaimed++;
 
-- 
2.19.1.1215.g8438c0b245-goog

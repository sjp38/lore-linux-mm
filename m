From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch 2/3 v2] swap: refactor pagevec flushing
References: <20081022225006.010250557@saeurebad.de>
	<20081022225512.879260477@saeurebad.de>
	<20081026235011.8af44857.akpm@linux-foundation.org>
	<877i7uihns.fsf@saeurebad.de>
Date: Mon, 27 Oct 2008 13:18:38 +0100
In-Reply-To: <877i7uihns.fsf@saeurebad.de> (Johannes Weiner's message of "Mon,
	27 Oct 2008 09:08:55 +0100")
Message-ID: <873aiii63l.fsf_-_@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@saeurebad.de> writes:

> Andrew Morton <akpm@linux-foundation.org> writes:
>
>> On Thu, 23 Oct 2008 00:50:08 +0200 Johannes Weiner <hannes@saeurebad.de> wrote:
>>
>>> Having all pagevecs in one array allows for easier flushing.  Use a
>>> single flush function that decides what to do based on the target LRU.
>>> 
>>> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
>>> ---
>>>  include/linux/pagevec.h |   13 +++--
>>>  mm/swap.c               |  121 +++++++++++++++++++++++-------------------------
>>>  2 files changed, 66 insertions(+), 68 deletions(-)
>>> 
>>> --- a/include/linux/pagevec.h
>>> +++ b/include/linux/pagevec.h
>>> @@ -27,10 +27,13 @@ enum lru_pagevec {
>>>  	NR_LRU_PAGEVECS
>>>  };
>>>  
>>> +#define for_each_lru_pagevec(pv)		\
>>> +	for (pv = 0; pv < NR_LRU_PAGEVECS; pv++)
>>
>> This only gets used once.  I don't think it's existence is justified?
>
> I don't see any other use-case for it now.  So, yes, let's drop it.
>
>> (`pv' is usally parenthesised in macros like this, but it's unlikely to
>> matter).
>
> Hmm, wondering which valid lvalue construction could break it...?
> Probably something involving stars...
>
> Okay, get doubly rid of it.  Replacement patch coming soon.

---
Having all pagevecs in one array allows for easier flushing.  Use a
single flush function that decides what to do based on the target LRU.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
v2: Drop for_each_lru_pagevec()

 include/linux/pagevec.h |   10 +--
 mm/swap.c               |  121 +++++++++++++++++++++++-------------------------
 2 files changed, 63 insertions(+), 68 deletions(-)

--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -30,7 +30,7 @@ enum lru_pagevec {
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
-void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
+void __pagevec_flush(struct pagevec *pvec, enum lru_pagevec target);
 void pagevec_strip(struct pagevec *pvec);
 void pagevec_swap_free(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
@@ -90,22 +90,22 @@ static inline void pagevec_free(struct p
 
 static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
+	__pagevec_flush(pvec, LRU_INACTIVE_ANON);
 }
 
 static inline void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
+	__pagevec_flush(pvec, LRU_ACTIVE_ANON);
 }
 
 static inline void __pagevec_lru_add_file(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_INACTIVE_FILE);
+	__pagevec_flush(pvec, LRU_INACTIVE_FILE);
 }
 
 static inline void __pagevec_lru_add_active_file(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
+	__pagevec_flush(pvec, LRU_ACTIVE_FILE);
 }
 
 static inline void pagevec_lru_add_file(struct pagevec *pvec)
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -96,17 +96,44 @@ void put_pages_list(struct list_head *pa
 }
 EXPORT_SYMBOL(put_pages_list);
 
-/*
- * pagevec_move_tail() must be called with IRQ disabled.
- * Otherwise this may cause nasty races.
- */
-static void pagevec_move_tail(struct pagevec *pvec)
+static void pagevec_flush_add(struct zone *zone, struct page *page,
+			enum lru_list lru)
+{
+	VM_BUG_ON(is_unevictable_lru(lru));
+	VM_BUG_ON(PageActive(page));
+	VM_BUG_ON(PageUnevictable(page));
+	VM_BUG_ON(PageLRU(page));
+	SetPageLRU(page);
+	if (is_active_lru(lru))
+		SetPageActive(page);
+	add_page_to_lru_list(zone, page, lru);
+}
+
+static void pagevec_flush_rotate(struct zone *zone, struct page *page)
+{
+	int lru;
+
+	if (!PageLRU(page) || PageActive(page) || PageUnevictable(page))
+		return;
+	lru = page_is_file_cache(page);
+	list_move_tail(&page->lru, &zone->lru[lru].list);
+	__count_vm_event(PGROTATED);
+}
+
+static enum lru_pagevec target_mode(enum lru_pagevec target)
+{
+	if (target > PAGEVEC_ADD && target < PAGEVEC_ROTATE)
+		return PAGEVEC_ADD;
+	return target;
+}
+
+static void ____pagevec_flush(struct pagevec *pvec, enum lru_pagevec target)
 {
 	int i;
-	int pgmoved = 0;
 	struct zone *zone = NULL;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
+		enum lru_pagevec mode;
 		struct page *page = pvec->pages[i];
 		struct zone *pagezone = page_zone(page);
 
@@ -116,19 +143,33 @@ static void pagevec_move_tail(struct pag
 			zone = pagezone;
 			spin_lock(&zone->lru_lock);
 		}
-		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-			int lru = page_is_file_cache(page);
-			list_move_tail(&page->lru, &zone->lru[lru].list);
-			pgmoved++;
+
+		mode = target_mode(target);
+		switch (mode) {
+		case PAGEVEC_ADD:
+			pagevec_flush_add(zone, page, target);
+			break;
+		case PAGEVEC_ROTATE:
+			pagevec_flush_rotate(zone, page);
+			break;
+		default:
+			BUG();
 		}
 	}
 	if (zone)
 		spin_unlock(&zone->lru_lock);
-	__count_vm_events(PGROTATED, pgmoved);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
 
+void __pagevec_flush(struct pagevec *pvec, enum lru_pagevec target)
+{
+	local_irq_disable();
+	____pagevec_flush(pvec, target);
+	local_irq_enable();
+}
+EXPORT_SYMBOL(__pagevec_flush);
+
 /*
  * Writeback is about to end against a page which has been marked for immediate
  * reclaim.  If it still appears to be reclaimable, move it to the tail of the
@@ -145,7 +186,7 @@ void  rotate_reclaimable_page(struct pag
 		local_irq_save(flags);
 		pvec = &__get_cpu_var(lru_pvecs)[PAGEVEC_ROTATE];
 		if (!pagevec_add(pvec, page))
-			pagevec_move_tail(pvec);
+			____pagevec_flush(pvec, PAGEVEC_ROTATE);
 		local_irq_restore(flags);
 	}
 }
@@ -201,7 +242,7 @@ void __lru_cache_add(struct page *page, 
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		____pagevec_lru_add(pvec, lru);
+		__pagevec_flush(pvec, lru);
 	put_cpu_var(lru_pvecs);
 }
 
@@ -273,22 +314,12 @@ static void drain_cpu_pagevecs(int cpu)
 {
 	struct pagevec *pvecs = per_cpu(lru_pvecs, cpu);
 	struct pagevec *pvec;
-	int lru;
+	int pv;
 
-	for_each_lru(lru) {
-		pvec = &pvecs[PAGEVEC_ADD + lru];
+	for (pv = 0; pv < NR_LRU_PAGEVECS; pv++) {
+		pvec = &pvecs[pv];
 		if (pagevec_count(pvec))
-			____pagevec_lru_add(pvec, lru);
-	}
-
-	pvec = &pvecs[PAGEVEC_ROTATE];
-	if (pagevec_count(pvec)) {
-		unsigned long flags;
-
-		/* No harm done if a racing interrupt already did this */
-		local_irq_save(flags);
-		pagevec_move_tail(pvec);
-		local_irq_restore(flags);
+			__pagevec_flush(pvec, pv);
 	}
 }
 
@@ -432,42 +463,6 @@ void __pagevec_release_nonlru(struct pag
 }
 
 /*
- * Add the passed pages to the LRU, then drop the caller's refcount
- * on them.  Reinitialises the caller's pagevec.
- */
-void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
-{
-	int i;
-	struct zone *zone = NULL;
-	VM_BUG_ON(is_unevictable_lru(lru));
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(PageUnevictable(page));
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		if (is_active_lru(lru))
-			SetPageActive(page);
-		add_page_to_lru_list(zone, page, lru);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
-}
-
-EXPORT_SYMBOL(____pagevec_lru_add);
-
-/*
  * Try to drop buffers from the pages in a pagevec
  */
 void pagevec_strip(struct pagevec *pvec)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

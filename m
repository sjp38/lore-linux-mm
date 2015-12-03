Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E10226B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:58:54 -0500 (EST)
Received: by wmec201 with SMTP id c201so25789713wme.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:58:54 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id v189si3933889wmg.35.2015.12.03.06.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 06:58:53 -0800 (PST)
Received: by wmec201 with SMTP id c201so31033355wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:58:53 -0800 (PST)
Date: Thu, 3 Dec 2015 15:58:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151203145850.GH9264@dhcp22.suse.cz>
References: <20151201133455.GB27574@bbox>
 <20151202101643.GC25284@dhcp22.suse.cz>
 <20151203013404.GA30779@bbox>
 <20151203021006.GA31041@bbox>
 <20151203085451.GC9264@dhcp22.suse.cz>
 <20151203125950.GA1428@bbox>
 <20151203133719.GF9264@dhcp22.suse.cz>
 <20151203134326.GG9264@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203134326.GG9264@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-12-15 14:43:26, Michal Hocko wrote:
> On Thu 03-12-15 14:37:19, Michal Hocko wrote:
> > On Thu 03-12-15 21:59:50, Minchan Kim wrote:
> > > On Thu, Dec 03, 2015 at 09:54:52AM +0100, Michal Hocko wrote:
> > > > On Thu 03-12-15 11:10:06, Minchan Kim wrote:
> > > > > On Thu, Dec 03, 2015 at 10:34:04AM +0900, Minchan Kim wrote:
> > > > > > On Wed, Dec 02, 2015 at 11:16:43AM +0100, Michal Hocko wrote:
> > [...]
> > > > > > > Also, how big is the underflow?
> > > > [...]
> > > > > > nr_pages 293 new -324
> > > > > > nr_pages 16 new -340
> > > > > > nr_pages 342 new -91
> > > > > > nr_pages 246 new -337
> > > > > > nr_pages 15 new -352
> > > > > > nr_pages 15 new -367
> > > > 
> > > > They are quite large but that is not that surprising if we consider that
> > > > we are batching many uncharges at once.
> > > >  
> > > > > My guess is that it's related to new feature of Kirill's THP 'PageDoubleMap'
> > > > > so a THP page could be mapped a pte but !pmd_trans_huge(*pmd) so memcg
> > > > > precharge in move_charge should handle it?
> > > > 
> > > > I am not familiar with the current state of THP after the rework
> > > > unfortunately. So if I got you right then you are saying that
> > > > pmd_trans_huge_lock fails to notice a THP so we will not charge it as
> > > > THP and only charge one head page and then the tear down path will
> > > > correctly recognize it as a THP and uncharge the full size, right?
> > > 
> > > Exactly.
> > 
> > Hmm, but are pages represented by those ptes on the LRU list?
> > __split_huge_pmd_locked doesn't seem to do any lru care. If they are not
> > on any LRU then mem_cgroup_move_charge_pte_range should ignore such a pte
> > and the THP (which the pte is part of) should stay in the original
> > memcg.
> 
> Ohh, PageLRU is
> PAGEFLAG(LRU, lru, PF_HEAD)
> 
> So we are checking the head and it is on LRU. Now I can see how this
> might happen. Let me think about a fix...

Perhaps something like the following? I wouldn't be surprised if it
blown up magnificently. I am still pretty confused about all the
consequences of the thp rework so there are some open questions. I
also do not see isolate_lru_page can work properly. It doesn't seem
to operate on the head page but who knows maybe there is some other
trickery because this sounds like something to blow up from other places
as well. So I must be missing something here.

Warning, this looks ugly as hell.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 79a29d564bff..f5c3af0b74b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4501,7 +4501,6 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
- * @nr_pages: number of regular pages (>1 for huge pages)
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
  *
@@ -4509,30 +4508,43 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
  *
  * This function doesn't do "charge" to new cgroup and doesn't do "uncharge"
  * from old cgroup.
+ *
+ * Returns the number of moved pages.
  */
-static int mem_cgroup_move_account(struct page *page,
-				   bool compound,
+static unsigned mem_cgroup_move_account(struct page *page,
 				   struct mem_cgroup *from,
 				   struct mem_cgroup *to)
 {
 	unsigned long flags;
-	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
-	int ret;
+	bool compound = PageCompound(page);
+	unsigned nr_pages = 1;
+	unsigned ret = 0;
 	bool anon;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON(compound && !PageTransHuge(page));
+
+	if (compound) {
+		/*
+		 * We might see a split huge pmd and a tail page in a regular
+		 * pte. Make sure to work on the whole THP.
+		 *
+		 * TODO: what about pmd_trans_huge_lock for tail page mapped via
+		 * pte? That means we are already split up so we cannot race?
+		 * TODO: reference on the tail page will keep the head alive,
+		 * right?
+		 */
+		page = compound_head(page);
+		nr_pages = hpage_nr_pages(page);
+	}
 
 	/*
 	 * Prevent mem_cgroup_replace_page() from looking at
 	 * page->mem_cgroup of its source page while we change it.
 	 */
-	ret = -EBUSY;
 	if (!trylock_page(page))
 		goto out;
 
-	ret = -EINVAL;
 	if (page->mem_cgroup != from)
 		goto out_unlock;
 
@@ -4580,7 +4592,7 @@ static int mem_cgroup_move_account(struct page *page,
 	page->mem_cgroup = to;
 	spin_unlock_irqrestore(&from->move_lock, flags);
 
-	ret = 0;
+	ret = nr_pages;
 
 	local_irq_disable();
 	mem_cgroup_charge_statistics(to, page, compound, nr_pages);
@@ -4858,6 +4870,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	enum mc_target_type target_type;
 	union mc_target target;
 	struct page *page;
+	struct page *huge_page = NULL;
 
 	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		if (mc.precharge < HPAGE_PMD_NR) {
@@ -4868,11 +4881,12 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 		if (target_type == MC_TARGET_PAGE) {
 			page = target.page;
 			if (!isolate_lru_page(page)) {
-				if (!mem_cgroup_move_account(page, true,
-							     mc.from, mc.to)) {
-					mc.precharge -= HPAGE_PMD_NR;
-					mc.moved_charge += HPAGE_PMD_NR;
-				}
+				unsigned moved;
+
+				moved = mem_cgroup_move_account(page,
+							     mc.from, mc.to);
+				mc.precharge -= moved;
+				mc.moved_charge += moved;
 				putback_lru_page(page);
 			}
 			put_page(page);
@@ -4895,15 +4909,24 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 		switch (get_mctgt_type(vma, addr, ptent, &target)) {
 		case MC_TARGET_PAGE:
 			page = target.page;
-			if (isolate_lru_page(page))
+			/* We have already handled this THP */
+			if (compound_head(page) == huge_page)
 				goto put;
-			if (!mem_cgroup_move_account(page, false,
-						mc.from, mc.to)) {
-				mc.precharge--;
+
+			if (!isolate_lru_page(page)) {
+				unsigned move;
+
+				move = mem_cgroup_move_account(page,
+								mc.from, mc.to);
+				if (move > 1)
+					huge_page = compound_head(page);
+
+				mc.precharge -= move;
 				/* we uncharge from mc.from later. */
-				mc.moved_charge++;
+				mc.moved_charge += move;
+				/* LRU always operates on the head page */
+				putback_lru_page(compound_head(page));
 			}
-			putback_lru_page(page);
 put:			/* get_mctgt_type() gets the page */
 			put_page(page);
 			break;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4589cfdbe405..14b65949b7d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1430,9 +1430,12 @@ int isolate_lru_page(struct page *page)
 	VM_BUG_ON_PAGE(!page_count(page), page);
 
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
+		struct zone *zone;
 		struct lruvec *lruvec;
 
+		/* TODO: is this correct? */
+		page = compound_head(page);
+		zone = page_zone(page);
 		spin_lock_irq(&zone->lru_lock);
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 		if (PageLRU(page)) {
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

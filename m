Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 42E436B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 09:41:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l12so1375096wmh.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 06:41:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24sor3992573edn.8.2018.04.05.06.41.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 06:41:29 -0700 (PDT)
Date: Thu, 5 Apr 2018 16:40:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Message-ID: <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
References: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180403075928.GC5501@dhcp22.suse.cz>
 <20180403082405.GA23809@hori1.linux.bs1.fc.nec.co.jp>
 <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405124830.GJ6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Apr 05, 2018 at 02:48:30PM +0200, Michal Hocko wrote:
> On Thu 05-04-18 15:28:38, Kirill A. Shutemov wrote:
> > On Thu, Apr 05, 2018 at 10:59:27AM +0200, Michal Hocko wrote:
> > > On Tue 03-04-18 13:54:11, Kirill A. Shutemov wrote:
> > > > On Tue, Apr 03, 2018 at 10:34:51AM +0200, Michal Hocko wrote:
> > > > > On Tue 03-04-18 08:24:06, Naoya Horiguchi wrote:
> > > > > > On Tue, Apr 03, 2018 at 09:59:28AM +0200, Michal Hocko wrote:
> > > > > > > On Tue 03-04-18 13:46:28, Naoya Horiguchi wrote:
> > > > > > > > My testing for the latest kernel supporting thp migration found out an
> > > > > > > > infinite loop in offlining the memory block that is filled with shmem
> > > > > > > > thps.  We can get out of the loop with a signal, but kernel should
> > > > > > > > return with failure in this case.
> > > > > > > >
> > > > > > > > What happens in the loop is that scan_movable_pages() repeats returning
> > > > > > > > the same pfn without any progress. That's because page migration always
> > > > > > > > fails for shmem thps.
> > > > > > >
> > > > > > > Why does it fail? Shmem pages should be movable without any issues.
> > > > > > 
> > > > > > .. because try_to_unmap_one() explicitly skips unmapping for migration.
> > > > > > 
> > > > > >   #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> > > > > >                   /* PMD-mapped THP migration entry */
> > > > > >                   if (!pvmw.pte && (flags & TTU_MIGRATION)) {
> > > > > >                           VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
> > > > > >   
> > > > > >                           if (!PageAnon(page))
> > > > > >                                   continue;
> > > > > >   
> > > > > >                           set_pmd_migration_entry(&pvmw, page);
> > > > > >                           continue;
> > > > > >                   }
> > > > > >   #endif
> > > > > > 
> > > > > > When I implemented this code, I felt hard to work on both of anon thp
> > > > > > and shmem thp at one time, so I separated the proposal into smaller steps.
> > > > > > Shmem uses pagecache so we need some non-trivial effort (including testing)
> > > > > > to extend thp migration for shmem. But I think it's a reasonable next step.
> > > > > 
> > > > > OK, I see. I have forgot about this part. Please be explicit about that
> > > > > in the changelog. Also the proper fix is to not use movable zone for
> > > > > shmem page THP rather than hack around it in the hotplug specific code
> > > > > IMHO.
> > > > 
> > > > No. We should just split the page before running
> > > > try_to_unmap(TTU_MIGRATION) on the page.
> > > 
> > > Something like this or it is completely broken. I completely forgot the
> > > whole page_vma_mapped_walk business.
> > 
> > No, this wouldn't work. We need to split page, not pmd to make migration
> > work.
> 
> RIght, I confused the two. What is the proper layer to fix that then?
> rmap_walk_file?

Maybe something like this? Totally untested.

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a126259bc4..9da8fbd1eb6b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -359,4 +359,22 @@ static inline bool thp_migration_supported(void)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static inline bool PageTransHugeMigratable(struct page *page)
+{
+	return thp_migration_supported() &&
+		PageTransHuge(page) && PageAnon(page);
+}
+
+static inline bool PageTransMigratable(struct page *page)
+{
+	return thp_migration_supported() &&
+		PageTransCompound(page) && PageAnon(page);
+}
+
+static inline bool PageTransNonMigratable(struct page *page)
+{
+	return thp_migration_supported() &&
+		PageTransCompound(page) && !PageAnon(page);
+}
+
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a2246cf670ba..dd66dfe6d198 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -43,7 +43,7 @@ static inline struct page *new_page_nodemask(struct page *page,
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
 				preferred_nid, nodemask);
 
-	if (thp_migration_supported() && PageTransHuge(page)) {
+	if (PageTransHugeMigratable(page)) {
 		order = HPAGE_PMD_ORDER;
 		gfp_mask |= GFP_TRANSHUGE;
 	}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b2bd52ff7605..0672938abf44 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1381,9 +1381,10 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			if (isolate_huge_page(page, &source))
 				move_pages -= 1 << compound_order(head);
 			continue;
-		} else if (thp_migration_supported() && PageTransHuge(page))
+		} else if (PageTransHugeMigratable(page)) {
 			pfn = page_to_pfn(compound_head(page))
 				+ hpage_nr_pages(page) - 1;
+		}
 
 		if (!get_page_unless_zero(page))
 			continue;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 01cbb7078d6c..482e3f482f1b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -446,7 +446,7 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 		__split_huge_pmd(walk->vma, pmd, addr, false, NULL);
 		goto out;
 	}
-	if (!thp_migration_supported()) {
+	if (PageTransNonMigratable(page)) {
 		get_page(page);
 		spin_unlock(ptl);
 		lock_page(page);
@@ -511,7 +511,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 			continue;
 		if (!queue_pages_required(page, qp))
 			continue;
-		if (PageTransCompound(page) && !thp_migration_supported()) {
+		if (PageTransNonMigratable(page)) {
 			get_page(page);
 			pte_unmap_unlock(pte, ptl);
 			lock_page(page);
@@ -947,7 +947,7 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
-	else if (thp_migration_supported() && PageTransHuge(page)) {
+	else if (PageTransHugeMigratable(page)) {
 		struct page *thp;
 
 		thp = alloc_pages_node(node,
@@ -1123,7 +1123,7 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
 	if (PageHuge(page)) {
 		return alloc_huge_page_vma(page_hstate(compound_head(page)),
 				vma, address);
-	} else if (thp_migration_supported() && PageTransHuge(page)) {
+	} else if (PageTransHugeMigratable(page)) {
 		struct page *thp;
 
 		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
diff --git a/mm/migrate.c b/mm/migrate.c
index 003886606a22..6d654fecddde 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1470,7 +1470,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 	if (PageHuge(p))
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 					pm->node);
-	else if (thp_migration_supported() && PageTransHuge(p)) {
+	else if (PageTransHugeMigratable(p)) {
 		struct page *thp;
 
 		thp = alloc_pages_node(pm->node,
@@ -1537,6 +1537,14 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			 */
 			goto put_and_set;
 
+		if (PageTransNonMigratable(page)) {
+			lock_page(page);
+			err = split_huge_page(page);
+			unlock_page(page);
+			if (err)
+				goto put_and_set;
+		}
+
 		err = -EACCES;
 		if (page_mapcount(page) > 1 &&
 				!migrate_all)
-- 
 Kirill A. Shutemov

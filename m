Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9E56A6B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 06:58:39 -0500 (EST)
Date: Wed, 30 Jan 2013 11:58:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Rename page struct field helpers
Message-ID: <20130130115833.GB2964@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
 <1358874762-19717-6-git-send-email-mgorman@suse.de>
 <20130122144659.d512e05c.akpm@linux-foundation.org>
 <20130123142507.GI13304@suse.de>
 <20130123135612.4b383fa7.akpm@linux-foundation.org>
 <20130124105544.GO13304@suse.de>
 <alpine.LNX.2.00.1301282014560.27042@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301282014560.27042@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 28, 2013 at 08:39:35PM -0800, Hugh Dickins wrote:
> On Thu, 24 Jan 2013, Mel Gorman wrote:
> 
> > The function names page_xchg_last_nid(), page_last_nid() and
> > reset_page_last_nid() were judged to be inconsistent so rename them
> > to a struct_field_op style pattern. As it looked jarring to have
> > reset_page_mapcount() and page_nid_reset_last() beside each other in
> > memmap_init_zone(), this patch also renames reset_page_mapcount() to
> > page_mapcount_reset(). There are others like init_page_count() but as it
> > is used throughout the arch code a rename would likely cause more conflicts
> > than it is worth.
> > 
> > Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Sorry for not piping up in that earlier thread, but I don't understand
> Andrew's reasoning on this: it looks to me like unhelpful churn rather
> than improvement (and I suspect your heart is not in it either, Mel).
> 

My heart was not in it because I already recognised the original names.
I've been nailed before about poor naming particularly when I was already
familiar with the existing names.

> It's true that sometimes we name things object_verb() and sometimes we
> name things verb_object(), but we're always going to be inconsistent on
> that, and this patch does not change the fact: page_mapcount_reset()
> but set_page_private() (named by one akpm, I believe)?
> 

I half toyed with the idea of renaming all of them but it was going to
generate a lot of churn that would inevitably cause irritating patch
conflicts with little benefit.

> Being English, I really prefer verb_object(); but there are often
> subsystems or cfiles where object_verb() narrows the namespace more
> nicely.
> 
> xchg_page_last_nid() instead of page_xchg_last_nid(), to match
> reset_page_last_nid(): I think that would be a fine change.
> 
> page_nid_xchg_last() to exchange page->_last_nid?  You jest, sir!
> 

page_nid_last also looked odd to me. page_nid_xchg_last() looked vaguely
similar to page_to_nid() and maybe that was the intent.  However, I also
found it a little misleading because the nids are completely different --
one nid is where the page resides and the other nid is related to what
CPU referenced the page during the last numa hinting fault.

Your suggestion is to always have a verb_struct_field pattern which
page_xchg_last_nid violates. That patch would look like the following.
Andrew?

---8<---
mm: Rename page_xchg_last_nid

Andrew found the functions names page_xchg_last_nid(), page_last_nid()
and reset_page_last_nid() to be inconsistent and were renamed
to page_nid_xchg_last(), page_nid_last() and page_nid_reset_last().
Hugh found this unhelpful and suggested a rename of page_xchg_last_nid to
keep with a verb_struct_field naming pattern.

This patch replaces mm-rename-page-struct-field-helpers.patch.

Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h |    6 +++---
 mm/huge_memory.c   |    2 +-
 mm/mempolicy.c     |    2 +-
 mm/migrate.c       |    4 ++--
 mm/mmzone.c        |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6e4468f..6356db0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -657,7 +657,7 @@ static inline int page_to_nid(const struct page *page)
 
 #ifdef CONFIG_NUMA_BALANCING
 #ifdef LAST_NID_NOT_IN_PAGE_FLAGS
-static inline int page_xchg_last_nid(struct page *page, int nid)
+static inline int xchg_page_last_nid(struct page *page, int nid)
 {
 	return xchg(&page->_last_nid, nid);
 }
@@ -676,7 +676,7 @@ static inline int page_last_nid(struct page *page)
 	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
 }
 
-extern int page_xchg_last_nid(struct page *page, int nid);
+extern int xchg_page_last_nid(struct page *page, int nid);
 
 static inline void reset_page_last_nid(struct page *page)
 {
@@ -687,7 +687,7 @@ static inline void reset_page_last_nid(struct page *page)
 }
 #endif /* LAST_NID_NOT_IN_PAGE_FLAGS */
 #else
-static inline int page_xchg_last_nid(struct page *page, int nid)
+static inline int xchg_page_last_nid(struct page *page, int nid)
 {
 	return page_to_nid(page);
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 648c102..ed97040 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1642,7 +1642,7 @@ static void __split_huge_page_refcount(struct page *page)
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
-		page_xchg_last_nid(page_tail, page_last_nid(page));
+		xchg_page_last_nid(page_tail, page_last_nid(page));
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e2df1c1..61226db 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2308,7 +2308,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * it less likely we act on an unlikely task<->page
 		 * relation.
 		 */
-		last_nid = page_xchg_last_nid(page, polnid);
+		last_nid = xchg_page_last_nid(page, polnid);
 		if (last_nid != polnid)
 			goto out;
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index 8ef1cbf..4d9b724 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1495,7 +1495,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					  __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
 	if (newpage)
-		page_xchg_last_nid(newpage, page_last_nid(page));
+		xchg_page_last_nid(newpage, page_last_nid(page));
 
 	return newpage;
 }
@@ -1679,7 +1679,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (!new_page)
 		goto out_fail;
 
-	page_xchg_last_nid(new_page, page_last_nid(page));
+	xchg_page_last_nid(new_page, page_last_nid(page));
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/mmzone.c b/mm/mmzone.c
index bce796e..de2a951 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -98,7 +98,7 @@ void lruvec_init(struct lruvec *lruvec)
 }
 
 #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NID_NOT_IN_PAGE_FLAGS)
-int page_xchg_last_nid(struct page *page, int nid)
+int xchg_page_last_nid(struct page *page, int nid)
 {
 	unsigned long old_flags, flags;
 	int last_nid;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

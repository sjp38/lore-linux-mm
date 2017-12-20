Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9176B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:53:33 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z1so16217924pfl.9
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:53:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si12923797pfj.82.2017.12.20.01.53.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 01:53:31 -0800 (PST)
Date: Wed, 20 Dec 2017 10:53:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
Message-ID: <20171220095328.GG4831@dhcp22.suse.cz>
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171215093309.GU16951@dhcp22.suse.cz>
 <95ba8db3-f8aa-528a-db4b-80f9d2ba9d2b@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <95ba8db3-f8aa-528a-db4b-80f9d2ba9d2b@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-12-17 05:33:36, Naoya Horiguchi wrote:
> 
> On 12/15/2017 06:33 PM, Michal Hocko wrote:
> > Naoya,
> > this has passed Mike's review (thanks for that!), you have mentioned
> > that you can pass this through your testing machinery earlier. While
> > I've done some testing already I would really appreciate if you could
> > do that as well. Review would be highly appreciated as well.
> 
> Sorry for my slow response. I reviewed/tested this patchset and looks
> good to me overall.

No need to feel sorry. This doesn't have an urgent priority. Thanks for
the review and testing. Can I assume your {Reviewed,Acked}-by or
Tested-by?

> I have one comment on the code path from mbind(2).
> The callback passed to migrate_pages() in do_mbind() (i.e. new_page())
> calls alloc_huge_page_noerr() which currently doesn't call SetPageHugeTemporary(),
> so hugetlb migration fails when h->surplus_huge_page >= h->nr_overcommit_huge_pages.

Yes, I am aware of that. I should have been more explicit in the
changelog. Sorry about that and thanks for pointing it out explicitly.
To be honest I wasn't really sure what to do about this. The code path
is really complex and it made my head spin. I fail to see why we have to
call alloc_huge_page and mess with reservations at all.

> I don't think this is a bug, but it would be better if mbind(2) works
> more similarly with other migration callers like move_pages(2)/migrate_pages(2).

If the fix is as easy as the following I will add it to the pile.
Otherwise I would prefer to do this separately after I find some more
time to understand the callpath.
---
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index e035002d3fb6..08a4af411e25 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -345,10 +345,9 @@ struct huge_bootmem_page {
 struct page *alloc_huge_page(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
-struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
-				unsigned long addr, int avoid_reserve);
 struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 				nodemask_t *nmask);
+struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address);
 int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
@@ -526,7 +525,7 @@ struct hstate {};
 #define alloc_huge_page(v, a, r) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
-#define alloc_huge_page_noerr(v, a, r) NULL
+#define alloc_huge_page_vma(vma, address) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
 #define hstate_sizelog(s) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4426c5b23a20..e00deabe6d17 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1672,6 +1672,25 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 	return alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
 }
 
+/* mempolicy aware migration callback */
+struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address)
+{
+	struct mempolicy *mpol;
+	nodemask_t *nodemask;
+	struct page *page;
+	struct hstate *h;
+	gfp_t gfp_mask;
+	int node;
+
+	h = hstate_vma(vma);
+	gfp_mask = htlb_alloc_mask(h);
+	node = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
+	page = alloc_huge_page_nodemask(h, node, nodemask);
+	mpol_cond_put(mpol);
+
+	return page;
+}
+
 /*
  * Increase the hugetlb pool such that it can accommodate a reservation
  * of size 'delta'.
@@ -2077,20 +2096,6 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	return ERR_PTR(-ENOSPC);
 }
 
-/*
- * alloc_huge_page()'s wrapper which simply returns the page if allocation
- * succeeds, otherwise NULL. This function is called from new_vma_page(),
- * where no ERR_VALUE is expected to be returned.
- */
-struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
-				unsigned long addr, int avoid_reserve)
-{
-	struct page *page = alloc_huge_page(vma, addr, avoid_reserve);
-	if (IS_ERR(page))
-		page = NULL;
-	return page;
-}
-
 int alloc_bootmem_huge_page(struct hstate *h)
 	__attribute__ ((weak, alias("__alloc_bootmem_huge_page")));
 int __alloc_bootmem_huge_page(struct hstate *h)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f604b22ebb65..96823fa07f38 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1121,8 +1121,7 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
 	}
 
 	if (PageHuge(page)) {
-		BUG_ON(!vma);
-		return alloc_huge_page_noerr(vma, address, 1);
+		return alloc_huge_page_vma(vma, address);
 	} else if (thp_migration_supported() && PageTransHuge(page)) {
 		struct page *thp;
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

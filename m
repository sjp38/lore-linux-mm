Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCF96B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 05:22:13 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so5610315lbn.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 02:22:13 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id wz10si2927931wjc.158.2016.05.24.02.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 02:22:04 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 67so4176362wmg.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 02:22:04 -0700 (PDT)
Date: Tue, 24 May 2016 11:22:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160524092202.GD8259@dhcp22.suse.cz>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160523174441.GA32715@dhcp22.suse.cz>
 <20160524084319.GH7917@esperanza>
 <20160524084737.GC8259@dhcp22.suse.cz>
 <20160524090142.GI7917@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524090142.GI7917@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-05-16 12:01:42, Vladimir Davydov wrote:
> On Tue, May 24, 2016 at 10:47:37AM +0200, Michal Hocko wrote:
> > On Tue 24-05-16 11:43:19, Vladimir Davydov wrote:
> > > On Mon, May 23, 2016 at 07:44:43PM +0200, Michal Hocko wrote:
> > > > On Mon 23-05-16 19:02:10, Vladimir Davydov wrote:
> > > > > mem_cgroup_oom may be invoked multiple times while a process is handling
> > > > > a page fault, in which case current->memcg_in_oom will be overwritten
> > > > > leaking the previously taken css reference.
> > > > 
> > > > Have you seen this happening? I was under impression that the page fault
> > > > paths that have oom enabled will not retry allocations.
> > > 
> > > filemap_fault will, for readahead.
> > 
> > I thought that the readahead is __GFP_NORETRY so we do not trigger OOM
> > killer.
> 
> Hmm, interesting. We do allocate readahead pages with __GFP_NORETRY, but
> we add them to page cache and hence charge with GFP_KERNEL or GFP_NOFS
> mask, see __do_page_cache_readahaed -> read_pages.

I guess we do not want to trigger OOM just because of readahead. What do
you think about the following? I will cook up a full patch if this
(untested) looks ok.
---
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 97354102794d..81363b834900 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -209,10 +209,10 @@ static inline struct page *page_cache_alloc_cold(struct address_space *x)
 	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
 }
 
-static inline struct page *page_cache_alloc_readahead(struct address_space *x)
+static inline gfp_t readahead_gfp_mask(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x) |
-				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
+	return mapping_gfp_mask(x) |
+				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN;
 }
 
 typedef int filler_t(void *, struct page *);
diff --git a/mm/readahead.c b/mm/readahead.c
index 40be3ae0afe3..7431fefe4ede 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -108,7 +108,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 EXPORT_SYMBOL(read_cache_pages);
 
 static int read_pages(struct address_space *mapping, struct file *filp,
-		struct list_head *pages, unsigned nr_pages)
+		struct list_head *pages, unsigned nr_pages, gfp_t gfp_mask)
 {
 	struct blk_plug plug;
 	unsigned page_idx;
@@ -126,8 +126,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = lru_to_page(pages);
 		list_del(&page->lru);
-		if (!add_to_page_cache_lru(page, mapping, page->index,
-				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
+		if (!add_to_page_cache_lru(page, mapping, page->index, gfp_mask)) {
 			mapping->a_ops->readpage(filp, page);
 		}
 		put_page(page);
@@ -159,6 +158,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	int page_idx;
 	int ret = 0;
 	loff_t isize = i_size_read(inode);
+	gfp_t gfp_mask = readahead_gfp_mask(mapping);
 
 	if (isize == 0)
 		goto out;
@@ -180,7 +180,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (page && !radix_tree_exceptional_entry(page))
 			continue;
 
-		page = page_cache_alloc_readahead(mapping);
+		page = __page_cache_alloc(gfp_mask);
 		if (!page)
 			break;
 		page->index = page_offset;
@@ -196,7 +196,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	 * will then handle the error.
 	 */
 	if (ret)
-		read_pages(mapping, filp, &page_pool, ret);
+		read_pages(mapping, filp, &page_pool, ret, gfp_mask);
 	BUG_ON(!list_empty(&page_pool));
 out:
 	return ret;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

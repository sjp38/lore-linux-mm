Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA643C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4026F222E5
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Tj4QAZ7/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4026F222E5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6DD78E0002; Fri, 15 Feb 2019 17:25:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1E9A8E0001; Fri, 15 Feb 2019 17:25:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BF628E0002; Fri, 15 Feb 2019 17:25:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7858E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:25:31 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y1so7800711pgo.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:25:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=4Gp3bQShK9aP2AM3VG2hKKx2Up4d2goE9hEe/0W7+Z4=;
        b=GL3c+Mi10dhaOakeebgGLuvZmJVeF23D/tjBLSmZ6S/e6gQQM7kd66/tFHThY/Sh+W
         xVx6518DahZqLso2XPltaBi2IxT8iXZOubTh6dUqZVa7RD8YAgdBV8FUOnatZ87Mg4b5
         Q6pCak3q+EANHZ3Dre5Cyj7U2V73TFAyCXnbWIJuFHMd4ipDUoBiYreoDMy/D47mRTht
         Fkhfm//PbARVYVLQF3L8Y/cubJ1Mj1wjQLAP0kI4b8H4+Xy3KIogkIFvR6iS938EvTZR
         tnmVp6XRRqGXgw93njyD2a+kMrD8u7CEIg3B8TvFuF0fAoi/EQPj6DC8uHC7p/IQZ6O5
         enlw==
X-Gm-Message-State: AHQUAuYE3Jm+g/dzPjb70L0+cp7lSt7j/G0TaZM4tsD7/3QDQouk8qK9
	BKJcXg+oB/ttkUVZoo03ZEJEOKqkdEuYuuGOJuwPfwu80WC6qHAgRKXLBqoTrSBm+Zfwb3MRNDn
	oD3L7rAaxflfslJ5DKxsSMROqJIdKLNVBxH8lU/zC48KEtpwsilcED6SfyXMGbpQBrg==
X-Received: by 2002:a63:bd51:: with SMTP id d17mr7579603pgp.443.1550269530918;
        Fri, 15 Feb 2019 14:25:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZcI9Hgt8Cyi+BVp84y8Cz40dEC6R/TQ5ftrsRDqcbAqhAyuK47q3d88vt4B3r+G8NiE73A
X-Received: by 2002:a63:bd51:: with SMTP id d17mr7579495pgp.443.1550269529210;
        Fri, 15 Feb 2019 14:25:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550269529; cv=none;
        d=google.com; s=arc-20160816;
        b=EV0drq3uP+ciWa6id4PasY0EfsQT0+sdadGeFq8ssCrg4l9j5PX1tZC9biqUo0nGy7
         AFS+yoCB1WYwgsgkLtTWzE/6cZXjPr6AgB4rA6W0UEej8xTYJerErwZU1zB1HYrV/ACQ
         YnYsUFU6DVx/7+6Yfbqr1eo8/ApIisjUTLJY0x7tQQ529JOjHPW1tMUw7f6i0y6O8BCM
         h8vcIDBpS4t6Unv7ae3Lt0bkXvGgvQ2A8Q1RpEzH1C93M7mVSw76PyX4oHypwRoDtT4n
         xG8Q0G7SSFkpCoFuAi25gbu7DZPW3kDX1PNm2U+Be/AxDDbcPhRlRJpxRDKf3SUa1Ftd
         QCUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=4Gp3bQShK9aP2AM3VG2hKKx2Up4d2goE9hEe/0W7+Z4=;
        b=JO54WCAarB2pdBCnpGAHCVWB0nKf2/3Q+5rh8KZ7rmv8+r0gBf5FcbyhTBCtIz+YXM
         kzAtFFHXW92ZO7KApXgVLLqFl2iKpGCdS2uwiwG0bI/jdbZKg/kxty7Zo9TO5VTPxdQa
         wHyFDoyFp3R6Y+VIJ+z+PXhwmCS8tEa7piUuQqzNrxskT19gFdA4sm+2EokuIR6MY+3S
         gf3jNf6NYaeOEi4y5BK13oRNf+vbFTk9/HD45hhdWlj2KB+kOLc1S9daRGUZbG8PiZGJ
         ALsDridb/8OKftyeds2MvfuZSuwysuFbtH+j4QJSoy92ydLLmf7duuaBCKsjBNVE2cBM
         d6BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Tj4QAZ7/";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h4si6188234pgl.409.2019.02.15.14.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 14:25:29 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Tj4QAZ7/";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Message-Id:Date:Subject:Cc:To:From:
	Sender:Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=4Gp3bQShK9aP2AM3VG2hKKx2Up4d2goE9hEe/0W7+Z4=; b=Tj4QAZ7/lBXKK3YTkdcEj5Y4C
	q/XIctdkj7rP+bW/JnBq8GItUHdu8/J4fwgNkDD2WN5U69R0qb/uzL98jMD3D46+y9JWBaFaa4Zvf
	yKP1vAeDhd0Vzm1kxrdbhsaOEj8AZUkW9IImp9pHhQ2K5cfWGPy1EoawLUMgYgyxhFCMN0Q4Z09yX
	ApcQJpg4fhYpcCO9Un46KejQ2ksfb/W8NX6fFj5Pq+4iupQOcCtLE3IDwWGzdsoAiqJmstAqGd7no
	11bSlKgQMvhobOhR6r2koHMwU/p/zHYPmcbojpCRR7VdbtJBUPvS9YFixd5br0H28+0+B2D5NGWIe
	JswBiBUkw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gulvD-0004eK-Uo; Fri, 15 Feb 2019 22:25:27 +0000
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>,
	Hugh Dickins <hughd@google.com>,
	Jan Kara <jack@suse.cz>,
	William Kucharski <william.kucharski@oracle.com>
Subject: [PATCH v3] page cache: Store only head pages in i_pages
Date: Fri, 15 Feb 2019 14:25:25 -0800
Message-Id: <20190215222525.17802-1-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Transparent Huge Pages are currently stored in i_pages as pointers to
consecutive subpages.  This patch changes that to storing consecutive
pointers to the head page in preparation for storing huge pages more
efficiently in i_pages.

Large parts of this are "inspired" by Kirill's patch
https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/

Signed-off-by: Matthew Wilcox <willy@infradead.org>
Acked-by: Jan Kara <jack@suse.cz>
Reviewed-by: Kirill Shutemov <kirill@shutemov.name>
---
 include/linux/pagemap.h |   9 +++
 mm/filemap.c            | 158 ++++++++++++++++------------------------
 mm/huge_memory.c        |   3 +
 mm/khugepaged.c         |   4 +-
 mm/memfd.c              |   2 +
 mm/migrate.c            |   2 +-
 mm/shmem.c              |   2 +-
 mm/swap_state.c         |   4 +-
 8 files changed, 81 insertions(+), 103 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index bcf909d0de5f..7d58e4e0b68e 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -333,6 +333,15 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 			mapping_gfp_mask(mapping));
 }
 
+static inline struct page *find_subpage(struct page *page, pgoff_t offset)
+{
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON_PAGE(page->index > offset, page);
+	VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
+			page);
+	return page - page->index + offset;
+}
+
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
 unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
diff --git a/mm/filemap.c b/mm/filemap.c
index 5673672fd444..d9161cae11b5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -279,11 +279,11 @@ EXPORT_SYMBOL(delete_from_page_cache);
  * @pvec: pagevec with pages to delete
  *
  * The function walks over mapping->i_pages and removes pages passed in @pvec
- * from the mapping. The function expects @pvec to be sorted by page index.
+ * from the mapping. The function expects @pvec to be sorted by page index
+ * and is optimised for it to be dense.
  * It tolerates holes in @pvec (mapping entries at those indices are not
  * modified). The function expects only THP head pages to be present in the
- * @pvec and takes care to delete all corresponding tail pages from the
- * mapping as well.
+ * @pvec.
  *
  * The function expects the i_pages lock to be held.
  */
@@ -292,40 +292,43 @@ static void page_cache_delete_batch(struct address_space *mapping,
 {
 	XA_STATE(xas, &mapping->i_pages, pvec->pages[0]->index);
 	int total_pages = 0;
-	int i = 0, tail_pages = 0;
+	int i = 0;
 	struct page *page;
 
 	mapping_set_update(&xas, mapping);
 	xas_for_each(&xas, page, ULONG_MAX) {
-		if (i >= pagevec_count(pvec) && !tail_pages)
+		if (i >= pagevec_count(pvec))
 			break;
+
+		/* A swap/dax/shadow entry got inserted? Skip it. */
 		if (xa_is_value(page))
 			continue;
-		if (!tail_pages) {
-			/*
-			 * Some page got inserted in our range? Skip it. We
-			 * have our pages locked so they are protected from
-			 * being removed.
-			 */
-			if (page != pvec->pages[i]) {
-				VM_BUG_ON_PAGE(page->index >
-						pvec->pages[i]->index, page);
-				continue;
-			}
-			WARN_ON_ONCE(!PageLocked(page));
-			if (PageTransHuge(page) && !PageHuge(page))
-				tail_pages = HPAGE_PMD_NR - 1;
+		/*
+		 * A page got inserted in our range? Skip it. We have our
+		 * pages locked so they are protected from being removed.
+		 * If we see a page whose index is higher than ours, it
+		 * means our page has been removed, which shouldn't be
+		 * possible because we're holding the PageLock.
+		 */
+		if (page != pvec->pages[i]) {
+			VM_BUG_ON_PAGE(page->index > pvec->pages[i]->index,
+					page);
+			continue;
+		}
+
+		WARN_ON_ONCE(!PageLocked(page));
+
+		if (page->index == xas.xa_index)
 			page->mapping = NULL;
-			/*
-			 * Leave page->index set: truncation lookup relies
-			 * upon it
-			 */
+		/* Leave page->index set: truncation lookup relies on it */
+
+		/*
+		 * Move to the next page in the vector if this is a small page
+		 * or the index is of the last page in this compound page).
+		 */
+		if (page->index + (1UL << compound_order(page)) - 1 ==
+				xas.xa_index)
 			i++;
-		} else {
-			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
-					!= pvec->pages[i]->index, page);
-			tail_pages--;
-		}
 		xas_store(&xas, NULL);
 		total_pages++;
 	}
@@ -1491,7 +1494,7 @@ EXPORT_SYMBOL(page_cache_prev_miss);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	XA_STATE(xas, &mapping->i_pages, offset);
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 repeat:
@@ -1506,25 +1509,19 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 	if (!page || xa_is_value(page))
 		goto out;
 
-	head = compound_head(page);
-	if (!page_cache_get_speculative(head))
+	if (!page_cache_get_speculative(page))
 		goto repeat;
 
-	/* The page was split under us? */
-	if (compound_head(page) != head) {
-		put_page(head);
-		goto repeat;
-	}
-
 	/*
-	 * Has the page moved?
+	 * Has the page moved or been split?
 	 * This is part of the lockless pagecache protocol. See
 	 * include/linux/pagemap.h for details.
 	 */
 	if (unlikely(page != xas_reload(&xas))) {
-		put_page(head);
+		put_page(page);
 		goto repeat;
 	}
+	page = find_subpage(page, offset);
 out:
 	rcu_read_unlock();
 
@@ -1706,7 +1703,6 @@ unsigned find_get_entries(struct address_space *mapping,
 
 	rcu_read_lock();
 	xas_for_each(&xas, page, ULONG_MAX) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1717,17 +1713,13 @@ unsigned find_get_entries(struct address_space *mapping,
 		if (xa_is_value(page))
 			goto export;
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto retry;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head)
-			goto put_page;
-
-		/* Has the page moved? */
+		/* Has the page moved or been split? */
 		if (unlikely(page != xas_reload(&xas)))
 			goto put_page;
+		page = find_subpage(page, xas.xa_index);
 
 export:
 		indices[ret] = xas.xa_index;
@@ -1736,7 +1728,7 @@ unsigned find_get_entries(struct address_space *mapping,
 			break;
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -1778,33 +1770,27 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 
 	rcu_read_lock();
 	xas_for_each(&xas, page, end) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/* Skip over shadow, swap and DAX entries */
 		if (xa_is_value(page))
 			continue;
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto retry;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head)
-			goto put_page;
-
-		/* Has the page moved? */
+		/* Has the page moved or been split? */
 		if (unlikely(page != xas_reload(&xas)))
 			goto put_page;
 
-		pages[ret] = page;
+		pages[ret] = find_subpage(page, xas.xa_index);
 		if (++ret == nr_pages) {
 			*start = page->index + 1;
 			goto out;
 		}
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -1849,7 +1835,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 
 	rcu_read_lock();
 	for (page = xas_load(&xas); page; page = xas_next(&xas)) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1859,24 +1844,19 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 		if (xa_is_value(page))
 			break;
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto retry;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head)
-			goto put_page;
-
-		/* Has the page moved? */
+		/* Has the page moved or been split? */
 		if (unlikely(page != xas_reload(&xas)))
 			goto put_page;
 
-		pages[ret] = page;
+		pages[ret] = find_subpage(page, xas.xa_index);
 		if (++ret == nr_pages)
 			break;
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -1912,7 +1892,6 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 
 	rcu_read_lock();
 	xas_for_each_marked(&xas, page, end, tag) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1923,26 +1902,21 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 		if (xa_is_value(page))
 			continue;
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto retry;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head)
-			goto put_page;
-
-		/* Has the page moved? */
+		/* Has the page moved or been split? */
 		if (unlikely(page != xas_reload(&xas)))
 			goto put_page;
 
-		pages[ret] = page;
+		pages[ret] = find_subpage(page, xas.xa_index);
 		if (++ret == nr_pages) {
 			*index = page->index + 1;
 			goto out;
 		}
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -1991,7 +1965,6 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 
 	rcu_read_lock();
 	xas_for_each_marked(&xas, page, ULONG_MAX, tag) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -2002,17 +1975,13 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 		if (xa_is_value(page))
 			goto export;
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto retry;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head)
-			goto put_page;
-
-		/* Has the page moved? */
+		/* Has the page moved or been split? */
 		if (unlikely(page != xas_reload(&xas)))
 			goto put_page;
+		page = find_subpage(page, xas.xa_index);
 
 export:
 		indices[ret] = xas.xa_index;
@@ -2021,7 +1990,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 			break;
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -2686,7 +2655,7 @@ void filemap_map_pages(struct vm_fault *vmf,
 	pgoff_t last_pgoff = start_pgoff;
 	unsigned long max_idx;
 	XA_STATE(xas, &mapping->i_pages, start_pgoff);
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 	xas_for_each(&xas, page, end_pgoff) {
@@ -2695,24 +2664,19 @@ void filemap_map_pages(struct vm_fault *vmf,
 		if (xa_is_value(page))
 			goto next;
 
-		head = compound_head(page);
-
 		/*
 		 * Check for a locked page first, as a speculative
 		 * reference may adversely influence page migration.
 		 */
-		if (PageLocked(head))
+		if (PageLocked(page))
 			goto next;
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto next;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head)
-			goto skip;
-
-		/* Has the page moved? */
+		/* Has the page moved or been split? */
 		if (unlikely(page != xas_reload(&xas)))
 			goto skip;
+		page = find_subpage(page, xas.xa_index);
 
 		if (!PageUptodate(page) ||
 				PageReadahead(page) ||
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d4847026d4b1..7008174c033b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2458,6 +2458,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 			if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
 				shmem_uncharge(head->mapping->host, 1);
 			put_page(head + i);
+		} else if (!PageAnon(page)) {
+			__xa_store(&head->mapping->i_pages, head[i].index,
+					head + i, 0);
 		}
 	}
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 449044378782..7ba7a1e4fa79 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1374,7 +1374,7 @@ static void collapse_shmem(struct mm_struct *mm,
 				result = SCAN_FAIL;
 				goto xa_locked;
 			}
-			xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
+			xas_store(&xas, new_page);
 			nr_none++;
 			continue;
 		}
@@ -1450,7 +1450,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		list_add_tail(&page->lru, &pagelist);
 
 		/* Finally, replace with the new page. */
-		xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
+		xas_store(&xas, new_page);
 		continue;
 out_unlock:
 		unlock_page(page);
diff --git a/mm/memfd.c b/mm/memfd.c
index 650e65a46b9c..bccbf7dff050 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -39,6 +39,7 @@ static void memfd_tag_pins(struct xa_state *xas)
 	xas_for_each(xas, page, ULONG_MAX) {
 		if (xa_is_value(page))
 			continue;
+		page = find_subpage(page, xas.xa_index);
 		if (page_count(page) - page_mapcount(page) > 1)
 			xas_set_mark(xas, MEMFD_TAG_PINNED);
 
@@ -88,6 +89,7 @@ static int memfd_wait_for_pins(struct address_space *mapping)
 			bool clear = true;
 			if (xa_is_value(page))
 				continue;
+			page = find_subpage(page, xas.xa_index);
 			if (page_count(page) - page_mapcount(page) != 1) {
 				/*
 				 * On the last scan, we clean up all those tags
diff --git a/mm/migrate.c b/mm/migrate.c
index 412d5fff78d4..8cb55dd69b9c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -465,7 +465,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 
 		for (i = 1; i < HPAGE_PMD_NR; i++) {
 			xas_next(&xas);
-			xas_store(&xas, newpage + i);
+			xas_store(&xas, newpage);
 		}
 	}
 
diff --git a/mm/shmem.c b/mm/shmem.c
index c8cdaa012f18..a78d4f05a51f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -614,7 +614,7 @@ static int shmem_add_to_page_cache(struct page *page,
 		if (xas_error(&xas))
 			goto unlock;
 next:
-		xas_store(&xas, page + i);
+		xas_store(&xas, page);
 		if (++i < nr) {
 			xas_next(&xas);
 			goto next;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 85245fdec8d9..eb714165afd2 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -132,7 +132,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
 		for (i = 0; i < nr; i++) {
 			VM_BUG_ON_PAGE(xas.xa_index != idx + i, page);
 			set_page_private(page + i, entry.val + i);
-			xas_store(&xas, page + i);
+			xas_store(&xas, page);
 			xas_next(&xas);
 		}
 		address_space->nrpages += nr;
@@ -167,7 +167,7 @@ void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
 
 	for (i = 0; i < nr; i++) {
 		void *entry = xas_store(&xas, NULL);
-		VM_BUG_ON_PAGE(entry != page + i, entry);
+		VM_BUG_ON_PAGE(entry != page, entry);
 		set_page_private(page + i, 0);
 		xas_next(&xas);
 	}
-- 
2.20.1


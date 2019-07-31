Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81FAFC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 21:04:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 307CC2064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 21:04:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DF4/A1qV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 307CC2064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB4868E0005; Wed, 31 Jul 2019 17:04:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3DF18E0001; Wed, 31 Jul 2019 17:04:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DF1C8E0005; Wed, 31 Jul 2019 17:04:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61B588E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 17:04:10 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i134so6400296pgd.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 14:04:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ELnCJmHftki0TjR5pLeFRv3ZGO3vLpNPRssAISIykdc=;
        b=Zs5tBY1Pu4l2tfRZS3jkoO97k95eHHMrdfHDUWSNaQGWZ5XJ9R0RkydTB2FWBCQq3T
         h8zFh+HY62WtuySGtVLX/KlABoVjAsO+0fFiGLw+ZtYpZSvzpNSiy1ry9D1FXazgTaFA
         zTz+3JOpYXAw8ldO00yV4CydOoiPeRGycb7AyW4e9fz4o6agv+2dB1wrZDDJqAqVbemT
         hDK35/UHLfd1hWbzYFE1MNrcMDUazjgABTik7eSeWsQFt83PCKcYdW5CBZBAa0SKU7LC
         X0qDYjQDvOTXpEJqF6dEWkKntEur0BfsAhyt9pzlPe9mS/PuiCZjz0trQvCuUkGpKaJH
         M7aQ==
X-Gm-Message-State: APjAAAXS/0Huq6fxX9C9+83rPEYa2LHoww/sjd7PVudCt3B9ZD2a5xNr
	X0clTMvKFAO6eUUmpzbxarH5AGIG4T5EfobqrQC1bZRMePzKlnnUG275cflVe1oKJIOtdcrFPqA
	M9OTcnyP4V1RvHwX6db3VQOaLxqmpmJuenBBQ/m5k5/eXBdNHGpGTmf9fCsFpRl3RZA==
X-Received: by 2002:a17:902:2ae8:: with SMTP id j95mr112367310plb.276.1564607049837;
        Wed, 31 Jul 2019 14:04:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4vupEtalHrY/i+4Xba+e+kuVWaaJVmLubscPMAMlFJazyIPd02UeD+JpmqjwZNvGyS0hQ
X-Received: by 2002:a17:902:2ae8:: with SMTP id j95mr112367219plb.276.1564607048467;
        Wed, 31 Jul 2019 14:04:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564607048; cv=none;
        d=google.com; s=arc-20160816;
        b=brdOy0OFaEAFaDo75LdcdG6AU+s5UBXWc+lQjs6vqtJ/IMMisFTz6CvJQIKXf8lYjb
         QKrGF3IZMYaXRub2D1RMN0JxqLiosZpy6wfWzC4PRvhrZjUG+Fz79hzhQrHnlik3N+tr
         uUbEOrMkgaJ+gluUlp+JrlpWL9qaQI9kHXqah1K6kPDt6Nk+xrECVsumKN6vqpWVMEai
         uP5eFprPwEC6ZHjhOIepGLyLCJMCY+3EOZu4rR0/o4uD+hftHzQeCSiIpUzKVT8H7ppZ
         U+NZaztIlYH9xvAPfMYIXwUKXgGQ+ANjdNjr5ETB/CHdVx6MamvU4q9BJWQ+DpYn/J2Z
         iExA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ELnCJmHftki0TjR5pLeFRv3ZGO3vLpNPRssAISIykdc=;
        b=c5aBraA8HUdq+Z1VLgvtCz945mW2bDl6i6kTXn9r0Z0l7oSx6lXH9/noUkdHp+ubIM
         r0MtlAA0OEDXkS48+Tghv7AeucJbnnE45ja3OlaG/uw5ojItNX8ZrNssmHsLJyFnL0+J
         JhGUbakkySVg9GXbFm75qBoJaQJaOAORJ/kFnOS2vpsRZ6XCf80U1uc6wE3QaTfN42qV
         +bkGd6U2SYa5lehYC8Rt/YdZcZ9nzqr3/I2A1uIIrvopkWX1Ai5dieFcI71pE4GR+NF1
         w/9ozTvt5xk8z10SJHMq5tlB70OSeZOym/wqhHTVKcJ5qee7tSb4GA4FRDVAZsEjQq3B
         GoHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="DF4/A1qV";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w18si2285961pjn.74.2019.07.31.14.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 14:04:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="DF4/A1qV";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ELnCJmHftki0TjR5pLeFRv3ZGO3vLpNPRssAISIykdc=; b=DF4/A1qVJ5S89p5qC8gexibFn
	dZ+kx6yshrb38il/41a/16P6sjGCvwNsI9mKfVmQd3eLJjskZs9XI+8WRe2Sd+qGz1GLWGqj9nBf3
	mThqLLZu+gEDcbBUiogQgWbJKDgtzLAHZNjfktWqM/z+EFD8Xk2A2yVsWoYBFKWRL+zOz+8gkuvsv
	HJ9UEhOCgxyYF1pVjLM/1uejnoknpPBJRVSzt8kSu1dMqFtU64VuEbrzdX7jGpHg8jTvEhhP9MsR/
	8FixG5dW9jaPj1/dVKCfJZyWtGil3wL9RdZpCcdRHhsyWevIajJIQwteXek7FfbFnNXLP1snJcVFl
	7s/rvhvaQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hsvlX-0001wL-Dn; Wed, 31 Jul 2019 21:04:07 +0000
From: Matthew Wilcox <willy@infradead.org>
To: akpm@linuxfoundation.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Jan Kara <jack@suse.cz>,
	Kirill Shutemov <kirill@shutemov.name>,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Qian Cai <cai@lca.pw>,
	Hugh Dickins <hughd@google.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Subject: [PATCH v5] mm: page cache: store only head pages in i_pages
Date: Wed, 31 Jul 2019 14:04:00 -0700
Message-Id: <20190731210400.7419-1-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Transparent Huge Pages are currently stored in i_pages as pointers to
consecutive subpages.  This patch changes that to storing consecutive
pointers to the head page in preparation for storing huge pages more
efficiently in i_pages.

Large parts of this are "inspired" by Kirill's patch
https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/

Kirill and Huang Ying contributed several fixes.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
Acked-by: Jan Kara <jack@suse.cz>
Reviewed-by: Kirill Shutemov <kirill@shutemov.name>
Reviewed-and-tested-by: Song Liu <songliubraving@fb.com>
Tested-by: William Kucharski <william.kucharski@oracle.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Hugh Dickins <hughd@google.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
---

Andrew, this is the the patch that you sent to Linus on May 13th that
was then reverted on July 5th with Huang's fix for swapped pages.

 include/linux/pagemap.h |  13 ++++
 mm/filemap.c            | 146 ++++++++++++++++------------------------
 mm/huge_memory.c        |  22 +++++-
 mm/khugepaged.c         |   4 +-
 mm/memfd.c              |   2 +
 mm/migrate.c            |   2 +-
 mm/shmem.c              |   2 +-
 mm/swap_state.c         |   4 +-
 8 files changed, 99 insertions(+), 96 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2f0dd118aaa8..1de283243e6b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -341,6 +341,19 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 			mapping_gfp_mask(mapping));
 }
 
+static inline struct page *find_subpage(struct page *page, pgoff_t offset)
+{
+	unsigned long mask;
+
+	if (PageHuge(page))
+		return page;
+
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	mask = (1UL << compound_order(page)) - 1;
+	return page + (offset & mask);
+}
+
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
 unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
diff --git a/mm/filemap.c b/mm/filemap.c
index 070c5ac7b1ed..af01684233d6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -281,11 +281,11 @@ EXPORT_SYMBOL(delete_from_page_cache);
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
@@ -294,40 +294,44 @@ static void page_cache_delete_batch(struct address_space *mapping,
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
+		 * Move to the next page in the vector if this is a regular
+		 * page or the index is of the last sub-page of this compound
+		 * page.
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
@@ -1519,7 +1523,7 @@ EXPORT_SYMBOL(page_cache_prev_miss);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	XA_STATE(xas, &mapping->i_pages, offset);
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 repeat:
@@ -1534,25 +1538,19 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 	if (!page || xa_is_value(page))
 		goto out;
 
-	head = compound_head(page);
-	if (!page_cache_get_speculative(head))
-		goto repeat;
-
-	/* The page was split under us? */
-	if (compound_head(page) != head) {
-		put_page(head);
+	if (!page_cache_get_speculative(page))
 		goto repeat;
-	}
 
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
 
@@ -1738,7 +1736,6 @@ unsigned find_get_entries(struct address_space *mapping,
 
 	rcu_read_lock();
 	xas_for_each(&xas, page, ULONG_MAX) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1749,17 +1746,13 @@ unsigned find_get_entries(struct address_space *mapping,
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
@@ -1768,7 +1761,7 @@ unsigned find_get_entries(struct address_space *mapping,
 			break;
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -1810,33 +1803,27 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 
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
 			*start = xas.xa_index + 1;
 			goto out;
 		}
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -1881,7 +1868,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 
 	rcu_read_lock();
 	for (page = xas_load(&xas); page; page = xas_next(&xas)) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1891,24 +1877,19 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
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
@@ -1944,7 +1925,6 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 
 	rcu_read_lock();
 	xas_for_each_marked(&xas, page, end, tag) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1955,26 +1935,21 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
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
 			*index = xas.xa_index + 1;
 			goto out;
 		}
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -2655,7 +2630,7 @@ void filemap_map_pages(struct vm_fault *vmf,
 	pgoff_t last_pgoff = start_pgoff;
 	unsigned long max_idx;
 	XA_STATE(xas, &mapping->i_pages, start_pgoff);
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 	xas_for_each(&xas, page, end_pgoff) {
@@ -2664,24 +2639,19 @@ void filemap_map_pages(struct vm_fault *vmf,
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
index 1334ede667a8..d0a700f58aef 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2485,6 +2485,8 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	struct page *head = compound_head(page);
 	pg_data_t *pgdat = page_pgdat(head);
 	struct lruvec *lruvec;
+	struct address_space *swap_cache = NULL;
+	unsigned long offset;
 	int i;
 
 	lruvec = mem_cgroup_page_lruvec(head, pgdat);
@@ -2492,6 +2494,14 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
+	if (PageAnon(head) && PageSwapCache(head)) {
+		swp_entry_t entry = { .val = page_private(head) };
+
+		offset = swp_offset(entry);
+		swap_cache = swap_address_space(entry);
+		xa_lock(&swap_cache->i_pages);
+	}
+
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		__split_huge_page_tail(head, i, lruvec, list);
 		/* Some pages can be beyond i_size: drop them from page cache */
@@ -2501,6 +2511,12 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 			if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
 				shmem_uncharge(head->mapping->host, 1);
 			put_page(head + i);
+		} else if (!PageAnon(page)) {
+			__xa_store(&head->mapping->i_pages, head[i].index,
+					head + i, 0);
+		} else if (swap_cache) {
+			__xa_store(&swap_cache->i_pages, offset + i,
+					head + i, 0);
 		}
 	}
 
@@ -2508,10 +2524,12 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	/* See comment in __split_huge_page_tail() */
 	if (PageAnon(head)) {
 		/* Additional pin to swap cache */
-		if (PageSwapCache(head))
+		if (PageSwapCache(head)) {
 			page_ref_add(head, 2);
-		else
+			xa_unlock(&swap_cache->i_pages);
+		} else {
 			page_ref_inc(head);
+		}
 	} else {
 		/* Additional pin to page cache */
 		page_ref_add(head, 2);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index eaaa21b23215..0f7419938008 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1378,7 +1378,7 @@ static void collapse_shmem(struct mm_struct *mm,
 				result = SCAN_FAIL;
 				goto xa_locked;
 			}
-			xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
+			xas_store(&xas, new_page);
 			nr_none++;
 			continue;
 		}
@@ -1454,7 +1454,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		list_add_tail(&page->lru, &pagelist);
 
 		/* Finally, replace with the new page. */
-		xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
+		xas_store(&xas, new_page);
 		continue;
 out_unlock:
 		unlock_page(page);
diff --git a/mm/memfd.c b/mm/memfd.c
index 650e65a46b9c..2647c898990c 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -39,6 +39,7 @@ static void memfd_tag_pins(struct xa_state *xas)
 	xas_for_each(xas, page, ULONG_MAX) {
 		if (xa_is_value(page))
 			continue;
+		page = find_subpage(page, xas->xa_index);
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
index 702115a9cf11..f6a23856f4e5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -459,7 +459,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 
 		for (i = 1; i < HPAGE_PMD_NR; i++) {
 			xas_next(&xas);
-			xas_store(&xas, newpage + i);
+			xas_store(&xas, newpage);
 		}
 	}
 
diff --git a/mm/shmem.c b/mm/shmem.c
index fccb34aca6ea..c8d5edf1ef5e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -616,7 +616,7 @@ static int shmem_add_to_page_cache(struct page *page,
 		if (xas_error(&xas))
 			goto unlock;
 next:
-		xas_store(&xas, page + i);
+		xas_store(&xas, page);
 		if (++i < nr) {
 			xas_next(&xas);
 			goto next;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index f844af5f09ba..8e7ce9a9bc5e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -133,7 +133,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
 		for (i = 0; i < nr; i++) {
 			VM_BUG_ON_PAGE(xas.xa_index != idx + i, page);
 			set_page_private(page + i, entry.val + i);
-			xas_store(&xas, page + i);
+			xas_store(&xas, page);
 			xas_next(&xas);
 		}
 		address_space->nrpages += nr;
@@ -168,7 +168,7 @@ void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
 
 	for (i = 0; i < nr; i++) {
 		void *entry = xas_store(&xas, NULL);
-		VM_BUG_ON_PAGE(entry != page + i, entry);
+		VM_BUG_ON_PAGE(entry != page, entry);
 		set_page_private(page + i, 0);
 		xas_next(&xas);
 	}
-- 
2.20.1


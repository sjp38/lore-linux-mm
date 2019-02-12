Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FC9EC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:35:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5AEC222C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:34:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ciruHumi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5AEC222C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69B028E0002; Tue, 12 Feb 2019 13:34:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6234A8E0001; Tue, 12 Feb 2019 13:34:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C5808E0002; Tue, 12 Feb 2019 13:34:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 002C28E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:34:58 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w16so2806780pll.15
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:34:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=xphOz71CSP7JJWioqIigJHYoCO6ko8c/CWaiEwIWqns=;
        b=smMX8mdtpATAV7NJr7FLQE2J/6lBD2riVb5BBcxnygI8lPiDF80kfvSaIb3zwN2RW+
         wAZcT4yJ3+wkbPPd7grmP7BX/G/ALdQ/2c/QET7lMWW4eYLNKaFHOPmAEy+Lp602GWtN
         eQAt/oT0EMWbLtvXoEzGyQt7b87hTwTMoIoKb35w9nmPm9MoQRoc0vtrlNd0YpVExlQq
         K9dczO4ZJ7m2/S2X7zK8HESbzSeQhVN6WKrMZArqTJqLlIrfYsPo3rAf9kVjPePpgE2X
         5rS6nqW8MnXZcyGQyOIbJqzDCZu4cCboo5Eom/xN8ZP3vmzE81raM98EI4NSRvF36hEk
         B/IA==
X-Gm-Message-State: AHQUAuaZ2iGNkU3TU+rU4TrmkYTxnWmH4z5w/DjQtwn1exAuYDy6W2ya
	MEuR6dCoc8oPUHMsc/dHnUrslhJ7XJbpgM5V3liDWbHMX1cU1qIKiTI/OETv9Mr3E4K8htexYFY
	krrHHY6GVMGT0OcmV+uj+QBQ3lwQcf2gPSRtJERX4qULs/CuUHXg+y+nt3zbFNuxYJw==
X-Received: by 2002:a62:3241:: with SMTP id y62mr5243744pfy.178.1549996498534;
        Tue, 12 Feb 2019 10:34:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia4t7dd8mCEKrsnD3pKeHeBw6n6GDZn/lpXK+7HB9qJa2pHzBEREND6YYenWJEYIueOEZHU
X-Received: by 2002:a62:3241:: with SMTP id y62mr5243642pfy.178.1549996497056;
        Tue, 12 Feb 2019 10:34:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549996497; cv=none;
        d=google.com; s=arc-20160816;
        b=I1AVkAR5rbM2NgMTYmMbs9UDWqle1aiMum46Wj9qdvOqPqT7IBm5YwWvIzz1rk6oKG
         QnKqjn3g57Igutqs/NTgyktPXBbp/58HnKaqObhvL4IawHb6g2RknEwJ5ee8HRLXq2uo
         sMggVcp7Bbro2pSlsrLoXP2w0qbbNQ4SD8wUSzE6ZBlvPhfNPdvPWmrJkvwcrBCkAuPc
         Mi8F99K4dhlP1fKrTNVsPKNOtrylqziOZ1ARDRZgptBKXfQotgMDgpICzA4WsFEZIxkh
         JZBbFP+ysFj4JQczVWouJ8cT76YowupEqSF1xn7y/sq74NAKzar2u+xfvGKHgr42GgQ1
         Tg/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=xphOz71CSP7JJWioqIigJHYoCO6ko8c/CWaiEwIWqns=;
        b=CKIroxGOXmvnIs+067zXRAr+lamICBa4R+ojBWa0GXe0/lwm0TbswCBxVdoqHR8Uib
         yOxdjQgKgbq2Reb1J6pyn9WNSI00UO+6WyF6p5sBJGXnwu6y1ZfMaTEuNlBSXS3BPIvz
         VmwgtK0LIhjDoifYSyVkeViX7j90c2XhTUUCwjANshUvRlgm65z84WOBNCkasmLEJxMt
         g0I+tKMffWtx7v4x0P4lTI8DdBZutOzIRxrzT4Q9EtU+8RSP4GgFkott/jjbS81dhCK+
         2A6bdJlAPIUS98nUrf6q3gXpnVGOGXdyQJzWoffoJshJSMCK2gDXqAcG+Nue7P8QfHAl
         CMxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ciruHumi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 91si14073235ply.214.2019.02.12.10.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 10:34:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ciruHumi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Message-Id:Date:Subject:Cc:To:From:
	Sender:Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=xphOz71CSP7JJWioqIigJHYoCO6ko8c/CWaiEwIWqns=; b=ciruHumimmlvGR28oM1geFKwt
	MENmPAs9E5HoE/i7BxYQafjjBEF0I3M/gB4kl7GV4Ww5nhShUm8As5+3QkZwB2fQkI43WSVls8cX7
	i5VR+m8NKrXuHbJilw6ZtS6zFwZpQSssZy9V1lch2kd1XlBnEaqGLtSDdDkzO5U/2LsIQemtAot7p
	h/oUrMXjL+LRk0DxUr0AKZPJSVOiGT6MOPDTtlvegm/hm+ng8EfLZYq7F3gHjr0G36gLfHekwiMye
	nOl24+uYfpNdsOwLyti41BAc8OwCR3THqGKe/TX0Ke/1rtHoqG0xUIFTZLfmgv1BX9J/MR2cDQzKg
	YuyxF7WJg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtctU-0006o0-92; Tue, 12 Feb 2019 18:34:56 +0000
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>,
	Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: [PATCH v2] page cache: Store only head pages in i_pages
Date: Tue, 12 Feb 2019 10:34:54 -0800
Message-Id: <20190212183454.26062-1-willy@infradead.org>
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
---
v2: Rebase on top of linux-next 20190212
    Fixed a missing s/head/page/ in filemap_map_pages
    Include missing calls to xas_store() in __split_huge_page

 include/linux/pagemap.h |  9 ++++
 mm/filemap.c            | 99 +++++++++++++----------------------------
 mm/huge_memory.c        |  3 ++
 mm/khugepaged.c         |  4 +-
 mm/shmem.c              |  2 +-
 mm/swap_state.c         |  2 +-
 6 files changed, 46 insertions(+), 73 deletions(-)

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
index 5673672fd444..ee28028c4323 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1491,7 +1491,7 @@ EXPORT_SYMBOL(page_cache_prev_miss);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	XA_STATE(xas, &mapping->i_pages, offset);
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 repeat:
@@ -1506,25 +1506,19 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
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
 
@@ -1706,7 +1700,6 @@ unsigned find_get_entries(struct address_space *mapping,
 
 	rcu_read_lock();
 	xas_for_each(&xas, page, ULONG_MAX) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1717,17 +1710,13 @@ unsigned find_get_entries(struct address_space *mapping,
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
@@ -1736,7 +1725,7 @@ unsigned find_get_entries(struct address_space *mapping,
 			break;
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -1778,33 +1767,27 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 
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
@@ -1849,7 +1832,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 
 	rcu_read_lock();
 	for (page = xas_load(&xas); page; page = xas_next(&xas)) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1859,24 +1841,19 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
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
@@ -1912,7 +1889,6 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 
 	rcu_read_lock();
 	xas_for_each_marked(&xas, page, end, tag) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -1923,26 +1899,21 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
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
@@ -1991,7 +1962,6 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 
 	rcu_read_lock();
 	xas_for_each_marked(&xas, page, ULONG_MAX, tag) {
-		struct page *head;
 		if (xas_retry(&xas, page))
 			continue;
 		/*
@@ -2002,17 +1972,13 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
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
@@ -2021,7 +1987,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 			break;
 		continue;
 put_page:
-		put_page(head);
+		put_page(page);
 retry:
 		xas_reset(&xas);
 	}
@@ -2686,7 +2652,7 @@ void filemap_map_pages(struct vm_fault *vmf,
 	pgoff_t last_pgoff = start_pgoff;
 	unsigned long max_idx;
 	XA_STATE(xas, &mapping->i_pages, start_pgoff);
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 	xas_for_each(&xas, page, end_pgoff) {
@@ -2695,24 +2661,19 @@ void filemap_map_pages(struct vm_fault *vmf,
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
index 85245fdec8d9..c5da342b5dba 100644
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
-- 
2.20.1


Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 558D2C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 465F02070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:23:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZlX5W95i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 465F02070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FD746B0003; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BA766B0007; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89C356B0007; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0123.hostedemail.com [216.40.44.123])
	by kanga.kvack.org (Postfix) with ESMTP id 6A52E6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 176A9181AC9B4
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:54 +0000 (UTC)
X-FDA: 75901690788.24.cow75_7943324950e27
X-HE-Tag: cow75_7943324950e27
X-Filterd-Recvd-Size: 7383
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=1QLSFFXUGzf9sZNnPcKI2Z9BvmtAY43QLuh0XGQS/rg=; b=ZlX5W95i+L/mDBug7zVcWALuB9
	Qg/q/3eWRr0nv2cDXYn6ZFCg4/Du+aym+zSHkwl8AsIVMGRepn8UGpe+JoypvYYv5rJraeLr2nveS
	OdUU8FrnozHR6LrZc7E8lHd95iL+kwR9hyl1bY47vCMwt82nAjczOXkVALyrJVgPC+ZSucSp8Vrtb
	8kMF/ytkkNjm6kLQZzO7axSvYdfkc2E/6yu1+sVO7GZMNjmuvMpASP9SkGiakcWQOiFf0CPtxFhbj
	5tPMedyzTimhnkRVi3AKHsT+XbX2t+FqukqQ6GudbnTxAh4guTnVHBqBq9gKHE29W6MVWuuoZQIfQ
	Vttqkz4w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5wQA-0001Uq-Uc; Thu, 05 Sep 2019 18:23:50 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Kirill Shutemov <kirill@shutemov.name>,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: [PATCH 3/3] mm: Allow find_get_page to be used for large pages
Date: Thu,  5 Sep 2019 11:23:48 -0700
Message-Id: <20190905182348.5319-4-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190905182348.5319-1-willy@infradead.org>
References: <20190905182348.5319-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Add FGP_PMD to indicate that we're trying to find-or-create a page that
is at least PMD_ORDER in size.  The internal 'conflict' entry usage
is modelled after that in DAX, but the implementations are different
due to DAX using multi-order entries and the page cache using multiple
order-0 entries.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/pagemap.h |  9 +++++
 mm/filemap.c            | 82 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 84 insertions(+), 7 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index d2147215d415..72101811524c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -248,6 +248,15 @@ pgoff_t page_cache_prev_miss(struct address_space *m=
apping,
 #define FGP_NOFS		0x00000010
 #define FGP_NOWAIT		0x00000020
 #define FGP_FOR_MMAP		0x00000040
+/*
+ * If you add more flags, increment FGP_ORDER_SHIFT (no further than 25)=
.
+ * Do not insert flags above the FGP order bits.
+ */
+#define FGP_ORDER_SHIFT		7
+#define FGP_PMD			((PMD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
+#define FGP_PUD			((PUD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
+
+#define fgp_order(fgp)		((fgp) >> FGP_ORDER_SHIFT)
=20
 struct page *pagecache_get_page(struct address_space *mapping, pgoff_t o=
ffset,
 		int fgp_flags, gfp_t cache_gfp_mask);
diff --git a/mm/filemap.c b/mm/filemap.c
index ae3c0a70a8e9..904dfabbea52 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1572,7 +1572,71 @@ struct page *find_get_entry(struct address_space *=
mapping, pgoff_t offset)
=20
 	return page;
 }
-EXPORT_SYMBOL(find_get_entry);
+
+static bool pagecache_is_conflict(struct page *page)
+{
+	return page =3D=3D XA_RETRY_ENTRY;
+}
+
+/**
+ * __find_get_page - Find and get a page cache entry.
+ * @mapping: The address_space to search.
+ * @offset: The page cache index.
+ * @order: The minimum order of the entry to return.
+ *
+ * Looks up the page cache entries at @mapping between @offset and
+ * @offset + 2^@order.  If there is a page cache page, it is returned wi=
th
+ * an increased refcount unless it is smaller than @order.
+ *
+ * If the slot holds a shadow entry of a previously evicted page, or a
+ * swap entry from shmem/tmpfs, it is returned.
+ *
+ * Return: the found page, a value indicating a conflicting page or %NUL=
L if
+ * there are no pages in this range.
+ */
+static struct page *__find_get_page(struct address_space *mapping,
+		unsigned long offset, unsigned int order)
+{
+	XA_STATE(xas, &mapping->i_pages, offset);
+	struct page *page;
+
+	rcu_read_lock();
+repeat:
+	xas_reset(&xas);
+	page =3D xas_find(&xas, offset | ((1UL << order) - 1));
+	if (xas_retry(&xas, page))
+		goto repeat;
+	/*
+	 * A shadow entry of a recently evicted page, or a swap entry from
+	 * shmem/tmpfs.  Skip it; keep looking for pages.
+	 */
+	if (xa_is_value(page))
+		goto repeat;
+	if (!page)
+		goto out;
+	if (compound_order(page) < order) {
+		page =3D XA_RETRY_ENTRY;
+		goto out;
+	}
+
+	if (!page_cache_get_speculative(page))
+		goto repeat;
+
+	/*
+	 * Has the page moved or been split?
+	 * This is part of the lockless pagecache protocol. See
+	 * include/linux/pagemap.h for details.
+	 */
+	if (unlikely(page !=3D xas_reload(&xas))) {
+		put_page(page);
+		goto repeat;
+	}
+	page =3D find_subpage(page, offset);
+out:
+	rcu_read_unlock();
+
+	return page;
+}
=20
 /**
  * find_lock_entry - locate, pin and lock a page cache entry
@@ -1614,12 +1678,12 @@ EXPORT_SYMBOL(find_lock_entry);
  * pagecache_get_page - find and get a page reference
  * @mapping: the address_space to search
  * @offset: the page index
- * @fgp_flags: PCG flags
+ * @fgp_flags: FGP flags
  * @gfp_mask: gfp mask to use for the page cache data page allocation
  *
  * Looks up the page cache slot at @mapping & @offset.
  *
- * PCG flags modify how the page is returned.
+ * FGP flags modify how the page is returned.
  *
  * @fgp_flags can be:
  *
@@ -1632,6 +1696,10 @@ EXPORT_SYMBOL(find_lock_entry);
  * - FGP_FOR_MMAP: Similar to FGP_CREAT, only we want to allow the calle=
r to do
  *   its own locking dance if the page is already in cache, or unlock th=
e page
  *   before returning if we had to add the page to pagecache.
+ * - FGP_PMD: We're only interested in pages at PMD granularity.  If the=
re
+ *   is no page here (and FGP_CREATE is set), we'll create one large eno=
ugh.
+ *   If there is a smaller page in the cache that overlaps the PMD page,=
 we
+ *   return %NULL and do not attempt to create a page.
  *
  * If FGP_LOCK or FGP_CREAT are specified then the function may sleep ev=
en
  * if the GFP flags specified for FGP_CREAT are atomic.
@@ -1646,9 +1714,9 @@ struct page *pagecache_get_page(struct address_spac=
e *mapping, pgoff_t offset,
 	struct page *page;
=20
 repeat:
-	page =3D find_get_entry(mapping, offset);
-	if (xa_is_value(page))
-		page =3D NULL;
+	page =3D __find_get_page(mapping, offset, fgp_order(fgp_flags));
+	if (pagecache_is_conflict(page))
+		return NULL;
 	if (!page)
 		goto no_page;
=20
@@ -1682,7 +1750,7 @@ struct page *pagecache_get_page(struct address_spac=
e *mapping, pgoff_t offset,
 		if (fgp_flags & FGP_NOFS)
 			gfp_mask &=3D ~__GFP_FS;
=20
-		page =3D __page_cache_alloc(gfp_mask);
+		page =3D __page_cache_alloc_order(gfp_mask, fgp_order(fgp_flags));
 		if (!page)
 			return NULL;
=20
--=20
2.23.0.rc1



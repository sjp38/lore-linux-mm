Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 116BFC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3F7B2070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:23:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Gpl9LKCw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3F7B2070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D31966B0008; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3EE6B0007; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5C7F6B000C; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id 84C536B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 27DA5181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:55 +0000 (UTC)
X-FDA: 75901690830.26.men20_797a5c819cd51
X-HE-Tag: men20_797a5c819cd51
X-Filterd-Recvd-Size: 4209
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tXdc4iXzoXHU6OjGWpZjE6sWjkGFF7V5SHiPuHEFbCs=; b=Gpl9LKCwzm4apXNKWlvcBoujeM
	PczdnpXwPrCTloQ/JcvJKN8U2YuahJIfrkP4L9cUTYB3V1ZoPBSrWxAJyzoTsIj0+uDx5oS+h2CTC
	9WMsyr8KX2eDDyjkltgxe8psNHJRdUKtp45khXvYjgtXRbqbQtAXCH5jPgQ/sPHMHrJbuEUclg3da
	lBLNtjsLsfv2I8xEU3XAITOWeji5QqdmivrHTMv0HJVopIqdALlSG1fBQeTkNv/dwEzCdz/eZW5Xa
	AzDyQykKBt5d7ufUxG0MM1zraic1i+RhB8ub0KKJOYa8lnpwR+CGQRubsYGvcK4Wi+6QTjYl1yYcv
	BGa/FFzA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5wQA-0001U6-Dv; Thu, 05 Sep 2019 18:23:50 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Kirill Shutemov <kirill@shutemov.name>,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: [PATCH 1/3] mm: Add __page_cache_alloc_order
Date: Thu,  5 Sep 2019 11:23:46 -0700
Message-Id: <20190905182348.5319-2-willy@infradead.org>
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

This new function allows page cache pages to be allocated that are
larger than an order-0 page.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/pagemap.h | 14 +++++++++++---
 mm/filemap.c            | 11 +++++++----
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 103205494ea0..d2147215d415 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -208,14 +208,22 @@ static inline int page_cache_add_speculative(struct=
 page *page, int count)
 }
=20
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int ord=
er);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline
+struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
 {
-	return alloc_pages(gfp, 0);
+	if (order > 0)
+		gfp |=3D __GFP_COMP;
+	return alloc_pages(gfp, order);
 }
 #endif
=20
+static inline struct page *__page_cache_alloc(gfp_t gfp)
+{
+	return __page_cache_alloc_order(gfp, 0);
+}
+
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
 	return __page_cache_alloc(mapping_gfp_mask(x));
diff --git a/mm/filemap.c b/mm/filemap.c
index 05a5aa82cd32..041c77c4ca56 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -957,24 +957,27 @@ int add_to_page_cache_lru(struct page *page, struct=
 address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
=20
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
 {
 	int n;
 	struct page *page;
=20
+	if (order > 0)
+		gfp |=3D __GFP_COMP;
+
 	if (cpuset_do_page_mem_spread()) {
 		unsigned int cpuset_mems_cookie;
 		do {
 			cpuset_mems_cookie =3D read_mems_allowed_begin();
 			n =3D cpuset_mem_spread_node();
-			page =3D __alloc_pages_node(n, gfp, 0);
+			page =3D __alloc_pages_node(n, gfp, order);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
=20
 		return page;
 	}
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp, order);
 }
-EXPORT_SYMBOL(__page_cache_alloc);
+EXPORT_SYMBOL(__page_cache_alloc_order);
 #endif
=20
 /*
--=20
2.23.0.rc1



Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53947C3A589
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:31:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1369122DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hfuFvEaE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1369122DD3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E53886B0266; Tue, 20 Aug 2019 20:30:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8E726B0269; Tue, 20 Aug 2019 20:30:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0E8B6B026B; Tue, 20 Aug 2019 20:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5DE6B0266
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:30:58 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3FB8A181AC9BF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:58 +0000 (UTC)
X-FDA: 75844554996.04.bone62_429b8406c4c24
X-HE-Tag: bone62_429b8406c4c24
X-Filterd-Recvd-Size: 3714
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8+LFRgysFm6l7b1EmI740QXkofLUbCuDM+A6qLMp9ww=; b=hfuFvEaEQut5AVQb1YlZ91uQkZ
	cQCCd+XL0ZBjSfW+iVu6x/ii9yjABmkxM578Y1ifxD7MMwjomQLoKGn5k4MLo2FX/86BoXjOGYx+m
	st3+ToZCILpSW/kqCpeT1dtRTADo/0xMsbEK3LKhk9WhVc8eDvpYi0Sg0B/CLMkYomJKnt44gkhFd
	4QqRaGzT/xJhc6sVKdddPDG4H6ktFrxuEeyvAJ1O71FUL4NKpe0v0gJNYXfogtiSI3fi5iLUrGIRa
	8WF1zrkQ0+YMlL9tT+cBEyyUoucubTbfdFEgqghr9OeVk1kAfYxAmOblCehYf/ZXd0//Z8EABbvof
	y4pJ4swA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0EWQ-0003HW-A3; Wed, 21 Aug 2019 00:30:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v2 2/5] mm: Add file_offset_of_ helpers
Date: Tue, 20 Aug 2019 17:30:36 -0700
Message-Id: <20190821003039.12555-3-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190821003039.12555-1-willy@infradead.org>
References: <20190821003039.12555-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

The page_offset function is badly named for people reading the functions
which call it.  The natural meaning of a function with this name would
be 'offset within a page', not 'page offset in bytes within a file'.
Dave Chinner suggests file_offset_of_page() as a replacement function
name and I'm also adding file_offset_of_next_page() as a helper for the
large page work.  Also add kernel-doc for these functions so they show
up in the kernel API book.

page_offset() is retained as a compatibility define for now.
---
 include/linux/pagemap.h | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2728f20fbc49..84f341109710 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -436,14 +436,33 @@ static inline pgoff_t page_to_pgoff(struct page *pa=
ge)
 	return page_to_index(page);
 }
=20
-/*
- * Return byte-offset into filesystem object for page.
+/**
+ * file_offset_of_page - File offset of this page.
+ * @page: Page cache page.
+ *
+ * Context: Any context.
+ * Return: The offset of the first byte of this page.
  */
-static inline loff_t page_offset(struct page *page)
+static inline loff_t file_offset_of_page(struct page *page)
 {
 	return ((loff_t)page->index) << PAGE_SHIFT;
 }
=20
+/* Legacy; please convert callers */
+#define page_offset(page)	file_offset_of_page(page)
+
+/**
+ * file_offset_of_next_page - File offset of the next page.
+ * @page: Page cache page.
+ *
+ * Context: Any context.
+ * Return: The offset of the first byte after this page.
+ */
+static inline loff_t file_offset_of_next_page(struct page *page)
+{
+	return ((loff_t)page->index + compound_nr(page)) << PAGE_SHIFT;
+}
+
 static inline loff_t page_file_offset(struct page *page)
 {
 	return ((loff_t)page_index(page)) << PAGE_SHIFT;
--=20
2.23.0.rc1



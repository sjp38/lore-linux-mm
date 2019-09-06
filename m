Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1CCFC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 16:00:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57CC2214DE
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 16:00:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EyqSM1AB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57CC2214DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B74E6B0003; Fri,  6 Sep 2019 12:00:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 767AE6B0005; Fri,  6 Sep 2019 12:00:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A4786B0007; Fri,  6 Sep 2019 12:00:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0116.hostedemail.com [216.40.44.116])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4656B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:00:01 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D6A1A1EF1
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 16:00:00 +0000 (UTC)
X-FDA: 75904956960.23.queen28_575c1f87da427
X-HE-Tag: queen28_575c1f87da427
X-Filterd-Recvd-Size: 5189
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 16:00:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nVVfwL9jPbxbv3UU7EoQYh7TMejKlo+fUaut0VfJfrw=; b=EyqSM1ABuGTf/zoM83qIcUFVi
	1wUQCwyFHi2EyzPSjT0zHjuZAdS8/ubNh3DpDu9PXz9B1wFy2P94iJUrycdEu7ZPC+Yhr0RR20erg
	mU0Rrx7BFCspWQcJt/ce1e2+mofN5QnlQfiD5zvAecgwnbC18I7yt1LZSqF9UOCgnt9091qUIypBO
	KqRLxP7Q21GIbWDVBj/VeIdjCuNuFQ8AHfrTbrFYiguBmv2xKU1wkFoDA1zBT5ZzQIy7fC7IggLdQ
	6q27uwvAZFklafc9/rIw6nirCYmPKby2ZAWlvtMnUQTq7XT7NtDBlxOgq6S3Lg6NYoZxhUexyLgje
	lhf7gEzrw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i6GeN-00050e-JA; Fri, 06 Sep 2019 15:59:51 +0000
Date: Fri, 6 Sep 2019 08:59:51 -0700
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Kirill Shutemov <kirill@shutemov.name>,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 4/3] Prepare transhuge pages properly
Message-ID: <20190906155951.GZ29434@bombadil.infradead.org>
References: <20190905182348.5319-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905182348.5319-1-willy@infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Bill pointed out I'd forgotten to call prep_transhuge_page().  I'll
fold this into some of the other commits, but this is what I'm thinking
of doing in case anyone has a better idea:

Basically, I prefer being able to do this:

-	return alloc_pages(gfp, order);
+	return prep_transhuge_page(alloc_pages(gfp, order));

to this:

+	struct page *page;
-	return alloc_pages(gfp, order);
+	page = alloc_pages(gfp, order);
+	if (page && (gfp & __GFP_COMP))
+		prep_transhuge_page(page);
+	return page;

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 45ede62aa85b..159e63438806 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -153,7 +153,7 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags);
 
-extern void prep_transhuge_page(struct page *page);
+extern struct page *prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
 
 bool can_split_huge_page(struct page *page, int *pextra_pins);
@@ -294,7 +294,10 @@ static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
 	return false;
 }
 
-static inline void prep_transhuge_page(struct page *page) {}
+static inline struct page *prep_transhuge_page(struct page *page)
+{
+	return page;
+}
 
 #define transparent_hugepage_flags 0UL
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 72101811524c..8b9d672d868c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -215,7 +215,7 @@ struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
 {
 	if (order > 0)
 		gfp |= __GFP_COMP;
-	return alloc_pages(gfp, order);
+	return prep_transhuge_page(alloc_pages(gfp, order));
 }
 #endif
 
diff --git a/mm/filemap.c b/mm/filemap.c
index a7fa3a50f750..c2b11799b968 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -986,11 +986,12 @@ struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
 			page = __alloc_pages_node(n, gfp, order);
+			prep_transhuge_page(page);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
 	}
-	return alloc_pages(gfp, order);
+	return prep_transhuge_page(alloc_pages(gfp, order));
 }
 EXPORT_SYMBOL(__page_cache_alloc_order);
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 483b07b2d6ae..3961af907dd7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -502,15 +502,20 @@ static inline struct list_head *page_deferred_list(struct page *page)
 	return &page[2].deferred_list;
 }
 
-void prep_transhuge_page(struct page *page)
+struct page *prep_transhuge_page(struct page *page)
 {
+	if (!page || compound_order(page) == 0)
+		return page;
 	/*
-	 * we use page->mapping and page->indexlru in second tail page
+	 * we use page->mapping and page->index in second tail page
 	 * as list_head: assuming THP order >= 2
 	 */
+	BUG_ON(compound_order(page) == 1);
 
 	INIT_LIST_HEAD(page_deferred_list(page));
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
+
+	return page;
 }
 
 static unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,



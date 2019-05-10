Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7363EC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26C67216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WvgmbUmS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26C67216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EF5A6B028F; Fri, 10 May 2019 09:50:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27DEC6B0297; Fri, 10 May 2019 09:50:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40CD6B0290; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36EF96B0288
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h14so4067241pgn.23
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=q9WVpS/XRZo3IbNhcOGMhrxuleT/Y4xb+FSNGOlKeoQ=;
        b=Rquy+5w6Umt4kBYCV6GjMiD6rRuTgmEuuFCrzXdoFlBTr4RiamvO3u8F0bndiou33g
         fMYghkEll5mHFBBYQ/MKID2dMJsrfjmz3Smdt1ZOk7lyc7aWejHpHVi46asVXJs7jNMr
         EvByoxTQqCDLMsvH9ljwI8eBeVxU+t4i49JfkUjXqZZonpHUly2p34R50lYRkofVfeG/
         7fiAsldzJ3pWGVJ7ru9tq0LapJhu6PweD1aoastotmmIcXz9qnFZ5zPFhLOR8Ms6ajup
         8+T9uKBMjv4lS/MIwC9MkWPcjfd+7jWVIA1ftOk1Ju9QRuPwQy/5d2REDyONSY9NnMXs
         A0/g==
X-Gm-Message-State: APjAAAVM0HYEk+N7EcVXXE1KzYFARAqMdJkQCzgSLo4oqDx5usQgyM2D
	sXgJ8+iu1DuRWQMmLti4TrtsKN+lY/teCR53QM/DeEqJ07pToYNula8VsZxzYrN8w6IiKgj9ryQ
	QnfeGlqNMwD2kFJlDM4AzJmN8MfYUqZsiffKJypoXYEKJub+9IL41IAceDxCSvwnQFg==
X-Received: by 2002:a62:2e46:: with SMTP id u67mr14523532pfu.206.1557496242681;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg9Fg7hAF2VClkjVbShwzweJPoMQOZU6fthZOUsUV8iBS3v/pvXrWlN2oh99WW8CJJ2PzN
X-Received: by 2002:a62:2e46:: with SMTP id u67mr14523369pfu.206.1557496241389;
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496241; cv=none;
        d=google.com; s=arc-20160816;
        b=N3PxyrgUbN7zchhLmu8b8v0B3BlohLqXh5Gp3LxLa/96UKKhHV+bm9AY5EAjg06RmO
         hcXozsokAfhy3uZKxhxxz18GjZ2WmibrAbrpwViH/CrZZmMNd02IlPrpqjbzpARklDVJ
         nz7QxQsu4RjksdE13RYEVbg8WjC+vpptRysempecQGPkUA6BNC5Qb3k9mz2qURvP3jgu
         /viFLrrXMQ457wE/Jc8SALqZiEt9TeVfI9FNLTgK9BqCvxMZLDnBZ8yq9wFZZdDxQyr4
         m0NktoogcOw+11LIghKBbprh0G4shJTJFJ2X3khquE0X8ShFuwbPKjo/0Fipky/chiug
         eH6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=q9WVpS/XRZo3IbNhcOGMhrxuleT/Y4xb+FSNGOlKeoQ=;
        b=PcKh7EKRJhJ9b5/X4FG7U0vkNIUS3in2/iMhMT+BNxGnBaPar5OjvyoLn1YWstdOXK
         Dz3Q01D17CjexGiTFmgr6w9V4VATYXLuvGB1m4bxAjsLMCEwTG5GACT13+CQvmCtlCU+
         xZbotKgUxiVlHRxzOhxD/RG+DnwZlc7Hfd/ltZL6CW+a1ln/HFJqWSgfMDh0u4utpgwu
         Sj9sE1TWxI7cSRNrbst03Rce6OmTXW/FWpIiriYi1YjEnTSlkxBSBRyVVMZAN7cD5aKc
         3e0HeOERAPKNEUIbQjGwotc+so4jhc/UwroSLDWNRSBxmlNsAN1lqe5l512iGw1Qvshh
         4hUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WvgmbUmS;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k13si7264703pgh.410.2019.05.10.06.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WvgmbUmS;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=q9WVpS/XRZo3IbNhcOGMhrxuleT/Y4xb+FSNGOlKeoQ=; b=WvgmbUmStQViYakqufiN4FIn1
	lgm/TlYgHi600Llt/L9Ii78ZqHf1cltvEXFjJocIzTFpyt+1nvLPk2BoCOj3O/apZj34mSsIAaGN3
	AXZXysEDw9B/9gpozNWuyWdhfAF3PFn+aaBBX69q6rFvoRguojWs5MAjZ6ZJV/TQmgygBSwSbqZbm
	P4GODopxHzI7Sb0FDUfBAd8DdH0iUCV5YhDBajkPKKegaDHBq/wlpCb8BwhWfG6MRHLSZl9r3qPvD
	sI1hPIqKDb2MKToxM0ePVJz6Y46f9djvzCPXylyLC/ixQ74BwYRlamhPsblDjeP3HeT1K3E+Lty8U
	QhGSuOUvA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v6-0004Tj-Sz; Fri, 10 May 2019 13:50:40 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 05/15] mm: Pass order to alloc_pages_current in GFP flags
Date: Fri, 10 May 2019 06:50:28 -0700
Message-Id: <20190510135038.17129-6-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Matches the change to the __alloc_pages_nodemask API.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/gfp.h |  4 ++--
 mm/mempolicy.c      | 10 ++++------
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 9ddc7703ea81..94ba8a6172e4 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -511,12 +511,12 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
+extern struct page *alloc_pages_current(gfp_t gfp_mask);
 
 static inline struct page *
 alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
-	return alloc_pages_current(gfp_mask, order);
+	return alloc_pages_current(gfp_mask | __GFP_ORDER(order));
 }
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8d5375cdd928..eec0b9c21962 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2108,13 +2108,12 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
  *      	%GFP_HIGHMEM highmem allocation,
  *      	%GFP_FS     don't call back into a file system.
  *      	%GFP_ATOMIC don't sleep.
- *	@order: Power of two of allocation size in pages. 0 is a single page.
  *
  *	Allocate a page from the kernel page pool.  When not in
- *	interrupt context and apply the current process NUMA policy.
+ *	interrupt context apply the current process NUMA policy.
  *	Returns NULL when no page can be allocated.
  */
-struct page *alloc_pages_current(gfp_t gfp, unsigned order)
+struct page *alloc_pages_current(gfp_t gfp)
 {
 	struct mempolicy *pol = &default_policy;
 	struct page *page;
@@ -2127,10 +2126,9 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp | __GFP_ORDER(order),
-				interleave_nodes(pol));
+		page = alloc_page_interleave(gfp, interleave_nodes(pol));
 	else
-		page = __alloc_pages_nodemask(gfp | __GFP_ORDER(order),
+		page = __alloc_pages_nodemask(gfp,
 				policy_node(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
 
-- 
2.20.1


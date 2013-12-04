Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id DBC4F6B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 11:59:16 -0500 (EST)
Received: by mail-ie0-f177.google.com with SMTP id tp5so26054564ieb.8
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:59:16 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id nh2si9989317icc.143.2013.12.04.08.59.15
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 08:59:15 -0800 (PST)
Date: Wed, 4 Dec 2013 10:59:18 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 03/15] mm: thp: give transparent hugepage code a separate
 copy_page
Message-ID: <20131204165918.GA13191@sgi.com>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
 <1386060721-3794-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1386060721-3794-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> -void copy_huge_page(struct page *dst, struct page *src)
> -{
> -	int i;
> -	struct hstate *h = page_hstate(src);
> -
> -	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {

With CONFIG_HUGETLB_PAGE=n, the kernel fails to build, throwing this
error:

mm/migrate.c: In function a??copy_huge_pagea??:
mm/migrate.c:473: error: implicit declaration of function a??page_hstatea??

I got it to build by sticking the following into hugetlb.h:

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 4694afc..fd76912 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -403,6 +403,7 @@ struct hstate {};
 #define hstate_sizelog(s) NULL
 #define hstate_vma(v) NULL
 #define hstate_inode(i) NULL
+#define page_hstate(p) NULL
 #define huge_page_size(h) PAGE_SIZE
 #define huge_page_mask(h) PAGE_MASK
 #define vma_kernel_pagesize(v) PAGE_SIZE

I figure that the #define I stuck in isn't actually solving the real
problem, but it got things working again.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

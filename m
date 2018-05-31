Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3836B0006
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:55:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w7-v6so12807089pfd.9
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:55:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b66-v6si37586672plb.107.2018.05.31.06.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:55:04 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm/page_ext: Constify lookup_page_ext() argument
Date: Thu, 31 May 2018 16:54:57 +0300
Message-Id: <20180531135457.20167-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180531135457.20167-1-kirill.shutemov@linux.intel.com>
References: <20180531135457.20167-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

lookup_page_ext() finds 'struct page_ext' for a given page. It requires
only read access to the given struct page.

Current implemnentation takes 'struct page *' as an argument. It makes
compiler complain when 'const struct page *' passed.

Change the argument to 'const struct page *'.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page_ext.h | 4 ++--
 mm/page_ext.c            | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index bbec618a614b..f84f167ec04c 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -50,7 +50,7 @@ static inline void page_ext_init(void)
 }
 #endif
 
-struct page_ext *lookup_page_ext(struct page *page);
+struct page_ext *lookup_page_ext(const struct page *page);
 
 #else /* !CONFIG_PAGE_EXTENSION */
 struct page_ext;
@@ -59,7 +59,7 @@ static inline void pgdat_page_ext_init(struct pglist_data *pgdat)
 {
 }
 
-static inline struct page_ext *lookup_page_ext(struct page *page)
+static inline struct page_ext *lookup_page_ext(const struct page *page)
 {
 	return NULL;
 }
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 5295ef331165..a9826da84ccb 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -120,7 +120,7 @@ void __meminit pgdat_page_ext_init(struct pglist_data *pgdat)
 	pgdat->node_page_ext = NULL;
 }
 
-struct page_ext *lookup_page_ext(struct page *page)
+struct page_ext *lookup_page_ext(const struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long index;
@@ -195,7 +195,7 @@ void __init page_ext_init_flatmem(void)
 
 #else /* CONFIG_FLAT_NODE_MEM_MAP */
 
-struct page_ext *lookup_page_ext(struct page *page)
+struct page_ext *lookup_page_ext(const struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 	struct mem_section *section = __pfn_to_section(pfn);
-- 
2.17.0

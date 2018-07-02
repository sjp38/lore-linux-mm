Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD2F76B0007
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 14:05:47 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c1-v6so19134906qtj.6
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 11:05:47 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l35-v6si7830699qvg.30.2018.07.02.11.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 11:05:46 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2] mm: teach dump_page() to correctly output poisoned struct pages
Date: Mon,  2 Jul 2018 14:05:36 -0400
Message-Id: <20180702180536.2552-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, mgorman@techsingularity.net, gregkh@linuxfoundation.org, pasha.tatashin@oracle.com

If struct page is poisoned, and uninitialized access is detected via
PF_POISONED_CHECK(page) dump_page() is called to output the page. But,
the dump_page() itself accesses struct page to determine how to print
it, and therefore gets into a recursive loop.

For example:
dump_page()
 __dump_page()
  PageSlab(page)
   PF_POISONED_CHECK(page)
    VM_BUG_ON_PGFLAGS(PagePoisoned(page), page)
     dump_page() recursion loop.

Fixes: f165b378bbdf ("mm: uninitialized struct page poisoning sanity checking")

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/debug.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 56e2d9125ea5..38c926520c97 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -43,12 +43,25 @@ const struct trace_print_flags vmaflag_names[] = {
 
 void __dump_page(struct page *page, const char *reason)
 {
+	bool page_poisoned = PagePoisoned(page);
+	int mapcount;
+
+	/*
+	 * If struct page is poisoned don't access Page*() functions as that
+	 * leads to recursive loop. Page*() check for poisoned pages, and calls
+	 * dump_page() when detected.
+	 */
+	if (page_poisoned) {
+		pr_emerg("page:%px is uninitialized and poisoned", page);
+		goto hex_only;
+	}
+
 	/*
 	 * Avoid VM_BUG_ON() in page_mapcount().
 	 * page->_mapcount space in struct page is used by sl[aou]b pages to
 	 * encode own info.
 	 */
-	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
+	mapcount = PageSlab(page) ? 0 : page_mapcount(page);
 
 	pr_emerg("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
 		  page, page_ref_count(page), mapcount,
@@ -60,6 +73,7 @@ void __dump_page(struct page *page, const char *reason)
 
 	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
 
+hex_only:
 	print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE, 32,
 			sizeof(unsigned long), page,
 			sizeof(struct page), false);
@@ -68,7 +82,7 @@ void __dump_page(struct page *page, const char *reason)
 		pr_alert("page dumped because: %s\n", reason);
 
 #ifdef CONFIG_MEMCG
-	if (page->mem_cgroup)
+	if (!page_poisoned && page->mem_cgroup)
 		pr_alert("page->mem_cgroup:%px\n", page->mem_cgroup);
 #endif
 }
-- 
2.18.0

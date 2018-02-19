Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADE2F6B0011
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 12:06:20 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id d26so7846130qtm.14
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 09:06:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l66sor73195qkd.125.2018.02.19.09.06.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Feb 2018 09:06:19 -0800 (PST)
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Subject: [PATCH] mm: Fix for PG_reserved page flag clearing
Message-ID: <d77ca418-1614-6ad3-d739-161ca737b7ec@gmail.com>
Date: Mon, 19 Feb 2018 12:06:14 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net
Cc: pasha.tatashin@oracle.com, linux-mm@kvack.org

From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>

struct page is inizialized as zero in __init_single_page().
If the page is offlined page, PG_reserved flag is set in early boot
time before __init_single_page(), so we should not clear the flag.

The real problem is that we can not online the offlined page
through following sysfs operation because offlined page is
expected PG_reserved flag is set. 
It is not needed the initialization, so remove it simply.

  Code:

  static int online_pages_range(unsigned long start_pfn, 
  ...
          if (PageReserved(pfn_to_page(start_pfn))) <= HERE!!
                  for (i = 0; i < nr_pages; i++) {
                          page = pfn_to_page(start_pfn + i);
                          (*online_page_callback)(page);
                          onlined_pages++;
  sysfs operation:

  # echo online > /sys/devices/system/node/node2/memory12288/online
  # cat /sys/devices/system/node/node2/memory12288/online 
  1
  # cat /sys/devices/system/node/node2/meminfo 
  Node 2 MemTotal:              0 kB

Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
---
 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c9688..3260cd2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1179,7 +1179,6 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
-	mm_zero_struct_page(page);
 	set_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
-- 
2.16.1

- Masayoshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

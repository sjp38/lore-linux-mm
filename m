Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 089486B007B
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:49:53 -0500 (EST)
Received: by pwj10 with SMTP id 10so3540366pwj.6
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 06:49:33 -0800 (PST)
Date: Wed, 13 Jan 2010 22:49:17 +0800
From: Li Hong <lihong.hi@gmail.com>
Subject: [PATCH 1/3] mm: page_alloc.c Remove duplicate call to
 trace_mm_page_free_direct
Message-ID: <20100113144917.GA11934@xhl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Function 'trace_mm_page_free_direct' is called in function '__free_pages'.
But it is called again in 'free_hot_page' if order == 0 and produce duplicate
records in trace file for mm_page_free_direct event. As below:

K-PID    CPU#    TIMESTAMP  FUNCTION
  gnome-terminal-1567  [000]  4415.246466: mm_page_free_direct: page=ffffea0003db9f40 pfn=1155800 order=0
  gnome-terminal-1567  [000]  4415.246468: mm_page_free_direct: page=ffffea0003db9f40 pfn=1155800 order=0
  gnome-terminal-1567  [000]  4415.246506: mm_page_alloc: page=ffffea0003db9f40 pfn=1155800 order=0 migratetype=0 gfp_flags=GFP_KERNEL
  gnome-terminal-1567  [000]  4415.255557: mm_page_free_direct: page=ffffea0003db9f40 pfn=1155800 order=0
  gnome-terminal-1567  [000]  4415.255557: mm_page_free_direct: page=ffffea0003db9f40 pfn=1155800 order=0

This patch removes the first call and add a call to 'trace_mm_page_free_direct'
in '__free_pages_ok'.

Signed-off-by: Li Hong <lihong.hi@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e9f5cc..24344cd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -582,6 +582,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
        int bad = 0;
        int wasMlocked = __TestClearPageMlocked(page);
 
+       trace_mm_page_free_direct(page, order);
        kmemcheck_free_shadow(page, order);
 
        for (i = 0 ; i < (1 << order) ; ++i)
@@ -2012,7 +2013,6 @@ void __pagevec_free(struct pagevec *pvec)
 void __free_pages(struct page *page, unsigned int order)
 {
        if (put_page_testzero(page)) {
-               trace_mm_page_free_direct(page, order);
                if (order == 0)
                        free_hot_page(page);
                else
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

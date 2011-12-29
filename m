Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 30B066B00B1
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:45:16 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so8766987wib.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 04:45:14 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 29 Dec 2011 20:45:14 +0800
Message-ID: <CAJd=RBBJG+hLLc3mR-WzByU1gZEcdFUAoZzyir+1A4a0tVnSmg@mail.gmail.com>
Subject: [PATCH] mm: vmscam: check page order in isolating lru pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Before we try to isolate physically contiguous pages, check for page order is
added, and if the reclaim order is no larger than page order, we should give up
the attempt.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Thu Dec 29 20:28:14 2011
@@ -1162,6 +1162,7 @@ static unsigned long isolate_lru_pages(u
 		unsigned long end_pfn;
 		unsigned long page_pfn;
 		int zone_id;
+		unsigned int isolated_pages = 0;

 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -1172,7 +1173,7 @@ static unsigned long isolate_lru_pages(u
 		case 0:
 			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
-			nr_taken += hpage_nr_pages(page);
+			isolated_pages = hpage_nr_pages(page);
 			break;

 		case -EBUSY:
@@ -1184,8 +1185,11 @@ static unsigned long isolate_lru_pages(u
 			BUG();
 		}

+		nr_taken += isolated_pages;
 		if (!order)
 			continue;
+		if (isolated_pages != 1 && isolated_pages >= (1 << order))
+			continue;

 		/*
 		 * Attempt to take all pages in the order aligned region
@@ -1227,7 +1231,6 @@ static unsigned long isolate_lru_pages(u
 				break;

 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				unsigned int isolated_pages;

 				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

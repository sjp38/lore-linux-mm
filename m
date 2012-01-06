Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id A96F26B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 07:49:36 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so1333998wgb.26
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 04:49:35 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 6 Jan 2012 20:49:34 +0800
Message-ID: <CAJd=RBDLT54HGuM7+=rM7yKi1ziSxLBsnT2Rm2VjRPTSc8OkFg@mail.gmail.com>
Subject: [PATCH v2] mm: vmscan: check page order in isolating lru pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

Before attempting to take all pages in the order aligned region, check for
page order is added for minor optimization, since the pfn-based isolation
could be bypassed if the newly isolated page is no less than that region.

v1->v2 changes
1, the reason to add the check is described in change log,
2, the check is corrected,
3, comment for the check is corrected.

Thanks for all comments recieved.


Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Fri Jan  6 20:28:22 2012
@@ -1162,6 +1162,7 @@ static unsigned long isolate_lru_pages(u
 		unsigned long end_pfn;
 		unsigned long page_pfn;
 		int zone_id;
+		unsigned int isolated_pages = 1;

 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -1172,7 +1173,8 @@ static unsigned long isolate_lru_pages(u
 		case 0:
 			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
-			nr_taken += hpage_nr_pages(page);
+			isolated_pages = hpage_nr_pages(page);
+			nr_taken += isolated_pages;
 			break;

 		case -EBUSY:
@@ -1188,6 +1190,14 @@ static unsigned long isolate_lru_pages(u
 			continue;

 		/*
+		 * To save a few cycles, the following pfn-based isolation
+		 * could be bypassed if the newly isolated page is no less
+		 * than the order aligned region.
+		 */
+		if (isolated_pages >= (1 << order))
+			continue;
+
+		/*
 		 * Attempt to take all pages in the order aligned region
 		 * surrounding the tag page.  Only take those pages of
 		 * the same active state as that tag page.  We may safely
@@ -1227,7 +1237,6 @@ static unsigned long isolate_lru_pages(u
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

Date: Tue, 15 Jul 2008 04:21:35 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 6/9] restore patch failure hunk of mlock-mlocked-pages-are-unevictable.patch
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715041910.F701.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: mlock-mlocked-pages-are-unevictable-resutore-patch-failure-hunk.patch
Against:  mmotm Jul 14
Applies after: mlock-mlocked-pages-are-unevictable-fix-fix-munlock-page-table-walk-now-requires-mm.patch

unevictable-lru-infrastructure-putback_lru_page-rework.patch and unevictable-lru-infrastructure-kill-unnecessary-lock_page.patch
makes one patch failure and two build error.
This patch restore these.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -577,11 +577,8 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
-		if (unlikely(!page_evictable(page, NULL))) {
-			unlock_page(page);
-			putback_lru_page(page);
-			continue;
-		}
+		if (unlikely(!page_evictable(page, NULL)))
+			goto cull_mlocked;
 
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
@@ -739,8 +736,8 @@ free_it:
 		continue;
 
 cull_mlocked:
-		if (putback_lru_page(page))
-			unlock_page(page);
+		unlock_page(page);
+		putback_lru_page(page);
 		continue;
 
 activate_locked:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A5E5C6B0072
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 23:28:16 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 8/8] extend PGVOLATILE vmstat to kswapd
Date: Thu,  3 Jan 2013 13:28:06 +0900
Message-Id: <1357187286-18759-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-1-git-send-email-minchan@kernel.org>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Now kswapd can discard volatile pages so let's cover it for vmstat.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vm_event_item.h |    3 ++-
 mm/mvolatile.c                |    5 ++++-
 mm/vmstat.c                   |    3 ++-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 721d096..4efa3bf 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -26,7 +26,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
 #ifdef CONFIG_VOLATILE_PAGE
-		PGVOLATILE,
+		PGVOLATILE_DIRECT,
+		PGVOLATILE_KSWAPD,
 #endif
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
diff --git a/mm/mvolatile.c b/mm/mvolatile.c
index 1c7bf5a..08a7eb3 100644
--- a/mm/mvolatile.c
+++ b/mm/mvolatile.c
@@ -246,7 +246,10 @@ int discard_volatile_page(struct page *page, enum ttu_flags ttu_flags)
 	if (try_to_volatile_page(page, ttu_flags)) {
 		if (page_freeze_refs(page, 1)) {
 			unlock_page(page);
-			count_vm_event(PGVOLATILE);
+			if (current_is_kswapd())
+				count_vm_event(PGVOLATILE_KSWAPD);
+			else
+				count_vm_event(PGVOLATILE_DIRECT);
 			return 1;
 		}
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 3d08e1a..416f550 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -754,7 +754,8 @@ const char * const vmstat_text[] = {
 	"pgmajfault",
 
 #ifdef CONFIG_VOLATILE_PAGE
-	"pgvolatile",
+	"pgvolatile_direct",
+	"pgvolatile_kswapd",
 #endif
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

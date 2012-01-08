Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 800316B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 02:05:05 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so2791092wib.14
        for <linux-mm@kvack.org>; Sat, 07 Jan 2012 23:05:03 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 8 Jan 2012 15:05:03 +0800
Message-ID: <CAJd=RBAqzawZ=jEFt7TrZgU0gaejMkfiBxzH7Y19qqNnsZrJGw@mail.gmail.com>
Subject: [PATCH] mm: vmscan: fix setting reclaim mode
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

The check for under memory pressure is corrected, then lumpy reclaim or
reclaim/compaction could be avoided either when for order-O reclaim or
when free pages are already low enough.


Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Sun Jan  8 13:22:12 2012
@@ -365,8 +365,7 @@ out:
 	return ret;
 }

-static void set_reclaim_mode(int priority, struct scan_control *sc,
-				   bool sync)
+static void set_reclaim_mode(int priority, struct scan_control *sc, bool sync)
 {
 	reclaim_mode_t syncmode = sync ? RECLAIM_MODE_SYNC : RECLAIM_MODE_ASYNC;

@@ -381,13 +380,12 @@ static void set_reclaim_mode(int priorit
 		sc->reclaim_mode = RECLAIM_MODE_LUMPYRECLAIM;

 	/*
-	 * Avoid using lumpy reclaim or reclaim/compaction if possible by
-	 * restricting when its set to either costly allocations or when
-	 * under memory pressure
+	 * Avoid lumpy reclaim or reclaim/compaction either
+	 * when for order-O reclaim or when under memory pressure
 	 */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
 		sc->reclaim_mode |= syncmode;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
+	else if (sc->order && priority >= DEF_PRIORITY - 2)
 		sc->reclaim_mode |= syncmode;
 	else
 		sc->reclaim_mode = RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

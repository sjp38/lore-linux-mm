Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id BE4C46B0062
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 23:36:57 -0500 (EST)
Received: by iacb35 with SMTP id b35so27619040iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 20:36:57 -0800 (PST)
Date: Wed, 28 Dec 2011 20:36:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/3] mm: cond_resched in scan_mapping_unevictable_pages
In-Reply-To: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112282035250.1362@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

scan_mapping_unevictable_pages() is used to make SysV SHM_LOCKed pages
evictable again once the shared memory is unlocked or destroyed (the
latter seems rather a waste of time, but meets internal expectations).
It does pagevec_lookup()s across the whole object: methinks a
cond_resched() every PAGEVEC_SIZE pages would be worthwhile.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm.orig/mm/vmscan.c	2011-12-28 16:49:36.000000000 -0800
+++ mmotm/mm/vmscan.c	2011-12-28 17:03:07.647220248 -0800
@@ -3583,8 +3583,8 @@ void scan_mapping_unevictable_pages(stru
 		pagevec_release(&pvec);
 
 		count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);
+		cond_resched();
 	}
-
 }
 
 static void warn_scan_unevictable_pages(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

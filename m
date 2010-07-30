Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9110C6B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 15:17:56 -0400 (EDT)
From: Jason Wessel <jason.wessel@windriver.com>
Subject: [PATCH 15/15] mm,kdb,kgdb: Add a debug reference for the kdb kmap usage
Date: Fri, 30 Jul 2010 14:17:36 -0500
Message-Id: <1280517456-1167-16-git-send-email-jason.wessel@windriver.com>
In-Reply-To: <1280517456-1167-1-git-send-email-jason.wessel@windriver.com>
References: <1280517456-1167-1-git-send-email-jason.wessel@windriver.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: kgdb-bugreport@lists.sourceforge.net, mingo@elte.hu, Jason Wessel <jason.wessel@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The kdb kmap should never get used outside of the kernel debugger
exception context.

Signed-off-by: Jason Wessel<jason.wessel@windriver.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Ingo Molnar <mingo@elte.hu>
CC: linux-mm@kvack.org
---
 mm/highmem.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 66baa20..7a0aa1b 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -26,6 +26,7 @@
 #include <linux/init.h>
 #include <linux/hash.h>
 #include <linux/highmem.h>
+#include <linux/kgdb.h>
 #include <asm/tlbflush.h>
 
 /*
@@ -470,6 +471,12 @@ void debug_kmap_atomic(enum km_type type)
 			warn_count--;
 		}
 	}
+#ifdef CONFIG_KGDB_KDB
+	if (unlikely(type == KM_KDB && atomic_read(&kgdb_active) == -1)) {
+		WARN_ON(1);
+		warn_count--;
+	}
+#endif /* CONFIG_KGDB_KDB */
 }
 
 #endif
-- 
1.6.4.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

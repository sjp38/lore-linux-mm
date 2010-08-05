Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2CAF66B02A5
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 10:37:32 -0400 (EDT)
From: Jason Wessel <jason.wessel@windriver.com>
Subject: [PATCH 14/17] mm,kdb,kgdb: Add a debug reference for the kdb kmap usage
Date: Thu,  5 Aug 2010 09:37:55 -0500
Message-Id: <1281019078-6636-15-git-send-email-jason.wessel@windriver.com>
In-Reply-To: <1281019078-6636-14-git-send-email-jason.wessel@windriver.com>
References: <1281019078-6636-1-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-2-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-3-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-4-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-5-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-6-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-7-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-8-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-9-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-10-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-11-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-12-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-13-git-send-email-jason.wessel@windriver.com>
 <1281019078-6636-14-git-send-email-jason.wessel@windriver.com>
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, Jason Wessel <jason.wessel@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
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
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

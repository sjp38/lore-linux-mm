Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9236B0083
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 21:26:07 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so11071322wgg.0
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 18:26:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si3993174wju.37.2014.11.23.18.26.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Nov 2014 18:26:05 -0800 (PST)
Message-ID: <1416795955.11084.11.camel@linux-t7sj.site>
Subject: [PATCH] mm,vmacache: count number of system-wide flushes
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sun, 23 Nov 2014 18:25:55 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>

These flushes deal with sequence number overflows, such
as for long lived threads. These are rare, but interesting
from a debugging PoV. As such, display the number of flushes
when vmacache debugging is enabled.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/vm_event_item.h | 1 +
 mm/vmacache.c                 | 2 ++
 mm/vmstat.c                   | 1 +
 3 files changed, 4 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 730334c..9246d32 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -90,6 +90,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_DEBUG_VM_VMACACHE
 		VMACACHE_FIND_CALLS,
 		VMACACHE_FIND_HITS,
+		VMACACHE_FULL_FLUSHES,
 #endif
 		NR_VM_EVENT_ITEMS
 };
diff --git a/mm/vmacache.c b/mm/vmacache.c
index 9f25af8..b6e3662 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -17,6 +17,8 @@ void vmacache_flush_all(struct mm_struct *mm)
 {
 	struct task_struct *g, *p;
 
+	count_vm_vmacache_event(VMACACHE_FULL_FLUSHES);
+
 	/*
 	 * Single threaded tasks need not iterate the entire
 	 * list of process. We can avoid the flushing as well
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1b12d39..10d7403 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -898,6 +898,7 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_DEBUG_VM_VMACACHE
 	"vmacache_find_calls",
 	"vmacache_find_hits",
+	"vmacache_full_flushes",
 #endif
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
-- 
1.8.4.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-Id: <20080605021504.502113040@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com>
Date: Thu, 05 Jun 2008 11:12:13 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 2/5] introduce get_vm_event().
Content-Disposition: inline; filename=02-get_vm_event.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

introduce get_vm_event() new function for easy use vm statics.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/vmstat.h |    7 ++++++-
 mm/vmstat.c            |   16 ++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

Index: b/include/linux/vmstat.h
===================================================================
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -98,6 +98,8 @@ static inline void vm_events_fold_cpu(in
 }
 #endif
 
+unsigned long get_vm_event(enum vm_event_item event_type);
+
 #else
 
 /* Disable counters */
@@ -119,7 +121,10 @@ static inline void all_vm_events(unsigne
 static inline void vm_events_fold_cpu(int cpu)
 {
 }
-
+static inline unsigned long get_vm_event(enum vm_event_item event_type)
+{
+	return 0;
+}
 #endif /* CONFIG_VM_EVENT_COUNTERS */
 
 #define __count_zone_vm_events(item, zone, delta) \
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -49,6 +49,22 @@ void all_vm_events(unsigned long *ret)
 }
 EXPORT_SYMBOL_GPL(all_vm_events);
 
+unsigned long get_vm_event(enum vm_event_item event_type)
+{
+	int cpu;
+	unsigned long ret = 0;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
+
+		ret += this->event[event_type];
+	}
+	put_online_cpus();
+
+	return ret;
+}
+
 #ifdef CONFIG_HOTPLUG
 /*
  * Fold the foreign cpu events into our own.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

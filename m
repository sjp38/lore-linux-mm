Message-Id: <20080719133256.868625855@jp.fujitsu.com>
References: <20080719132615.228311215@jp.fujitsu.com>
Date: Sat, 19 Jul 2008 22:26:16 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 1/3] introduce get_vm_event()
Content-Disposition: inline; filename=02-get_vm_event.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

changelog
========================================
  v7 -> v8
     o no change

  v6 -> v7
     o get_vm_stat: make cpu-unplug safety.

  v5 -> v6
     o created


introduce get_vm_event() new function for easy use vm statics.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 include/linux/vmstat.h |    7 ++++++-
 mm/vmstat.c            |   16 ++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

Index: b/include/linux/vmstat.h
===================================================================
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -108,6 +108,8 @@ static inline void vm_events_fold_cpu(in
 }
 #endif
 
+unsigned long get_vm_event(enum vm_event_item event_type);
+
 #else
 
 /* Disable counters */
@@ -129,7 +131,10 @@ static inline void all_vm_events(unsigne
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

Date: Sun, 04 May 2008 21:57:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [-mm][PATCH 2/5] introduce get_vm_event()
In-Reply-To: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080504215602.8F58.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

introduce get_vm_event() new function for easy use vm statics.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/vmstat.h |    7 ++++++-
 mm/vmstat.c            |   14 ++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

Index: b/include/linux/vmstat.h
===================================================================
--- a/include/linux/vmstat.h	2008-05-02 23:40:39.000000000 +0900
+++ b/include/linux/vmstat.h	2008-05-03 00:23:17.000000000 +0900
@@ -92,6 +92,8 @@ static inline void vm_events_fold_cpu(in
 }
 #endif
 
+unsigned long get_vm_event(enum vm_event_item event_type);
+
 #else
 
 /* Disable counters */
@@ -113,7 +115,10 @@ static inline void all_vm_events(unsigne
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
--- a/mm/vmstat.c	2008-05-02 23:40:39.000000000 +0900
+++ b/mm/vmstat.c	2008-05-02 23:43:28.000000000 +0900
@@ -46,6 +46,20 @@ void all_vm_events(unsigned long *ret)
 }
 EXPORT_SYMBOL_GPL(all_vm_events);
 
+unsigned long get_vm_event(enum vm_event_item event_type)
+{
+	int cpu;
+	unsigned long ret = 0;
+
+	for_each_cpu_mask(cpu, cpu_online_map) {
+		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
+
+		ret += this->event[event_type];
+	}
+
+	return ret;
+}
+
 #ifdef CONFIG_HOTPLUG
 /*
  * Fold the foreign cpu events into our own.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

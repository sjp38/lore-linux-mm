Date: Tue, 18 Sep 2007 09:44:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/4] oom: save zonelist pointer for oom killer calls
In-Reply-To: <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

OOM killer synchronization should be done with zone granularity so that
memory policy and cpuset allocations may have their corresponding zones
locked and allow parallel kills for other OOM conditions that may exist
elsewhere in the system.  DMA allocations can be targeted at the zone
level, which would not be possible if locking was done in nodes or
globally.

A pointer to the OOM-triggering zonelist is saved in a linked list.  Any
time there is an OOM condition, all zones in the zonelist are checked
against the zonelists stored in the OOM killer lists.  If the OOM killer
has already been called for an allocation that includes one of these
zones, the "trylock" fails and returns non-zero.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    3 ++
 mm/oom_kill.c       |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -20,6 +20,9 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
+extern int oom_killer_trylock(struct zonelist *zonelist);
+extern void oom_killer_unlock(const struct zonelist *zonelist);
+
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -26,6 +26,13 @@
 #include <linux/module.h>
 #include <linux/notifier.h>
 
+struct oom_zonelist {
+	struct zonelist *zonelist;
+	struct list_head list;
+};
+static LIST_HEAD(zonelists);
+static DEFINE_MUTEX(oom_zonelist_mutex);
+
 int sysctl_panic_on_oom;
 /* #define DEBUG */
 
@@ -381,6 +388,68 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+/*
+ * Call with oom_zonelist_mutex held.
+ */
+static int is_zone_locked(const struct zone *zone)
+{
+	struct oom_zonelist *oom_zl;
+	int i;
+
+	list_for_each_entry(oom_zl, &zonelists, list)	
+		for (i = 0; oom_zl->zonelist->zones[i]; i++)
+			if (zone == oom_zl->zonelist->zones[i])
+				return 1;
+	return 0;
+}
+
+/*
+ * Try to acquire the OOM killer lock for the zones in zonelist.  Returns
+ * non-zero if a parallel OOM killing is already taking place that includes a
+ * zone in the zonelist.
+ */
+int oom_killer_trylock(struct zonelist *zonelist)
+{
+	struct oom_zonelist *oom_zl;
+	int ret = 0;
+	int i;
+
+	mutex_lock(&oom_zonelist_mutex);
+	for (i = 0; zonelist->zones[i]; i++)
+		if (is_zone_locked(zonelist->zones[i])) {
+			ret = 1;
+			goto out;
+		}
+
+	oom_zl = kzalloc(sizeof(*oom_zl), GFP_KERNEL);
+	if (!oom_zl)
+		goto out;
+
+	oom_zl->zonelist = zonelist;
+	list_add(&oom_zl->list, &zonelists);
+out:
+	mutex_unlock(&oom_zonelist_mutex);
+	return ret;
+}
+
+/*
+ * Removes the zonelist from the list so that future allocations that include
+ * its zones can successfully call the OOM killer.
+ */
+void oom_killer_unlock(const struct zonelist *zonelist)
+{
+	struct oom_zonelist *oom_zl;
+
+	mutex_lock(&oom_zonelist_mutex);
+	list_for_each_entry(oom_zl, &zonelists, list)
+		if (zonelist == oom_zl->zonelist) {
+			list_del(&oom_zl->list);
+			break;
+		}
+	mutex_unlock(&oom_zonelist_mutex);
+	kfree(oom_zl);
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 20 Sep 2007 13:23:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 4/9] oom: add per-zone locking
In-Reply-To: <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

OOM killer synchronization should be done with zone granularity so that
memory policy and cpuset allocations may have their corresponding zones
locked and allow parallel kills for other OOM conditions that may exist
elsewhere in the system.  DMA allocations can be targeted at the zone
level, which would not be possible if locking was done in nodes or
globally.

Synchronization shall be done with a variation of "trylocks."  The goal
is to put the current task to sleep and restart the failed allocation
attempt later if the trylock fails.  Otherwise, the OOM killer is
invoked.

Each zone in the zonelist that __alloc_pages() was called with is checked
for the newly-introduced ZONE_OOM_LOCKED flag.  If any zone has this flag
present, the "trylock" to serialize the OOM killer fails and returns
zero.  Otherwise, all the zones have ZONE_OOM_LOCKED set and the
try_set_zone_oom() function returns non-zero.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h |    5 ++++
 include/linux/oom.h    |    3 ++
 mm/oom_kill.c          |   52 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -313,6 +313,7 @@ struct zone {
 typedef enum {
 	ZONE_ALL_UNRECLAIMABLE,		/* all pages pinned */
 	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
+	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
 } zone_flags_t;
 
 static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
@@ -332,6 +333,10 @@ static inline int zone_is_reclaim_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
 }
+static inline int zone_is_oom_locked(const struct zone *zone)
+{
+	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
+}
 
 /*
  * The "priority" of VM scanning is how much of the queues we will scan in one
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -20,6 +20,9 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
+extern int try_set_zone_oom(struct zonelist *zonelist);
+extern void clear_zonelist_oom(struct zonelist *zonelist);
+
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -27,6 +27,7 @@
 #include <linux/notifier.h>
 
 int sysctl_panic_on_oom;
+static DEFINE_MUTEX(zone_scan_mutex);
 /* #define DEBUG */
 
 /**
@@ -381,6 +382,57 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+/*
+ * Try to acquire the OOM killer lock for the zones in zonelist.  Returns zero
+ * if a parallel OOM killing is already taking place that includes a zone in
+ * the zonelist.  Otherwise, locks all zones in the zonelist and returns 1.
+ */
+int try_set_zone_oom(struct zonelist *zonelist)
+{
+	struct zone **z;
+	int ret = 1;
+
+	z = zonelist->zones;
+
+	mutex_lock(&zone_scan_mutex);
+	do {
+		if (zone_is_oom_locked(*z)) {
+			ret = 0;
+			goto out;
+		}
+	} while (*(++z) != NULL);
+
+	/*
+	 * Lock each zone in the zonelist under zone_scan_mutex so a parallel
+	 * invocation of try_set_zone_oom() doesn't succeed when it shouldn't.
+	 */
+	z = zonelist->zones;
+	do {
+		zone_set_flag(*z, ZONE_OOM_LOCKED);
+	} while (*(++z) != NULL);
+out:
+	mutex_unlock(&zone_scan_mutex);
+	return ret;
+}
+
+/*
+ * Clears the ZONE_OOM_LOCKED flag for all zones in the zonelist so that failed
+ * allocation attempts with zonelists containing them may now recall the OOM
+ * killer, if necessary.
+ */
+void clear_zonelist_oom(struct zonelist *zonelist)
+{
+	struct zone **z;
+
+	z = zonelist->zones;
+
+	mutex_lock(&zone_scan_mutex);
+	do {
+		zone_clear_flag(*z, ZONE_OOM_LOCKED);
+	} while (*(++z) != NULL);
+	mutex_unlock(&zone_scan_mutex);
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

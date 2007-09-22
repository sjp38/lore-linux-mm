Date: Sat, 22 Sep 2007 10:47:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 3/5] oom: convert zone_scan_lock from mutex to spinlock
In-Reply-To: <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's no reason to sleep in try_set_zone_oom() or clear_zonelist_oom()
if the lock can't be acquired; it will be available soon enough once
the zonelist scanning is done.  All other threads waiting for the OOM
killer are also contingent on the exiting task being able to acquire
the lock in clear_zonelist_oom() so it doesn't make sense to put it
to sleep.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -28,7 +28,7 @@
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
-static DEFINE_MUTEX(zone_scan_mutex);
+static DEFINE_SPINLOCK(zone_scan_mutex);
 /* #define DEBUG */
 
 /**
@@ -403,7 +403,7 @@ int try_set_zone_oom(struct zonelist *zonelist)
 
 	z = zonelist->zones;
 
-	mutex_lock(&zone_scan_mutex);
+	spin_lock(&zone_scan_mutex);
 	do {
 		if (zone_is_oom_locked(*z)) {
 			ret = 0;
@@ -420,7 +420,7 @@ int try_set_zone_oom(struct zonelist *zonelist)
 		zone_set_flag(*z, ZONE_OOM_LOCKED);
 	} while (*(++z) != NULL);
 out:
-	mutex_unlock(&zone_scan_mutex);
+	spin_unlock(&zone_scan_mutex);
 	return ret;
 }
 
@@ -435,11 +435,11 @@ void clear_zonelist_oom(struct zonelist *zonelist)
 
 	z = zonelist->zones;
 
-	mutex_lock(&zone_scan_mutex);
+	spin_lock(&zone_scan_mutex);
 	do {
 		zone_clear_flag(*z, ZONE_OOM_LOCKED);
 	} while (*(++z) != NULL);
-	mutex_unlock(&zone_scan_mutex);
+	spin_unlock(&zone_scan_mutex);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

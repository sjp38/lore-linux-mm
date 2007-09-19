Date: Wed, 19 Sep 2007 11:24:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 7/8] oom: only kill tasks that share zones with zonelist
In-Reply-To: <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is only helpful to OOM kill tasks that share a zone with at least one
zone in the zonelist passed to __alloc_pages().  The current task, of
course, always shares zones with this zonelist so it will always be
selected if it is killable and no other task can be found.  Otherwise, we
panic.

To determine whether a candidate task shares a zone with a member of the
zonelist, it is necessary to iterate through the VMA's of each task.
This isn't as painful as it first appears since usually a VMA's zone
will intersect with the OOM-triggering zonelist early in the scan; in
that case, it is not necessary to continue scanning for that task.

mm->mmap_sem is required to read scan through the VMA's but it may not
immediately be available because it is write-locked.  Instead of
sleeping on the semaphore, we simply score the task using the normal
heuristics and assume it will be beneficial to kill the task.  We are
not assured that the write-lock will ever be released in an OOM
condition and mmap_sem is frequently contended.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 56 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -25,6 +25,7 @@
 #include <linux/cpuset.h>
 #include <linux/module.h>
 #include <linux/notifier.h>
+#include <linux/pfn.h>
 
 struct oom_zonelist {
 	struct zonelist *zonelist;
@@ -201,30 +202,80 @@ static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 }
 
 /*
+ * Returns non-zero if zone is found in zonelist; otherwise, returns zero.
+ */
+static int is_zone_in_zonelist(struct zone *zone, struct zonelist *zonelist)
+{
+	struct zone **z;
+
+	z = zonelist->zones;
+	do {
+		if (zone == *z)
+			return 1;
+	} while (*(++z) != NULL);
+	return 0;
+}
+
+/*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'. We expect the caller will lock the tasklist.
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned long *ppoints)
+static struct task_struct *select_bad_process(struct zonelist *zonelist,
+				gfp_t gfp_mask, unsigned long *ppoints)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
 	struct timespec uptime;
 	*ppoints = 0;
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	do_each_thread(g, p) {
 		unsigned long points;
+		int has_zone = 0;
 
+		/* skip the init task */
+		if (is_init(p))
+			continue;
 		/*
 		 * skip kernel threads and tasks which have already released
 		 * their mm.
 		 */
-		if (!p->mm)
+		mm = get_task_mm(p);
+		if (!mm)
 			continue;
-		/* skip the init task */
-		if (is_init(p))
+
+		/*
+		 * If mm->mmap_sem is write-locked, the task is assumed to be
+		 * a worthwhile target.  It may not be possible for the task
+		 * to ever unlock.
+		 */
+		if (!down_read_trylock(&mm->mmap_sem))
+			goto no_zonescan;
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			unsigned long pfn;
+			struct zone *zone;
+
+			pfn = PFN_DOWN(vma->vm_start);
+			zone = page_zone(pfn_to_page(pfn));
+
+			if (is_zone_in_zonelist(zone, zonelist)) {
+				has_zone = 1;
+				break;
+			}
+		}
+		up_read(&mm->mmap_sem);
+no_zonescan:
+		mmput(mm);
+
+		/*
+		 * It will not do any good to kill p if it does not share any
+		 * zones with the zonelist in our allocation attempt.
+		 */
+		if (!has_zone)
 			continue;
 
 		/*
@@ -525,7 +576,7 @@ retry:
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.
 		 */
-		p = select_bad_process(&points);
+		p = select_bad_process(zonelist, gfp_mask, &points);
 
 		if (PTR_ERR(p) == -1UL)
 			goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD976B01C6
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:12:09 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 03/96] eclone (3/11): Define set_pidmap() function
Date: Wed, 17 Mar 2010 12:07:51 -0400
Message-Id: <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Sukadev Bhattiprolu <sukadev@us.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

Define a set_pidmap() interface which is like alloc_pidmap() only that
caller specifies the pid number to be assigned.

Changelog[v13]:
	- Don't let do_alloc_pidmap return 0 if it failed to find a pid.
Changelog[v9]:
	- Completely rewrote this patch based on Eric Biederman's code.
Changelog[v7]:
        - [Eric Biederman] Generalize alloc_pidmap() to take a range of pids.
Changelog[v6]:
        - Separate target_pid > 0 case to minimize the number of checks needed.
Changelog[v3]:
        - (Eric Biederman): Avoid set_pidmap() function. Added couple of
          checks for target_pid in alloc_pidmap() itself.
Changelog[v2]:
        - (Serge Hallyn) Check for 'pid < 0' in set_pidmap().(Code
          actually checks for 'pid <= 0' for completeness).

Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Reviewed-by: Oren Laadan <orenl@cs.columbia.edu>
---
 kernel/pid.c |   41 +++++++++++++++++++++++++++++++++--------
 1 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/kernel/pid.c b/kernel/pid.c
index 252babf..1f15bb6 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -146,17 +146,18 @@ static int alloc_pidmap_page(struct pidmap *map)
 	return 0;
 }
 
-static int alloc_pidmap(struct pid_namespace *pid_ns)
+static int do_alloc_pidmap(struct pid_namespace *pid_ns, int last, int min,
+		int max)
 {
-	int i, offset, max_scan, pid, last = pid_ns->last_pid;
+	int i, offset, max_scan, pid;
 	struct pidmap *map;
 
 	pid = last + 1;
 	if (pid >= pid_max)
-		pid = RESERVED_PIDS;
+		pid = min;
 	offset = pid & BITS_PER_PAGE_MASK;
 	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
-	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
+	max_scan = (max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
 	for (i = 0; i <= max_scan; ++i) {
 		if (unlikely(!map->page))
 			if (alloc_pidmap_page(map) < 0)
@@ -165,7 +166,6 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 			do {
 				if (!test_and_set_bit(offset, map->page)) {
 					atomic_dec(&map->nr_free);
-					pid_ns->last_pid = pid;
 					return pid;
 				}
 				offset = find_next_offset(map, offset);
@@ -176,16 +176,16 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 			 * bitmap block and the final block was the same
 			 * as the starting point, pid is before last_pid.
 			 */
-			} while (offset < BITS_PER_PAGE && pid < pid_max &&
+			} while (offset < BITS_PER_PAGE && pid < max &&
 					(i != max_scan || pid < last ||
 					    !((last+1) & BITS_PER_PAGE_MASK)));
 		}
-		if (map < &pid_ns->pidmap[(pid_max-1)/BITS_PER_PAGE]) {
+		if (map < &pid_ns->pidmap[(max-1)/BITS_PER_PAGE]) {
 			++map;
 			offset = 0;
 		} else {
 			map = &pid_ns->pidmap[0];
-			offset = RESERVED_PIDS;
+			offset = min;
 			if (unlikely(last == offset))
 				break;
 		}
@@ -194,6 +194,31 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	return -EBUSY;
 }
 
+static int alloc_pidmap(struct pid_namespace *pid_ns)
+{
+	int nr;
+
+	nr = do_alloc_pidmap(pid_ns, pid_ns->last_pid, RESERVED_PIDS, pid_max);
+	if (nr >= 0)
+		pid_ns->last_pid = nr;
+	return nr;
+}
+
+static int set_pidmap(struct pid_namespace *pid_ns, int target)
+{
+	if (!target)
+		return alloc_pidmap(pid_ns);
+
+	if (target >= pid_max)
+		return -EINVAL;
+
+	if ((target < 0) || (target < RESERVED_PIDS &&
+				pid_ns->last_pid >= RESERVED_PIDS))
+		return -EINVAL;
+
+	return do_alloc_pidmap(pid_ns, target - 1, target, target + 1);
+}
+
 int next_pidmap(struct pid_namespace *pid_ns, int last)
 {
 	int offset;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

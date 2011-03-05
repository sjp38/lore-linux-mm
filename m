Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BF62B8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 19:51:37 -0500 (EST)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] mm: skip zombie in OOM-killer
Date: Sat,  5 Mar 2011 03:51:47 +0300
Message-Id: <1299286307-4386-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, avagin@openvz.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When we check that task has flag TIF_MEMDIE, we forgot check that
it has mm. A task may be zombie and a parent may wait a memor.

v2: Check that task doesn't have mm one time and skip it immediately

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 mm/oom_kill.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7dcca55..b1ce3ba 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -299,6 +299,9 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	for_each_process(p) {
 		unsigned int points;
 
+		if (!p->mm)
+			continue;
+
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
 
@@ -324,7 +327,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
+		if (thread_group_empty(p) && (p->flags & PF_EXITING)) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

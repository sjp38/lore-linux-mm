Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1946B025E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 22:01:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h144so1073821ita.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 19:01:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b5si11048427oee.40.2016.05.20.19.01.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 19:01:03 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/2] mm,oom: Remove unused argument from oom_scan_process_thread().
Date: Sat, 21 May 2016 11:00:41 +0900
Message-Id: <1463796041-7889-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org, rientjes@google.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

oom_scan_process_thread() does not use totalpages argument.
oom_badness() uses it.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h | 2 +-
 mm/memcontrol.c     | 2 +-
 mm/oom_kill.c       | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8346952..c63de01 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -90,7 +90,7 @@ extern void check_panic_on_oom(struct oom_control *oc,
 			       struct mem_cgroup *memcg);
 
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-		struct task_struct *task, unsigned long totalpages);
+					       struct task_struct *task);
 
 extern bool out_of_memory(struct oom_control *oc);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab574d8..49cee6f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1287,7 +1287,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it))) {
-			switch (oom_scan_process_thread(&oc, task, totalpages)) {
+			switch (oom_scan_process_thread(&oc, task)) {
 			case OOM_SCAN_SELECT:
 				if (chosen)
 					put_task_struct(chosen);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8e151d0..743afdd 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -274,7 +274,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 #endif
 
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-			struct task_struct *task, unsigned long totalpages)
+					struct task_struct *task)
 {
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		return OOM_SCAN_CONTINUE;
@@ -311,7 +311,7 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 	for_each_process(p) {
 		unsigned int points;
 
-		switch (oom_scan_process_thread(oc, p, totalpages)) {
+		switch (oom_scan_process_thread(oc, p)) {
 		case OOM_SCAN_SELECT:
 			chosen = p;
 			chosen_points = ULONG_MAX;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

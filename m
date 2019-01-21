Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 21 Jan 2019 10:50:31 -0800
Message-Id: <20190121185033.161015-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH v2 1/2] mm, oom: fix use-after-free in oom_kill_process
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, syzbot+7fbbfa368521945f0e3d@syzkaller.appspotmail.com, Michal Hocko <mhocko@suse.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Syzbot instance running on upstream kernel found a use-after-free bug
in oom_kill_process. On further inspection it seems like the process
selected to be oom-killed has exited even before reaching
read_lock(&tasklist_lock) in oom_kill_process(). More specifically the
tsk->usage is 1 which is due to get_task_struct() in oom_evaluate_task()
and the put_task_struct within for_each_thread() frees the tsk and
for_each_thread() tries to access the tsk. The easiest fix is to do
get/put across the for_each_thread() on the selected task.

Now the next question is should we continue with the oom-kill as the
previously selected task has exited? However before adding more
complexity and heuristics, let's answer why we even look at the
children of oom-kill selected task? The select_bad_process() has already
selected the worst process in the system/memcg. Due to race, the
selected process might not be the worst at the kill time but does that
matter? The userspace can use the oom_score_adj interface to prefer
children to be killed before the parent. I looked at the history but it
seems like this is there before git history.

Reported-by: syzbot+7fbbfa368521945f0e3d@syzkaller.appspotmail.com
Fixes: 6b0c81b3be11 ("mm, oom: reduce dependency on tasklist_lock")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Reviewed-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: stable@kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
Changelog since v1:
- Improved the commit message and added the Reported-by and Fixes tags.

 mm/oom_kill.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0930b4365be7..1a007dae1e8f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -981,6 +981,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 * still freeing memory.
 	 */
 	read_lock(&tasklist_lock);
+
+	/*
+	 * The task 'p' might have already exited before reaching here. The
+	 * put_task_struct() will free task_struct 'p' while the loop still try
+	 * to access the field of 'p', so, get an extra reference.
+	 */
+	get_task_struct(p);
 	for_each_thread(p, t) {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
@@ -1000,6 +1007,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 			}
 		}
 	}
+	put_task_struct(p);
 	read_unlock(&tasklist_lock);
 
 	/*
-- 
2.20.1.321.g9e740568ce-goog

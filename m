Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B99E8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so376858edd.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bz3-v6sor18549802ejb.17.2019.01.07.06.39.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:42 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, oom: marks all killed tasks as oom victims
Date: Mon,  7 Jan 2019 15:38:01 +0100
Message-Id: <20190107143802.16847-2-mhocko@kernel.org>
In-Reply-To: <20190107143802.16847-1-mhocko@kernel.org>
References: <20190107143802.16847-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Historically we have called mark_oom_victim only to the main task
selected as the oom victim because oom victims have access to memory
reserves and granting the access to all killed tasks could deplete
memory reserves very quickly and cause even larger problems.

Since only a partial access to memory reserves is allowed there is no
longer this risk and so all tasks killed along with the oom victim
can be considered as well.

The primary motivation for that is that process groups which do not
shared signals would behave more like standard thread groups wrt oom
handling (aka tsk_is_oom_victim will work the same way for them).

- Use find_lock_task_mm to stabilize mm as suggested by Tetsuo

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9edb1a..0246c7a4e44e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -892,6 +892,7 @@ static void __oom_kill_process(struct task_struct *victim)
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
+		struct task_struct *t;
 		if (!process_shares_mm(p, mm))
 			continue;
 		if (same_thread_group(p, victim))
@@ -911,6 +912,11 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_PRIV, p, PIDTYPE_TGID);
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		mark_oom_victim(t);
+		task_unlock(t);
 	}
 	rcu_read_unlock();
 
-- 
2.20.1

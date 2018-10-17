Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8036B0280
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 06:06:55 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c21-v6so24348554ioi.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:06:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c5-v6si12604709jae.126.2018.10.17.03.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 03:06:53 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no eligible task.
Date: Wed, 17 Oct 2018 19:06:22 +0900
Message-Id: <1539770782-3343-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

syzbot is hitting RCU stall at shmem_fault() [1].
This is because memcg-OOM events with no eligible task (current thread
is marked as OOM-unkillable) continued calling dump_header() from
out_of_memory() enabled by commit 3100dab2aa09dc6e ("mm: memcontrol:
print proper OOM header when no eligible victim left.").

Michal proposed ratelimiting dump_header() [2]. But I don't think that
that patch is appropriate because that patch does not ratelimit

  "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
  "Out of memory and no killable processes...\n"

messages which can be printed for every few milliseconds (i.e. effectively
denial of service for console users) until the OOM situation is solved.

Let's make sure that next dump_header() waits for at least 60 seconds from
previous "Out of memory and no killable processes..." message. Michal is
thinking that any interval is meaningless without knowing the printk()
throughput. But since printk() is synchronous unless handed over to
somebody else by commit dbdda842fe96f893 ("printk: Add console owner and
waiter logic to load balance console writes"), it is likely that all OOM
messages from this out_of_memory() request is already flushed to consoles
when pr_warn("Out of memory and no killable processes...\n") returned.
Thus, we will be able to allow console users to do what they need to do.

To summarize, this patch allows threads in requested memcg to complete
memory allocation requests for doing recovery operation, and also allows
administrators to manually do recovery operation from console if
OOM-unkillable thread is failing to solve the OOM situation automatically.

[1] https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64
[2] https://lkml.kernel.org/r/20181010151135.25766-1-mhocko@kernel.org

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..9056f9b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1106,6 +1106,11 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! */
 	if (!oc->chosen) {
+		static unsigned long last_warned;
+
+		if ((is_sysrq_oom(oc) || is_memcg_oom(oc)) &&
+		    time_in_range(jiffies, last_warned, last_warned + 60 * HZ))
+			return false;
 		dump_header(oc, NULL);
 		pr_warn("Out of memory and no killable processes...\n");
 		/*
@@ -1115,6 +1120,7 @@ bool out_of_memory(struct oom_control *oc)
 		 */
 		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
 			panic("System is deadlocked on memory\n");
+		last_warned = jiffies;
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-- 
1.8.3.1

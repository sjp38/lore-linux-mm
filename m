Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E9B226B0085
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 10:25:58 -0500 (EST)
Received: by pxi12 with SMTP id 12so150914pxi.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 07:25:57 -0800 (PST)
Subject: [PATCH v3]mm/oom-kill: direct hardware access processes should get
 bonus
From: "Figo.zhang" <figo1802@gmail.com>
In-Reply-To: <1289402093.10699.25.camel@localhost.localdomain>
References: <1288662213.10103.2.camel@localhost.localdomain>
	 <1289305468.10699.2.camel@localhost.localdomain>
	 <1289402093.10699.25.camel@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 23:24:26 +0800
Message-ID: <1289402666.10699.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "rientjes@google.com" <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Figo.zhang" <zhangtianfei@leadcoretech.com>
List-ID: <linux-mm.kvack.org>

the victim should not directly access hardware devices like Xorg server,
because the hardware could be left in an unpredictable state, although 
user-application can set /proc/pid/oom_score_adj to protect it. so i think
those processes should get bonus for protection.

in v2, fix the incorrect comment.
in v3, change the divided the badness score by 4, like old heuristic for protection. we just
want the oom_killer don't select Root/RESOURCE/RAWIO process as possible.

suppose that if a user process A such as email cleint "evolution" and a process B with
ditecly hareware access such as "Xorg", they have eat the equal memory (the badness score is 
the same),so which process are you want to kill? so in new heuristic, it will kill the process B.
but in reality, we want to kill process A.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
mm/oom_kill.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4029583..f43d759 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -202,6 +202,15 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 		points -= 30;
 
 	/*
+	 * Root and direct hareware access processes are usually more 
+	 * important, so they should get bonus for protection. 
+	 */
+	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
+	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
+	    has_capability_noaudit(p, CAP_SYS_RAWIO))
+		points /= 4;
+
+	/*
 	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
 	 * either completely disable oom killing or always prefer a certain
 	 * task.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C62316B00A7
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 07:25:31 -0500 (EST)
Received: by vws18 with SMTP id 18so1986185vws.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 04:25:30 -0800 (PST)
Subject: [PATCH v2]mm/oom-kill: direct hardware access processes should get
 bonus
From: "Figo.zhang" <figo1802@gmail.com>
In-Reply-To: <1288662213.10103.2.camel@localhost.localdomain>
References: <1288662213.10103.2.camel@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Nov 2010 20:24:28 +0800
Message-ID: <1289305468.10699.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "rientjes@google.com" <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

 
the victim should not directly access hardware devices like Xorg server,
because the hardware could be left in an unpredictable state, although 
user-application can set /proc/pid/oom_score_adj to protect it. so i think
those processes should get 3% bonus for protection.

in v2, fix the incorrect comment.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
mm/oom_kill.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4029583..9b06f56 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -196,9 +196,12 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 
 	/*
 	 * Root processes get 3% bonus, just like the __vm_enough_memory()
-	 * implementation used by LSMs.
+	 * implementation used by LSMs. And direct hardware access processes
+	 * also get 3% bonus.
 	 */
-	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
+	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
+	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
+	    has_capability_noaudit(p, CAP_SYS_RAWIO))
 		points -= 30;
 
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

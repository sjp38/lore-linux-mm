Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BD7CE8D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 21:49:55 -0400 (EDT)
Received: by vws18 with SMTP id 18so4388168vws.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 18:45:08 -0700 (PDT)
Subject: [PATCH]oom-kill: direct hardware access processes should get bonus
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Nov 2010 09:43:33 +0800
Message-ID: <1288662213.10103.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "rientjes@google.com" <rientjes@google.com>
List-ID: <linux-mm.kvack.org>


the victim should not directly access hardware devices like Xorg server,
because the hardware could be left in an unpredictable state, although 
user-application can set /proc/pid/oom_score_adj to protect it. so i think
those processes should get 3% bonus for protection.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
---
mm/oom_kill.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4029583..df6a9da 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -195,10 +195,12 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	task_unlock(p);
 
 	/*
-	 * Root processes get 3% bonus, just like the __vm_enough_memory()
-	 * implementation used by LSMs.
+	 * Root and direct hardware access processes get 3% bonus, just like the
+	 * __vm_enough_memory() implementation used by LSMs.
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

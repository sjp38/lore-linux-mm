Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 14F466B00A5
	for <linux-mm@kvack.org>; Tue, 26 May 2015 13:02:17 -0400 (EDT)
Received: by wizk4 with SMTP id k4so84400871wiz.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:02:16 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id ui9si17561784wjc.132.2015.05.26.10.02.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 10:02:15 -0700 (PDT)
Received: by wifw1 with SMTP id w1so38594708wif.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:02:14 -0700 (PDT)
Date: Tue, 26 May 2015 19:02:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150526170213.GB14955@dhcp22.suse.cz>
References: <201505252333.FJG56590.OOFSHQMOJtFFVL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505252333.FJG56590.OOFSHQMOJtFFVL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Mon 25-05-15 23:33:31, Tetsuo Handa wrote:
> >From 3728807fe66ebc24a8a28455593754b9532bbe74 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 25 May 2015 22:26:07 +0900
> Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
> 
> If the mm struct which the OOM victim is using is shared by e.g. 1000
> threads, and the lock dependency prevents all threads except the OOM
> victim thread from terminating until they get TIF_MEMDIE flag, the OOM
> killer will be invoked for 1000 times on this mm struct. As a result,
> the kernel would emit
> 
>   "Kill process %d (%s) sharing same memory\n"
> 
> line for 1000 * 1000 / 2 times. But once these threads got pending SIGKILL,
> emitting this information is nothing but noise. This patch filters them.

OK, I can see this might be really annoying. But reducing this message
will not help much because it is the dump_header which generates a lot
of output. And there is clearly no reason to treat the selected victim
any differently than the current so why not simply do the following
instead?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5cfda39b3268..a67ce18b4b35 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -505,7 +505,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
+	if (p->mm && (fatal_signal_pending(p) || task_will_free_mem(p))) {
 		mark_oom_victim(p);
 		task_unlock(p);
 		put_task_struct(p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 706F36B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 07:52:30 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so7776951pdi.31
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:52:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id vy7si29117122pbc.187.2014.12.23.04.52.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 04:52:28 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
	<20141222202511.GA9485@dhcp22.suse.cz>
	<201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
	<20141223095159.GA28549@dhcp22.suse.cz>
	<201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
In-Reply-To: <201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
Message-Id: <201412232057.CID73463.FJFOtFLSOOVHQM@I-love.SAKURA.ne.jp>
Date: Tue, 23 Dec 2014 20:57:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Tetsuo Handa wrote:
> If such a delay is theoretically impossible, I'm OK with your patch.
> 

Oops, I forgot to mention that task_unlock(p) should be called before
put_task_struct(p), in case p->usage == 1 at put_task_struct(p).

 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	if (task_will_free_mem(p)) {
+	task_lock(p);
+	if (p->mm && task_will_free_mem(p)) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
 		put_task_struct(p);
+		task_unlock(p);
 		return;
 	}
+	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

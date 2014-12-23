Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6D96B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 07:22:30 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so7779652pad.41
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:22:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id gr3si28936643pbc.207.2014.12.23.04.22.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 04:22:28 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
	<201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
	<20141222202511.GA9485@dhcp22.suse.cz>
	<201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
	<20141223095159.GA28549@dhcp22.suse.cz>
In-Reply-To: <20141223095159.GA28549@dhcp22.suse.cz>
Message-Id: <201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
Date: Tue, 23 Dec 2014 20:46:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> > Also, why not to call set_tsk_thread_flag() and do_send_sig_info() together
> > like below
> 
> What would be an advantage? I am not really sure whether the two locks
> might nest as well.

I imagined that current thread sets TIF_MEMDIE on a victim thread, then
sleeps for 30 seconds immediately after task_unlock() (it's an overdone
delay), and finally sets SIGKILL on that victim thread. If such a delay
happened, that victim thread is free to abuse TIF_MEMDIE for that period.
Thus, I thought sending SIGKILL followed by setting TIF_MEMDIE is better.

 	rcu_read_unlock();
 
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	task_lock(victim);
+	if (victim->mm)
+		set_tsk_thread_flag(victim, TIF_MEMDIE);
+	task_unlock(victim);
 	put_task_struct(victim);

If such a delay is theoretically impossible, I'm OK with your patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

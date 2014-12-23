Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 98A916B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 20:52:29 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so6955718pab.16
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 17:52:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id zs6si27371816pac.109.2014.12.22.17.52.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 17:52:27 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
	<20141219124903.GB18397@dhcp22.suse.cz>
	<201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
	<201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
	<20141222202511.GA9485@dhcp22.suse.cz>
In-Reply-To: <20141222202511.GA9485@dhcp22.suse.cz>
Message-Id: <201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
Date: Tue, 23 Dec 2014 10:00:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> OOM killer tries to exlude tasks which do not have mm_struct associated
s/exlude/exclude/

> Fix this by checking task->mm and setting TIF_MEMDIE flag under task_lock
> which will serialize the OOM killer with exit_mm which sets task->mm to
> NULL.
Nice idea.

By the way, find_lock_task_mm(victim) may succeed if victim->mm == NULL and
one of threads in victim thread-group has non-NULL mm. That case is handled
by victim != p branch below. But where was p->signal->oom_score_adj !=
OOM_SCORE_ADJ_MIN checked? (In other words, don't we need to check like
t->mm && t->signal->oom_score_adj != OOM_SCORE_ADJ_MIN at find_lock_task_mm()
for OOM-kill case?)

Also, why not to call set_tsk_thread_flag() and do_send_sig_info() together
like below

 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
 		return;
 	} else if (victim != p) {
 		get_task_struct(p);
 		put_task_struct(victim);
 		victim = p;
 	}
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
+	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
 	task_unlock(victim);

than wait for for_each_process() loop in case current task went to sleep
immediately after task_unlock(victim)? Or is there a reason we had been
setting TIF_MEMDIE after the for_each_process() loop? If the reason was
to minimize the duration of OOM killer being disabled due to TIF_MEMDIE,
shouldn't we do like below?

 	rcu_read_unlock();
 
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	task_lock(victim);
+	if (victim->mm)
+		set_tsk_thread_flag(victim, TIF_MEMDIE);
+	task_unlock(victim);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

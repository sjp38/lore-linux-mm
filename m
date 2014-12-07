Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8AC6B0032
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 13:55:37 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so2967500wiv.1
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 10:55:36 -0800 (PST)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id jo9si58327286wjc.128.2014.12.07.10.55.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 10:55:36 -0800 (PST)
Received: by mail-wg0-f50.google.com with SMTP id k14so4609789wgh.23
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 10:55:36 -0800 (PST)
Date: Sun, 7 Dec 2014 19:55:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 2/5] OOM: thaw the OOM victim if it is frozen
Message-ID: <20141207185533.GA29065@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-3-git-send-email-mhocko@suse.cz>
 <20141206130657.GC18711@htj.dyndns.org>
 <20141207102430.GF15892@dhcp22.suse.cz>
 <20141207104539.GK15892@dhcp22.suse.cz>
 <20141207135940.GB19034@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141207135940.GB19034@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Sun 07-12-14 08:59:40, Tejun Heo wrote:
> On Sun, Dec 07, 2014 at 11:45:39AM +0100, Michal Hocko wrote:
> ....
> >  void mark_tsk_oom_victim(struct task_struct *tsk)
> >  {
> >  	set_tsk_thread_flag(tsk, TIF_MEMDIE);
> > +	__thaw_task(tsk);
> 
> Yeah, this is a lot better.  Maybe we can add a comment at least
> pointing readers to where to look at to understand what's going on?
> This stems from the fact that OOM killer which essentially is a memory
> reclaim operation overrides freezing.  It'd be nice if that is
> documented somehow.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 19a08f3f00ba..fca456fe855a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -426,6 +426,13 @@ void note_oom_kill(void)
 void mark_tsk_oom_victim(struct task_struct *tsk)
 {
 	set_tsk_thread_flag(tsk, TIF_MEMDIE);
+
+	/*
+	 * Make sure that the task is woken up from uninterruptible sleep
+	 * if it is frozen because OOM killer wouldn't be able to free
+	 * any memory and livelock. freezing_slow_path will tell the freezer
+	 * that TIF_MEMDIE tasks should be ignored.
+	 */
 	__thaw_task(tsk);
 }

Better?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

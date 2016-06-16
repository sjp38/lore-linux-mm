Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 120D26B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:54:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so102154455pfx.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:54:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j9si9779924pan.36.2016.06.16.05.54.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 05:54:35 -0700 (PDT)
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465473137-22531-8-git-send-email-mhocko@kernel.org>
	<201606092218.FCC48987.MFQLVtSHJFOOFO@I-love.SAKURA.ne.jp>
	<20160609142026.GF24777@dhcp22.suse.cz>
	<201606111710.IGF51027.OJLSOQtHVOFFFM@I-love.SAKURA.ne.jp>
	<20160613112746.GD6518@dhcp22.suse.cz>
In-Reply-To: <20160613112746.GD6518@dhcp22.suse.cz>
Message-Id: <201606162154.CGE05294.HJQOSMFFVFtOOL@I-love.SAKURA.ne.jp>
Date: Thu, 16 Jun 2016 21:54:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 11-06-16 17:10:03, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Also, I think setting TIF_MEMDIE on p when find_lock_task_mm(p) != p is
> > > > wrong. While oom_reap_task() will anyway clear TIF_MEMDIE even if we set
> > > > TIF_MEMDIE on p when p->mm == NULL, it is not true for CONFIG_MMU=n case.
> > > 
> > > Yes this would be racy for !CONFIG_MMU but does it actually matter?
> > 
> > I don't know because I've never used CONFIG_MMU=n kernels. But I think it
> > actually matters. You fixed this race by commit 83363b917a2982dd ("oom:
> > make sure that TIF_MEMDIE is set under task_lock").
> 
> Yes and that commit was trying to address a highly theoretical issue
> reported by you. Let me quote:
> :oom_kill_process is currently prone to a race condition when the OOM
> :victim is already exiting and TIF_MEMDIE is set after the task releases
> :its address space.  This might theoretically lead to OOM livelock if the
> :OOM victim blocks on an allocation later during exiting because it
> :wouldn't kill any other process and the exiting one won't be able to exit.
> :The situation is highly unlikely because the OOM victim is expected to
> :release some memory which should help to sort out OOM situation.
> 
> Even if such a race is possible it wouldn't be with the oom
> reaper. Regarding CONFIG_MMU=n I am even less sure it is possible and
> I would rather focus on CONFIG_MMU=y where we know that problems exist
> rather than speculating about something as special as nommu which even
> might not care at all.

I still don't like it. current->mm == NULL in

-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
+	if (task_will_free_mem(current)) {

is not highly unlikely. You obviously break commit d7a94e7e11badf84
("oom: don't count on mm-less current process") on CONFIG_MMU=n kernels.

Also, since commit f44666b04605d1c7 ("mm,oom: speed up select_bad_process() loop")
changed to iterate using thread group leaders, it is no longer highly unlikely
that p is a thread group leader which already released mm. What you call "a highly
theoretical issue" (which is true as of commit 83363b917a2982dd ("oom: make sure
that TIF_MEMDIE is set under task_lock") was proposed) may not be true any more.
Regarding CONFIG_MMU=n kernels, making sure that TIF_MEMDIE is set on a thread
with non-NULL mm does matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

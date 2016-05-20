Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4D7F6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 11:56:37 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id dh6so202054820obb.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:56:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e16si19908627ioi.138.2016.05.20.08.56.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 08:56:36 -0700 (PDT)
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160520075035.GF19172@dhcp22.suse.cz>
	<201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
	<20160520120954.GA5215@dhcp22.suse.cz>
	<201605202241.CHG21813.FHtSFVJFMOQOLO@I-love.SAKURA.ne.jp>
	<20160520152331.GD5215@dhcp22.suse.cz>
In-Reply-To: <20160520152331.GD5215@dhcp22.suse.cz>
Message-Id: <201605210056.CFD48413.VJFtOLFSMFHOQO@I-love.SAKURA.ne.jp>
Date: Sat, 21 May 2016 00:56:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

Michal Hocko wrote:
> > > > Note that "[PATCH v3] mm,oom: speed up select_bad_process() loop." temporarily
> > > > broke oom_task_origin(task) case, for oom_select_bad_process() might select
> > > > a task without mm because oom_badness() which checks for mm != NULL will not be
> > > > called.
> > > 
> > > How can we have oom_task_origin without mm? The flag is set explicitly
> > > while doing swapoff resp. writing to ksm. We clear the flag before
> > > exiting.
> > 
> > What if oom_task_origin(task) received SIGKILL, but task was unable to run for
> > very long period (e.g. 30 seconds) due to scheduling priority, and the OOM-reaper
> > reaped task's mm within a second. Next round of OOM-killer selects the same task
> > due to oom_task_origin(task) without doing MMF_OOM_REAPED test.
> 
> Which is actuall the intended behavior. The whole point of
> oom_task_origin is to prevent from killing somebody because of
> potentially memory hungry operation (e.g. swapoff) and rather kill the
> initiator. 

Is it guaranteed that try_to_unuse() from swapoff is never blocked on memory
allocation (e.g. mmput(), wait_on_page_*()) ?

If there is possibility of being blocked on memory allocation, it is not safe to
wait for oom_task_origin(task) unconditionally forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A70D6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 03:55:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 81so23086115wms.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 00:55:27 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id f1si3055260wmi.55.2016.05.23.00.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 00:55:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so12401180wmg.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 00:55:25 -0700 (PDT)
Date: Mon, 23 May 2016 09:55:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160523075524.GG2278@dhcp22.suse.cz>
References: <20160520075035.GF19172@dhcp22.suse.cz>
 <201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
 <20160520120954.GA5215@dhcp22.suse.cz>
 <201605202241.CHG21813.FHtSFVJFMOQOLO@I-love.SAKURA.ne.jp>
 <20160520152331.GD5215@dhcp22.suse.cz>
 <201605210056.CFD48413.VJFtOLFSMFHOQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605210056.CFD48413.VJFtOLFSMFHOQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

On Sat 21-05-16 00:56:26, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > > Note that "[PATCH v3] mm,oom: speed up select_bad_process() loop." temporarily
> > > > > broke oom_task_origin(task) case, for oom_select_bad_process() might select
> > > > > a task without mm because oom_badness() which checks for mm != NULL will not be
> > > > > called.
> > > > 
> > > > How can we have oom_task_origin without mm? The flag is set explicitly
> > > > while doing swapoff resp. writing to ksm. We clear the flag before
> > > > exiting.
> > > 
> > > What if oom_task_origin(task) received SIGKILL, but task was unable to run for
> > > very long period (e.g. 30 seconds) due to scheduling priority, and the OOM-reaper
> > > reaped task's mm within a second. Next round of OOM-killer selects the same task
> > > due to oom_task_origin(task) without doing MMF_OOM_REAPED test.
> > 
> > Which is actuall the intended behavior. The whole point of
> > oom_task_origin is to prevent from killing somebody because of
> > potentially memory hungry operation (e.g. swapoff) and rather kill the
> > initiator. 
> 
> Is it guaranteed that try_to_unuse() from swapoff is never blocked on memory
> allocation (e.g. mmput(), wait_on_page_*()) ?

It shouldn't. All the waiting should be killable. If not it is a bug and
should be fixed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

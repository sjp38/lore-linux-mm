Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1932A6B025E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 07:58:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a136so44472991wme.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 04:58:03 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id qc10si17866726wjc.175.2016.05.26.04.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 04:58:01 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so4247528wmn.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 04:58:01 -0700 (PDT)
Date: Thu, 26 May 2016 13:58:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Hold oom_victims counter while OOM reaping.
Message-ID: <20160526115759.GB23675@dhcp22.suse.cz>
References: <201605262047.JAB39598.OFOtQJVSFFOLMH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605262047.JAB39598.OFOtQJVSFFOLMH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

On Thu 26-05-16 20:47:47, Tetsuo Handa wrote:
> Continued from http://lkml.kernel.org/r/201605252330.IAC82384.OOSQHVtFFFLOMJ@I-love.SAKURA.ne.jp :
> > > I do not think we want to wait inside the oom_lock as it is a global
> > > lock shared by all OOM killer contexts. Another option would be to use
> > > the oom_lock inside __oom_reap_task. It is not super cool either because
> > > now we have a dependency on the lock but looks like reasonably easy
> > > solution.
> > 
> > It would be nice if we can wait until memory reclaimed from the OOM victim's
> > mm is queued to freelist for allocation. But I don't have idea other than
> > oomkiller_holdoff_timer.
> > 
> > I think this problem should be discussed another day in a new thread.
> > 
> 
> Can we use per "struct signal_struct" oom_victims instead of global oom_lock?

The problem with signal_struct is that we will not help if the task gets
unhashed from the task list which usually happens quite early after
exit_mm. The oom_lock will keep other OOM killer activity away until we
reap the address space and free up the memory so it would cover that
case. So I think the oom_lock is a more robust solution. I plan to post
the patch with the full changelog soon I just wanted to finish the other
pile before.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

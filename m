Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D53F6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 22:51:21 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m2so157140300ioa.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 19:51:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l2si10598502oet.29.2016.04.15.19.51.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 19:51:19 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks queued for oom_reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
	<1459951996-12875-4-git-send-email-mhocko@kernel.org>
	<201604072055.GAI52128.tHLVOFJOQMFOFS@I-love.SAKURA.ne.jp>
	<20160408113425.GF29820@dhcp22.suse.cz>
In-Reply-To: <20160408113425.GF29820@dhcp22.suse.cz>
Message-Id: <201604161151.ECG35947.FFLtSFVQJOHOOM@I-love.SAKURA.ne.jp>
Date: Sat, 16 Apr 2016 11:51:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Thu 07-04-16 20:55:34, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > The first obvious one is when the oom victim clears its mm and gets
> > > stuck later on. oom_reaper would back of on find_lock_task_mm returning
> > > NULL. We can safely try to clear TIF_MEMDIE in this case because such a
> > > task would be ignored by the oom killer anyway. The flag would be
> > > cleared by that time already most of the time anyway.
> > 
> > I didn't understand what this wants to tell. The OOM victim will clear
> > TIF_MEMDIE as soon as it sets current->mm = NULL.
> 
> No it clears the flag _after_ it returns from mmput. There is no
> guarantee it won't get stuck somewhere on the way there - e.g. exit_aio
> waits for completion and who knows what else might get stuck.

OK. Then, I think an OOM livelock scenario shown below is possible.

 (1) First OOM victim (where mm->mm_users == 1) is selected by the first
     round of out_of_memory() call.

 (2) The OOM reaper calls atomic_inc_not_zero(&mm->mm_users).

 (3) The OOM victim calls mmput() from exit_mm() from do_exit().
     mmput() returns immediately because atomic_dec_and_test(&mm->mm_users)
     returns false because of (2).

 (4) The OOM reaper reaps memory and then calls mmput().
     mmput() calls exit_aio() etc. and waits for completion because
     atomic_dec_and_test(&mm->mm_users) is now true.

 (5) Second OOM victim (which is the parent of the first OOM victim)
     is selected by the next round of out_of_memory() call.

 (6) The OOM reaper is waiting for completion of the first OOM victim's
     memory while the second OOM victim is waiting for the OOM reaper to
     reap memory.

Where is the guarantee that exit_aio() etc. called from mmput() by the
OOM reaper does not depend on memory allocation (i.e. the OOM reaper is
not blocked forever inside __oom_reap_task())?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

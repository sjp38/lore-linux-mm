Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5288F6B0403
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:51:03 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gl16so13209718wjc.5
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 03:51:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fk6si7631797wjc.87.2016.12.22.03.51.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 03:51:02 -0800 (PST)
Date: Thu, 22 Dec 2016 12:50:58 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom_reaper: Move oom_lock from
 __oom_reap_task_mm()to oom_reap_task().
Message-ID: <20161222115057.GH6048@dhcp22.suse.cz>
References: <1481540152-7599-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161212115918.GI18163@dhcp22.suse.cz>
 <20161222093501.GE6048@dhcp22.suse.cz>
 <201612221941.DIC60933.tHFOOVLJFQOMSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612221941.DIC60933.tHFOOVLJFQOMSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Thu 22-12-16 19:41:41, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 12-12-16 12:59:18, Michal Hocko wrote:
> > > On Mon 12-12-16 19:55:52, Tetsuo Handa wrote:
> > > > Since commit 862e3073b3eed13f
> > > > ("mm, oom: get rid of signal_struct::oom_victims")
> > > > changed to wait until MMF_OOM_SKIP is set rather than wait while
> > > > TIF_MEMDIE is set, rationale comment for commit e2fe14564d3316d1
> > > > ("oom_reaper: close race with exiting task") needs to be updated.
> > > 
> > > True.
> > > 
> > > > While holding oom_lock can make sure that other threads waiting for
> > > > oom_lock at __alloc_pages_may_oom() are given a chance to call
> > > > get_page_from_freelist() after the OOM reaper called unmap_page_range()
> > > > via __oom_reap_task_mm(), it can defer calling of __oom_reap_task_mm().
> > > > 
> > > > Therefore, this patch moves oom_lock from __oom_reap_task_mm() to
> > > > oom_reap_task() (without any functional change). By doing so, the OOM
> > > > killer can call __oom_reap_task_mm() if we don't want to defer calling
> > > > of __oom_reap_task_mm() (e.g. when oom_evaluate_task() aborted by
> > > > finding existing OOM victim's mm without MMF_OOM_SKIP).
> > > 
> > > But I fail to understand this part of the changelog. It sounds like a
> > > preparatory for other changes. There doesn't seem to be any other user
> > > of __oom_reap_task_mm in the current tree.
> 
> I'm planning to call __oom_reap_task_mm() from out_of_memory() if OOM
> situation is not solved immediately, after we made sure that we give
> enough CPU time to OOM killer and OOM reaper to run reclaim code by
> mutex_lock_killable(&oom_lock) change.

Whatever you plan to do, my objection to the patch was that it mixes two
things together. The comment removal makes sense on its own and it
should be a separate patch which I've acked already.

> > > Please send a patch which removes the comment which is no longer true
> > > on its own and feel free to add
> > > 
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > but do not make other changes if you do not have any follow up patch
> > > which would benefit from that.
> > 
> > Do you plan to pursue this?
> 
> Although I don't know whether we agree with mutex_lock_killable(&oom_lock)
> change, I think this patch alone can go as a cleanup.

No, we don't agree on that part. As this is a printk issue I do not want
to workaround it in the oom related code. That is just ridiculous. The
very same issue would be possible due to other continous source of log
messages.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

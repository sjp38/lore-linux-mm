Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94C206B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 07:57:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e1-v6so1205106pgv.4
        for <linux-mm@kvack.org>; Wed, 23 May 2018 04:57:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12-v6si4433730pgc.523.2018.05.23.04.57.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 04:57:32 -0700 (PDT)
Date: Wed, 23 May 2018 13:57:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180523115726.GP20441@dhcp22.suse.cz>
References: <20180515091655.GD12670@dhcp22.suse.cz>
 <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
 <20180518122045.GG21711@dhcp22.suse.cz>
 <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
 <20180522061850.GB20020@dhcp22.suse.cz>
 <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Wed 23-05-18 19:24:48, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > I don't understand why you are talking about PF_WQ_WORKER case.
> > 
> > Because that seems to be the reason to have it there as per your
> > comment.
> 
> OK. Then, I will fold below change into my patch.
> 
>         if (did_some_progress) {
>                 no_progress_loops = 0;
>  +              /*
> -+               * This schedule_timeout_*() serves as a guaranteed sleep for
> -+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> ++               * Try to give the OOM killer/reaper/victims some time for
> ++               * releasing memory.
>  +               */
>  +              if (!tsk_is_oom_victim(current))
>  +                      schedule_timeout_uninterruptible(1);

Do you really need this? You are still fiddling with this path at all? I
see how removing the timeout might be reasonable after recent changes
but why do you insist in adding it outside of the lock.
-- 
Michal Hocko
SUSE Labs

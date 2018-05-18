Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B28EC6B05CE
	for <linux-mm@kvack.org>; Fri, 18 May 2018 06:14:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f20-v6so4542175ioc.8
        for <linux-mm@kvack.org>; Fri, 18 May 2018 03:14:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u194-v6si6383039ith.1.2018.05.18.03.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 03:14:28 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp>
	<20180515091655.GD12670@dhcp22.suse.cz>
In-Reply-To: <20180515091655.GD12670@dhcp22.suse.cz>
Message-Id: <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
Date: Fri, 18 May 2018 19:14:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Sat 12-05-18 23:18:24, Tetsuo Handa wrote:
> [...]
> > @@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >  	/* Retry as long as the OOM killer is making progress */
> >  	if (did_some_progress) {
> >  		no_progress_loops = 0;
> > +		/*
> > +		 * This schedule_timeout_*() serves as a guaranteed sleep for
> > +		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > +		 */
> > +		if (!tsk_is_oom_victim(current))
> > +			schedule_timeout_uninterruptible(1);
> >  		goto retry;
> 
> We already do have that sleep for PF_WQ_WORKER in should_reclaim_retry.
> Why do we need it here as well?

Because that path depends on __zone_watermark_ok() == true which is not
guaranteed to be executed.

I consider that this "goto retry;" is a good location for making a short sleep.
Current code is so conditional that there are cases which needlessly retry
without sleeping (e.g. current thread finds an OOM victim at select_bad_process()
and immediately retries allocation attempt rather than giving the OOM victim
CPU resource for releasing memory) or needlessly sleep (e.g. current thread
was selected as an OOM victim but mutex_trylock(&oom_lock) in
__alloc_pages_may_oom() failed).

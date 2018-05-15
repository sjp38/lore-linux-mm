Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8CE46B0005
	for <linux-mm@kvack.org>; Tue, 15 May 2018 05:16:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p7-v6so11629493wrj.4
        for <linux-mm@kvack.org>; Tue, 15 May 2018 02:16:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20-v6si3370034ede.52.2018.05.15.02.16.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 02:16:58 -0700 (PDT)
Date: Tue, 15 May 2018 11:16:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180515091655.GD12670@dhcp22.suse.cz>
References: <201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Sat 12-05-18 23:18:24, Tetsuo Handa wrote:
[...]
> @@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	/* Retry as long as the OOM killer is making progress */
>  	if (did_some_progress) {
>  		no_progress_loops = 0;
> +		/*
> +		 * This schedule_timeout_*() serves as a guaranteed sleep for
> +		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> +		 */
> +		if (!tsk_is_oom_victim(current))
> +			schedule_timeout_uninterruptible(1);
>  		goto retry;

We already do have that sleep for PF_WQ_WORKER in should_reclaim_retry.
Why do we need it here as well?

-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB006B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:11:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t7-v6so4495610wmg.3
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:11:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1-v6si1088625edh.367.2018.06.07.04.11.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 04:11:39 -0700 (PDT)
Date: Thu, 7 Jun 2018 13:11:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180607111137.GK32433@dhcp22.suse.cz>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 07-06-18 20:00:20, Tetsuo Handa wrote:
[...]
> @@ -4238,6 +4237,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
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
>  	}

Nacked-by: Michal Hocko <mhocko@suse.com>

as explainaed several times already. This moving code just to preserve
the current logic without any arguments to back them must stop finally.
We have way too much of this "just in case" code that nobody really
understands and others just pile on top. Seriously this is not how the
development should work.
-- 
Michal Hocko
SUSE Labs

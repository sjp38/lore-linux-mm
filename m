Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32B086B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:17:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r2-v6so5461039wrm.15
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:17:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t29-v6si7475194eda.313.2018.06.07.04.17.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 04:17:01 -0700 (PDT)
Date: Thu, 7 Jun 2018 13:16:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm,oom: Simplify exception case handling in
 out_of_memory().
Message-ID: <20180607111659.GM32433@dhcp22.suse.cz>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1528369223-7571-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1528369223-7571-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 07-06-18 20:00:22, Tetsuo Handa wrote:
> To avoid oversights when adding the "mm, oom: cgroup-aware OOM killer"
> patchset, simplify the exception case handling in out_of_memory().
> This patch makes no functional changes.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

with a minor nit

> ---
>  mm/oom_kill.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 23ce67f..5a6f1b1 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1073,15 +1073,18 @@ bool out_of_memory(struct oom_control *oc)
>  	}
>  
>  	select_bad_process(oc);
> +	if (oc->chosen == (void *)-1UL)

I think this one deserves a comment.
	/* There is an inflight oom victim *.

> +		return true;
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
> -	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> +	if (!oc->chosen) {
> +		if (is_sysrq_oom(oc) || is_memcg_oom(oc))
> +			return false;
>  		dump_header(oc, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}
> -	if (oc->chosen && oc->chosen != (void *)-1UL)
> -		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
> -				 "Memory cgroup out of memory");
> -	return !!oc->chosen;
> +	oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
> +			 "Memory cgroup out of memory");
> +	return true;
>  }
>  
>  /*
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6440D6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:23:23 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so5611419yho.24
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:23:23 -0800 (PST)
Received: from mail-yh0-x22e.google.com (mail-yh0-x22e.google.com [2607:f8b0:4002:c01::22e])
        by mx.google.com with ESMTPS id v3si19370635yhd.13.2013.12.11.14.23.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 14:23:22 -0800 (PST)
Received: by mail-yh0-f46.google.com with SMTP id l109so5624727yhq.5
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:23:22 -0800 (PST)
Date: Wed, 11 Dec 2013 14:23:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg, oom: lock mem_cgroup_print_oom_info
In-Reply-To: <1386776545-24916-1-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.02.1312111421320.7354@chino.kir.corp.google.com>
References: <1386776545-24916-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 11 Dec 2013, Michal Hocko wrote:

> mem_cgroup_print_oom_info uses a static buffer (memcg_name) to store the
> name of the cgroup. This is not safe as pointed out by David Rientjes
> because memcg oom is locked only for its hierarchy and nothing prevents
> another parallel hierarchy to trigger oom as well and overwrite the
> already in-use buffer.
> 
> This patch introduces oom_info_lock hidden inside mem_cgroup_print_oom_info
> which is held throughout the function. It make access to memcg_name safe
> and as a bonus it also prevents parallel memcg ooms to interleave their
> statistics which would make the printed data hard to analyze otherwise.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  mm/memcontrol.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 28c9221b74ea..c72b03bf9679 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1647,13 +1647,13 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
>   */
>  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> -	struct cgroup *task_cgrp;
> -	struct cgroup *mem_cgrp;
>  	/*
> -	 * Need a buffer in BSS, can't rely on allocations. The code relies
> -	 * on the assumption that OOM is serialized for memory controller.
> -	 * If this assumption is broken, revisit this code.
> +	 * protects memcg_name and makes sure that parallel ooms do not
> +	 * interleave

Parallel memcg oom kills can happen in disjoint memcg hierarchies, this 
just prevents the printing of the statistics from interleaving.  I'm not 
sure if that's clear from this comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E98C88E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 15:23:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so32755623edc.9
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 12:23:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13-v6si9836377eja.107.2019.01.02.12.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 12:23:56 -0800 (PST)
Date: Wed, 2 Jan 2019 21:23:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fork, memcg: fix cached_stacks case
Message-ID: <20190102202348.GE24572@dhcp22.suse.cz>
References: <20190102180145.57406-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190102180145.57406-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, stable@vger.kernel.org

On Wed 02-01-19 10:01:45, Shakeel Butt wrote:
> Commit 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on
> memcg charge fail") fixes a crash caused due to failed memcg charge of
> the kernel stack. However the fix misses the cached_stacks case which
> this patch fixes. So, the same crash can happen if the memcg charge of
> a cached stack is failed.
> 
> Fixes: 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on memcg charge fail")
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: <stable@vger.kernel.org>

Ups, I have overlook that. Thanks for catching that.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  kernel/fork.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index e4a51124661a..593cd1577dff 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -216,6 +216,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  		memset(s->addr, 0, THREAD_SIZE);
>  
>  		tsk->stack_vm_area = s;
> +		tsk->stack = s->addr;
>  		return s->addr;
>  	}
>  
> -- 
> 2.20.1.415.g653613c723-goog
> 

-- 
Michal Hocko
SUSE Labs

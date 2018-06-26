Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84C356B000D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 15:03:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r7-v6so651396edq.8
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 12:03:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t15-v6si130949edh.240.2018.06.26.12.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Jun 2018 12:03:58 -0700 (PDT)
Date: Tue, 26 Jun 2018 15:06:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20180626190619.GB3958@cmpxchg.org>
References: <20180625230659.139822-1-shakeelb@google.com>
 <20180625230659.139822-2-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180625230659.139822-2-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Amir Goldstein <amir73il@gmail.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Mon, Jun 25, 2018 at 04:06:58PM -0700, Shakeel Butt wrote:
> @@ -140,8 +141,9 @@ struct fanotify_event_info *fanotify_alloc_event(struct fsnotify_group *group,
>  						 struct inode *inode, u32 mask,
>  						 const struct path *path)
>  {
> -	struct fanotify_event_info *event;
> +	struct fanotify_event_info *event = NULL;
>  	gfp_t gfp = GFP_KERNEL;
> +	struct mem_cgroup *old_memcg = NULL;
>  
>  	/*
>  	 * For queues with unlimited length lost events are not expected and
> @@ -151,19 +153,25 @@ struct fanotify_event_info *fanotify_alloc_event(struct fsnotify_group *group,
>  	if (group->max_events == UINT_MAX)
>  		gfp |= __GFP_NOFAIL;
>  
> +	/* Whoever is interested in the event, pays for the allocation. */
> +	if (group->memcg) {
> +		gfp |= __GFP_ACCOUNT;
> +		old_memcg = memalloc_use_memcg(group->memcg);
> +	}

group->memcg is only NULL when memcg is disabled or there is some
offlining race. Can you make memalloc_use_memcg(NULL) mean that it
should charge root_mem_cgroup instead of current->mm->memcg? That way
we can make this site unconditional while retaining the behavior:

	gfp_t gfp = GFP_KERNEL | __GFP_ACCOUNT;

	memalloc_use_memcg(group->memcg);
	kmem_cache_alloc(..., gfp);
out:
	memalloc_unuse_memcg();

(dropping old_memcg and the unuse parameter as per the other mail)

>  	if (fanotify_is_perm_event(mask)) {
>  		struct fanotify_perm_event_info *pevent;
>  
>  		pevent = kmem_cache_alloc(fanotify_perm_event_cachep, gfp);
>  		if (!pevent)
> -			return NULL;
> +			goto out;
>  		event = &pevent->fae;
>  		pevent->response = 0;
>  		goto init;
>  	}
>  	event = kmem_cache_alloc(fanotify_event_cachep, gfp);
>  	if (!event)
> -		return NULL;
> +		goto out;
>  init: __maybe_unused
>  	fsnotify_init_event(&event->fse, inode, mask);
>  	event->tgid = get_pid(task_tgid(current));
> @@ -174,6 +182,9 @@ init: __maybe_unused
>  		event->path.mnt = NULL;
>  		event->path.dentry = NULL;
>  	}
> +out:
> +	if (group->memcg)
> +		memalloc_unuse_memcg(old_memcg);
>  	return event;
>  }

Thanks,
Johannes

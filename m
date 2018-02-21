Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 605086B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:35:56 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id w184so2234656ita.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:35:56 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id j34si1800103ioi.303.2018.02.21.08.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 08:35:55 -0800 (PST)
Date: Wed, 21 Feb 2018 10:35:51 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/3] fs: fsnotify: account fsnotify metadata to
 kmemcg
In-Reply-To: <20180221030101.221206-4-shakeelb@google.com>
Message-ID: <alpine.DEB.2.20.1802211029080.13404@nuc-kabylake>
References: <20180221030101.221206-1-shakeelb@google.com> <20180221030101.221206-4-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 20 Feb 2018, Shakeel Butt wrote:

> diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
> index 6702a6a0bbb5..0d9493ebc7cd 100644
> --- a/fs/notify/fanotify/fanotify.c
> +++ b/fs/notify/fanotify/fanotify.c
>  	if (fanotify_is_perm_event(mask)) {
>  		struct fanotify_perm_event_info *pevent;
>
> -		pevent = kmem_cache_alloc(fanotify_perm_event_cachep,
> -					  GFP_KERNEL);
> +		pevent = kmem_cache_alloc_memcg(fanotify_perm_event_cachep,
> +						GFP_KERNEL, memcg);
>  		if (!pevent)

#1

> index 8b73332735ba..ed8e7b5f3981 100644
> --- a/fs/notify/inotify/inotify_fsnotify.c
> +++ b/fs/notify/inotify/inotify_fsnotify.c
> @@ -98,7 +98,7 @@ int inotify_handle_event(struct fsnotify_group *group,
>  	i_mark = container_of(inode_mark, struct inotify_inode_mark,
>  			      fsn_mark);
>
> -	event = kmalloc(alloc_len, GFP_KERNEL);
> +	event = kmalloc_memcg(alloc_len, GFP_KERNEL, group->memcg);
>  	if (unlikely(!event))
>  		return -ENOMEM;

#2


So we have all this churn for those two allocations which are basically
the same code for two different notification schemes.

Could you store the task that is requesting the fsnotify action instead of
the memcg? Then do the allocation in the context of that task. That
reduces the modifications to fsnotify.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

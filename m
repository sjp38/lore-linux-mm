Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF1F56B02D6
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:49:48 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b142so610217wma.4
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:49:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o205si278571wmb.102.2018.02.22.05.49.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 05:49:47 -0800 (PST)
Date: Thu, 22 Feb 2018 14:49:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20180222134944.GK30681@dhcp22.suse.cz>
References: <20180221030101.221206-1-shakeelb@google.com>
 <20180221030101.221206-4-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221030101.221206-4-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 20-02-18 19:01:01, Shakeel Butt wrote:
> A lot of memory can be consumed by the events generated for the huge or
> unlimited queues if there is either no or slow listener. This can cause
> system level memory pressure or OOMs. So, it's better to account the
> fsnotify kmem caches to the memcg of the listener.

How much memory are we talking about here?

> There are seven fsnotify kmem caches and among them allocations from
> dnotify_struct_cache, dnotify_mark_cache, fanotify_mark_cache and
> inotify_inode_mark_cachep happens in the context of syscall from the
> listener. So, SLAB_ACCOUNT is enough for these caches.
> 
> The objects from fsnotify_mark_connector_cachep are not accounted as
> they are small compared to the notification mark or events and it is
> unclear whom to account connector to since it is shared by all events
> attached to the inode.
> 
> The allocations from the event caches happen in the context of the event
> producer. For such caches we will need to remote charge the allocations
> to the listener's memcg. Thus we save the memcg reference in the
> fsnotify_group structure of the listener.

Is it typical that the listener lives in a different memcg and if yes
then cannot this cause one memcg to OOM/DoS the one with the listener?

> This patch has also moved the members of fsnotify_group to keep the
> size same, at least for 64 bit build, even with additional member by
> filling the holes.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

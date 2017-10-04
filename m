Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5B0B6B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 09:17:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f84so26636723pfj.0
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 06:17:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si2309192pfi.64.2017.10.04.06.17.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 06:17:53 -0700 (PDT)
Date: Wed, 4 Oct 2017 15:17:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] epoll: account epitem and eppoll_entry to kmemcg
Message-ID: <20171004131750.lwxhwtfsyget6bsx@dhcp22.suse.cz>
References: <20171003021519.23907-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003021519.23907-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 02-10-17 19:15:19, Shakeel Butt wrote:
> The user space application can directly trigger the allocations
> from eventpoll_epi and eventpoll_pwq slabs. A buggy or malicious
> application can consume a significant amount of system memory by
> triggering such allocations. Indeed we have seen in production
> where a buggy application was leaking the epoll references and
> causing a burst of eventpoll_epi and eventpoll_pwq slab
> allocations. This patch opt-in the charging of eventpoll_epi
> and eventpoll_pwq slabs.

I am not objecting to the patch I would just like to understand the
runaway case. ep_insert seems to limit the maximum number of watches to
max_user_watches which should be ~4% of lowmem if I am following the
code properly. pwq_cache should be bound by the number of watches as
well, or am I misunderstanding the code?

> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  fs/eventpoll.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index 2fabd19cdeea..a45360444895 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -2329,11 +2329,11 @@ static int __init eventpoll_init(void)
>  
>  	/* Allocates slab cache used to allocate "struct epitem" items */
>  	epi_cache = kmem_cache_create("eventpoll_epi", sizeof(struct epitem),
> -			0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> +			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
>  
>  	/* Allocates slab cache used to allocate "struct eppoll_entry" */
>  	pwq_cache = kmem_cache_create("eventpoll_pwq",
> -			sizeof(struct eppoll_entry), 0, SLAB_PANIC, NULL);
> +		sizeof(struct eppoll_entry), 0, SLAB_PANIC|SLAB_ACCOUNT, NULL);
>  
>  	return 0;
>  }
> -- 
> 2.14.2.822.g60be5d43e6-goog

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

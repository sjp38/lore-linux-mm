Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A2D3C6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 16:05:32 -0400 (EDT)
Date: Mon, 5 Aug 2013 13:05:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
Message-Id: <20130805130530.fd38ec4866ba7f1d9a400218@linux-foundation.org>
In-Reply-To: <1375718980-22154-1-git-send-email-avagin@openvz.org>
References: <1375718980-22154-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, stable@vger.kernel.org

On Mon,  5 Aug 2013 20:09:40 +0400 Andrey Vagin <avagin@openvz.org> wrote:

> struct memcg_cache_params has a union. Different parts of this union
> are used for root and non-root caches. A part with destroying work is
> used only for non-root caches.
> 
> I fixed the same problem in another place v3.9-rc1-16204-gf101a94, but
> didn't notice this one.
> 
> Cc: <stable@vger.kernel.org>    [3.9.x]

hm, why the cc:stable?

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3195,11 +3195,11 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
>  	if (!s->memcg_params)
>  		return -ENOMEM;
>  
> -	INIT_WORK(&s->memcg_params->destroy,
> -			kmem_cache_destroy_work_func);
>  	if (memcg) {
>  		s->memcg_params->memcg = memcg;
>  		s->memcg_params->root_cache = root_cache;
> +		INIT_WORK(&s->memcg_params->destroy,
> +				kmem_cache_destroy_work_func);
>  	} else
>  		s->memcg_params->is_root_cache = true;

So the bug here is that we'll scribble on some entries in
memcg_caches[].  Those scribbles may or may not be within the part of
that array which is actually used.  If there's code which expects
memcg_caches[] entries to be zeroed at initialisation then yes, we have
a problem.

But I rather doubt whether this bug was causing runtime problems?


Presently memcg_register_cache() allocates too much memory for the
memcg_caches[] array.  If that was fixed then this INIT_WORK() might
scribble into unknown memory, which is of course serious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

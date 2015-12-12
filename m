Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9596B0257
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 11:33:48 -0500 (EST)
Received: by pfbo64 with SMTP id o64so3943225pfb.1
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 08:33:47 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ti10si4716702pab.52.2015.12.12.08.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 08:33:47 -0800 (PST)
Date: Sat, 12 Dec 2015 19:33:32 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/4] mm: memcontrol: reign in the CONFIG space madness
Message-ID: <20151212163332.GC28521@esperanza>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
 <1449863653-6546-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1449863653-6546-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Dec 11, 2015 at 02:54:11PM -0500, Johannes Weiner wrote:
> What CONFIG_INET and CONFIG_LEGACY_KMEM guard inside the memory
> controller code is insignificant, having these conditionals is not
> worth the complication and fragility that comes with them.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

> @@ -4374,17 +4342,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
> -#ifdef CONFIG_INET
>  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
>  		static_branch_dec(&memcg_sockets_enabled_key);
> -#endif
> -
> -	memcg_free_kmem(memcg);

I wonder where the second call to memcg_free_kmem comes from. Luckily,
it couldn't result in a breakage. And now it's removed.

>  
> -#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
>  	if (memcg->tcp_mem.active)
>  		static_branch_dec(&memcg_sockets_enabled_key);
> -#endif
>  
>  	memcg_free_kmem(memcg);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

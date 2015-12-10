Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 38F5E6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:38:26 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so46609063pac.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:38:26 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 67si19883027pfc.1.2015.12.10.03.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:38:25 -0800 (PST)
Date: Thu, 10 Dec 2015 14:38:07 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [RFC PATCH] mm: memcontrol: reign in CONFIG space madness
Message-ID: <20151210113807.GW11488@esperanza>
References: <20151209203004.GA5820@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151209203004.GA5820@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 09, 2015 at 03:30:04PM -0500, Johannes Weiner wrote:
> there has been quite a bit of trouble that stems from dividing our
> CONFIG space and having to provide real code and dummy functions
> correctly in all possible combinations. This is amplified by having
> the legacy mode and the cgroup2 mode in the same file sharing code.
> 
> The socket memory and kmem accounting series is a nightmare in that
> respect, and I'm still in the process of sorting it out. But no matter
> what the outcome there is going to be, what do you think about getting
> rid of the CONFIG_MEMCG[_LEGACY]_KMEM and CONFIG_INET stuff?
> 
> Because they end up saving very little and it doesn't seem worth the
> trouble. CONFIG_MEMCG_LEGACY_KMEM basically allows not compiling the
> interface structures and the limit updating function. Everything else
> is included anyway because of cgroup2. And CONFIG_INET also only saves
> a page_counter and two words in struct mem_cgroup, as well as the tiny
> socket-specific charge and uncharge wrappers that nobody would call.
> 
> Would you be opposed to getting rid of them to simplify things?

That's exactly what I was thinking about while cooking the patch which
would get rid of tcp_memcontrol.c, but I was afraid I would be turned
down flat, so I dopped the idea :-)

So I'm all for this change. Actually, we already follow the trend when
we define kmem and memsw counters even if MEMCG_KMEM/MEMCG_SWAP is
disabled, and that's reasonable, because wrapping them in ifdefs would
make the code look like hell.

Besides, !CONFIG_INET && CONFIG_MEMCG looks exotic. I doubt such a
configuration exists in real life.

...
> @@ -1040,22 +1040,6 @@ config MEMCG_SWAP_ENABLED
>  	  For those who want to have the feature enabled by default should
>  	  select this option (if, for some reason, they need to disable it
>  	  then swapaccount=0 does the trick).
> -config MEMCG_LEGACY_KMEM
> -	bool "Legacy Memory Resource Controller Kernel Memory accounting"
> -	depends on MEMCG
> -	depends on SLUB || SLAB
> -	help
> -	  The Kernel Memory extension for Memory Resource Controller can limit
> -	  the amount of memory used by kernel objects in the system. Those are
> -	  fundamentally different from the entities handled by the standard
> -	  Memory Controller, which are page-based, and can be swapped. Users of
> -	  the kmem extension can use it to guarantee that no group of processes
> -	  will ever exhaust kernel resources alone.
> -
> -	  This option affects the ORIGINAL cgroup interface. The cgroup2 memory
> -	  controller includes important in-kernel memory consumers per default.
> -
> -	  If you're using cgroup2, say N.

Hmm, should we hide memory.kmem.* files if this option is disabled?
Probably, but it won't do anything bad if we don't.

>From a quick glance, the patch looks good to me.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7293F6B0253
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:46:26 -0400 (EDT)
Received: by lffv3 with SMTP id v3so58748516lff.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:46:25 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ta8si10436630lbb.115.2015.10.22.11.46.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 11:46:25 -0700 (PDT)
Date: Thu, 22 Oct 2015 21:46:12 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/8] net: consolidate memcg socket buffer tracking and
 accounting
Message-ID: <20151022184612.GN18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1445487696-21545-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 12:21:31AM -0400, Johannes Weiner wrote:
> The tcp memory controller has extensive provisions for future memory
> accounting interfaces that won't materialize after all. Cut the code
> base down to what's actually used, now and in the likely future.
> 
> - There won't be any different protocol counters in the future, so a
>   direct sock->sk_memcg linkage is enough. This eliminates a lot of
>   callback maze and boilerplate code, and restores most of the socket
>   allocation code to pre-tcp_memcontrol state.
> 
> - There won't be a tcp control soft limit, so integrating the memcg

In fact, the code is ready for the "soft" limit (I mean min, pressure,
max tuple), it just lacks a knob.

>   code into the global skmem limiting scheme complicates things
>   unnecessarily. Replace all that with simple and clear charge and
>   uncharge calls--hidden behind a jump label--to account skb memory.
> 
> - The previous jump label code was an elaborate state machine that
>   tracked the number of cgroups with an active socket limit in order
>   to enable the skmem tracking and accounting code only when actively
>   necessary. But this is overengineered: it was meant to protect the
>   people who never use this feature in the first place. Simply enable
>   the branches once when the first limit is set until the next reboot.
> 
...
> @@ -1136,9 +1090,6 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
>  	if (!sk->sk_prot->memory_pressure)
>  		return false;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		return !!sk->sk_cgrp->memory_pressure;
> -

AFAIU, now we won't shrink the window on hitting the limit, i.e. this
patch subtly changes the behavior of the existing knobs, potentially
breaking them.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

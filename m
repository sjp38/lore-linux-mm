Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 87C6182F64
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 15:09:58 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so2341374wic.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 12:09:58 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id em7si313513wid.45.2015.10.22.12.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 12:09:57 -0700 (PDT)
Date: Thu, 22 Oct 2015 15:09:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/8] net: consolidate memcg socket buffer tracking and
 accounting
Message-ID: <20151022190943.GA20871@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-4-git-send-email-hannes@cmpxchg.org>
 <20151022184612.GN18351@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022184612.GN18351@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 09:46:12PM +0300, Vladimir Davydov wrote:
> On Thu, Oct 22, 2015 at 12:21:31AM -0400, Johannes Weiner wrote:
> > The tcp memory controller has extensive provisions for future memory
> > accounting interfaces that won't materialize after all. Cut the code
> > base down to what's actually used, now and in the likely future.
> > 
> > - There won't be any different protocol counters in the future, so a
> >   direct sock->sk_memcg linkage is enough. This eliminates a lot of
> >   callback maze and boilerplate code, and restores most of the socket
> >   allocation code to pre-tcp_memcontrol state.
> > 
> > - There won't be a tcp control soft limit, so integrating the memcg
> 
> In fact, the code is ready for the "soft" limit (I mean min, pressure,
> max tuple), it just lacks a knob.

Yeah, but that's not going to materialize if the entire interface for
dedicated tcp throttling is considered obsolete.

> > @@ -1136,9 +1090,6 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
> >  	if (!sk->sk_prot->memory_pressure)
> >  		return false;
> >  
> > -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> > -		return !!sk->sk_cgrp->memory_pressure;
> > -
> 
> AFAIU, now we won't shrink the window on hitting the limit, i.e. this
> patch subtly changes the behavior of the existing knobs, potentially
> breaking them.

Hm, but there is no grace period in which something meaningful could
happen with the window shrinking, is there? Any buffer allocation is
still going to fail hard.

I don't see how this would change anything in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

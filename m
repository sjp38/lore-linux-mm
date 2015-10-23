Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1E69A6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 09:43:14 -0400 (EDT)
Received: by lffv3 with SMTP id v3so83949899lff.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:43:13 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id s71si12682772lfd.169.2015.10.23.06.43.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 06:43:12 -0700 (PDT)
Date: Fri, 23 Oct 2015 16:42:56 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/8] net: consolidate memcg socket buffer tracking and
 accounting
Message-ID: <20151023134256.GS18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-4-git-send-email-hannes@cmpxchg.org>
 <20151022184612.GN18351@esperanza>
 <20151022190943.GA20871@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151022190943.GA20871@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 03:09:43PM -0400, Johannes Weiner wrote:
> On Thu, Oct 22, 2015 at 09:46:12PM +0300, Vladimir Davydov wrote:
> > On Thu, Oct 22, 2015 at 12:21:31AM -0400, Johannes Weiner wrote:
> > > The tcp memory controller has extensive provisions for future memory
> > > accounting interfaces that won't materialize after all. Cut the code
> > > base down to what's actually used, now and in the likely future.
> > > 
> > > - There won't be any different protocol counters in the future, so a
> > >   direct sock->sk_memcg linkage is enough. This eliminates a lot of
> > >   callback maze and boilerplate code, and restores most of the socket
> > >   allocation code to pre-tcp_memcontrol state.
> > > 
> > > - There won't be a tcp control soft limit, so integrating the memcg
> > 
> > In fact, the code is ready for the "soft" limit (I mean min, pressure,
> > max tuple), it just lacks a knob.
> 
> Yeah, but that's not going to materialize if the entire interface for
> dedicated tcp throttling is considered obsolete.

May be, it shouldn't be. My current understanding is that per memcg tcp
window control is necessary, because:

 - We need to be able to protect a containerized workload from its
   growing network buffers. Using vmpressure notifications for that does
   not look reassuring to me.

 - We need a way to limit network buffers of a particular container,
   otherwise it can fill the system-wide window throttling other
   containers, which is unfair.

> 
> > > @@ -1136,9 +1090,6 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
> > >  	if (!sk->sk_prot->memory_pressure)
> > >  		return false;
> > >  
> > > -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> > > -		return !!sk->sk_cgrp->memory_pressure;
> > > -
> > 
> > AFAIU, now we won't shrink the window on hitting the limit, i.e. this
> > patch subtly changes the behavior of the existing knobs, potentially
> > breaking them.
> 
> Hm, but there is no grace period in which something meaningful could
> happen with the window shrinking, is there? Any buffer allocation is
> still going to fail hard.

AFAIU when we hit the limit, we not only throttle the socket which
allocates, but also try to release space reserved by other sockets.
After your patch we won't. This looks unfair to me.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

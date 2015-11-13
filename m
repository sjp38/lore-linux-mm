Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0107A6B0254
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 00:44:25 -0500 (EST)
Received: by wmvv187 with SMTP id v187so65192091wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 21:44:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e67si3252945wmd.25.2015.11.12.21.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 21:44:23 -0800 (PST)
Date: Fri, 13 Nov 2015 00:44:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/14] net: tcp_memcontrol: sanitize tcp memory
 accounting callbacks
Message-ID: <20151113054408.GA2104@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-9-git-send-email-hannes@cmpxchg.org>
 <1447390418.22599.34.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447390418.22599.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 08:53:38PM -0800, Eric Dumazet wrote:
> On Thu, 2015-11-12 at 18:41 -0500, Johannes Weiner wrote:
> > @@ -711,6 +705,12 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
> >  struct sock;
> >  void sock_update_memcg(struct sock *sk);
> >  void sock_release_memcg(struct sock *sk);
> > +bool mem_cgroup_charge_skmem(struct cg_proto *proto, unsigned int nr_pages);
> > +void mem_cgroup_uncharge_skmem(struct cg_proto *proto, unsigned int nr_pages);
> > +static inline bool mem_cgroup_under_socket_pressure(struct cg_proto *proto)
> > +{
> > +	return proto->memory_pressure;
> > +}
> >  #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
> >  
> >  #ifdef CONFIG_MEMCG_KMEM
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 2eefc99..8cc7613 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -1126,8 +1126,8 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
> >  	if (!sk->sk_prot->memory_pressure)
> >  		return false;
> >  
> > -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> > -		return !!sk->sk_cgrp->memory_pressure;
> > +	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
> > +	    mem_cgroup_under_socket_pressure(sk->sk_cgrp))
> >  
> >  	return !!*sk->sk_prot->memory_pressure;
> >  }
> 
> 
> This looks wrong ?
> 
> if (A && B && C)
>     return !!*sk->sk_prot->memory_pressure;
> 
> <compiler should eventually barf, 
> as this function should not return void>

Yikes, you're right. This is missing a return true.

[ Just forced a complete rebuild and of course it warns at control
  reaching end of non-void function. ]

I'm stumped by how I could have missed it as I rebuild after every
commit with make -s, so a warning should stand out. And it should
definitely rebuild the callers frequently as most patches change
memcontrol.h. Probably a screwup in the final series polishing.
I'm going to go over this carefully one more time tomorrow.

Meanwhile, this is the missing piece and the updated patch.

Thanks Eric.

diff --git a/include/net/sock.h b/include/net/sock.h
index 8cc7613..f954e2a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1128,6 +1128,7 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
 
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
 	    mem_cgroup_under_socket_pressure(sk->sk_cgrp))
+		return true;
 
 	return !!*sk->sk_prot->memory_pressure;
 }

---

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id D411E6B0039
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 07:01:50 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id 10so449603lbf.36
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 04:01:49 -0700 (PDT)
Date: Fri, 14 Jun 2013 15:01:45 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH] memcg: make cache index determination more robust
Message-ID: <20130614110145.GB4292@localhost.localdomain>
References: <1371069808-1172-1-git-send-email-glommer@openvz.org>
 <20130613163849.GL23070@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130613163849.GL23070@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Jun 13, 2013 at 06:38:49PM +0200, Michal Hocko wrote:
> On Wed 12-06-13 16:43:28, Glauber Costa wrote:
> > I caught myself doing something like the following outside memcg core:
> > 
> > 	memcg_id = -1;
> > 	if (memcg && memcg_kmem_is_active(memcg))
> > 		memcg_id = memcg_cache_id(memcg);
> > 
> > to be able to handle all possible memcgs in a sane manner. In particular, the
> > root cache will have kmemcg_id = -1 (just because we don't call memcg_kmem_init
> > to the root cache since it is not limitable). We have always coped with that by
> > making sure we sanitize which cache is passed to memcg_cache_id. Although this
> > example is given for root, what we really need to know is whether or not a
> > cache is kmem active.
> > 
> > But outside the memcg core testing for root, for instance, is not trivial since
> > we don't export mem_cgroup_is_root. I ended up realizing that this tests really
> > belong inside memcg_cache_id. This patch moves the tests inside memcg_cache_id
> > and make sure it always return a meaningful value.
> 
> This is quite a mess, to be honest. Some callers test/require
> memcg_can_account_kmem others !p->is_root_cache. Can we have that
> unified, please?
> 
> Also the return value of this function is used mostly as an index to
> memcg_params->memcg_caches array so returning -1 sounds like a bad idea.
> Few other cases use it as a real id. Maybe we need to split this up.
> 
> Pulling the check inside the function is OK but can we settle with a
> common pattern here, pretty please?
> 

We have been through the array index discussion before. It is used as an array index
only in contexts where we are absolutely sure we are dealing with a memcg that is kmem
limited. Those are usually contexts in which in case it is not, we would have to BUG
anyway.

If you prefer, though, that we always BUG on id == -1 in those scenarios, for consistency,
this is understandable and I will prepare a patch for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

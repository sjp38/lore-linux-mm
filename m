Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E28B46B003A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 07:24:05 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id fe20so417946lab.20
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 04:24:04 -0700 (PDT)
Date: Fri, 14 Jun 2013 15:24:00 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH] memcg: make cache index determination more robust
Message-ID: <20130614112359.GC4292@localhost.localdomain>
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
BTW: Since the test for memcg_can_account_kmem is a bit stronger than
memcg_kmem_is_active (the difference is that it tests the extra bit that we need
to coordinate the static branches), I will test for that, instead. Like this:

int memcg_cache_id(struct mem_cgroup *memcg)
{
        if (!memcg_can_account_kmem(memcg))                       
                return -1;
        return memcg->kmemcg_id;                                          
}

This will allow us to consolidate the tests around it a bit in my follow up patch.

> > Signed-off-by: Glauber Costa <glommer@openvz.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 2e851f4..749f7a4 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3081,7 +3081,9 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
> >   */
> >  int memcg_cache_id(struct mem_cgroup *memcg)
> >  {
> > -	return memcg ? memcg->kmemcg_id : -1;
> > +	if (!memcg || !memcg_kmem_is_active(memcg))
> > +		return -1;
> > +	return memcg->kmemcg_id;
> >  }
> >  
> >  /*
> > -- 
> > 1.8.1.4
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

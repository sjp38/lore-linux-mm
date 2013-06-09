Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 663516B0031
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 07:57:49 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z5so5413322lbh.21
        for <linux-mm@kvack.org>; Sun, 09 Jun 2013 04:57:47 -0700 (PDT)
Date: Sun, 9 Jun 2013 15:57:44 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH] memcg: do not account memory used for cache creation
Message-ID: <20130609115742.GA5315@localhost.localdomain>
References: <1370355059-24968-1-git-send-email-glommer@openvz.org>
 <20130607092132.GE8117@dhcp22.suse.cz>
 <51B1B1E9.1020701@parallels.com>
 <20130607141204.GG8117@dhcp22.suse.cz>
 <51B1F1FD.7000002@gmail.com>
 <20130607155406.GL8117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130607155406.GL8117@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Fri, Jun 07, 2013 at 05:54:06PM +0200, Michal Hocko wrote:
> On Fri 07-06-13 18:45:17, Glauber Costa wrote:
> > On 06/07/2013 06:12 PM, Michal Hocko wrote:
> > >On Fri 07-06-13 14:11:53, Glauber Costa wrote:
> > >>On 06/07/2013 01:21 PM, Michal Hocko wrote:
> > >>>On Tue 04-06-13 18:10:59, Glauber Costa wrote:
> > >>>>The memory we used to hold the memcg arrays is currently accounted to
> > >>>>the current memcg.
> > >>>
> > >>>Maybe I have missed a train but I thought that only some caches are
> > >>>tracked and those have to be enabled explicitly by using __GFP_KMEMCG in
> > >>>gfp flags.
> > >>
> > >>No, all caches are tracked. This was set a long time ago, and only a
> > >>very few initial versions differed from this. This barely changed over
> > >>the lifetime of the memcg patchset.
> > >>
> > >>You probably got confused, due to the fact that only some *allocations*
> > >
> > >OK, I was really imprecise. Of course any type of cache might be tracked
> > >should the allocation (which takes gfp) say so. What I have missed is
> > >that not only stack allocations say so but also kmalloc itself enforces
> > >that rather than the actual caller of kmalloc. This is definitely new
> > >to me. And it is quite confusing that the flag is set only for large
> > >allocations (kmalloc_order) or am I just missing other parts where
> > >__GFP_KMEMCG is set unconditionally?
> > >
> > >I really have to go and dive into the code.
> > >
> > 
> > Here is where you are getting your confusion: we don't track caches,
> > we track *pages*.
> > 
> > Everytime you pass GFP_KMEMCG to a *page* allocation, it gets tracked.
> > Every memcg cache - IOW, a memcg copy of a slab cache, sets
> > GFP_KMEMCG for all its allocations.
> 
> yes that is clear to me.
> 
> > Now, the slub - and this is really an implementation detail -
> > doesn't have caches for high order kmalloc caches. Instead, it gets
> > pages directly from the page allocator. So we have to mark them
> > explicitly. (they are a cache, they are just not implemented as
> > such)
> 
> I am still confused. If kmalloc_large_node is called because the size of
> the object is larger than SLUB_MAX_SIZE then __GFP_KMEMCG is added
> automatically regardless what _caller_ of kmalloc said. What am I
> missing?
>  

You are not missing anything, I am.

It was not a problem since now because all allocations being bypassed
were pretty small - so I got blinded by this.

The logic I have explained to you is correct and will for 100 % of the
time for the SLAB. The SLUB allocator, however, will ignore our bypassing
request because it will never get to memcg_kmem_get_cache.

It doesn't hurt to have the bypass check at memcg_kmem_newpage_charge as
well, so I will add it - Thank you very much for noticing this.

The only situation in which it *could* hurt to have an extra check in there,
is if we decide to bypass the allocations somewhere inside the slab caches
themselves, in such a way that we would select a memcg cache at
memcg_kmem_get_cache, but then insert a non-memcg page in it because between
the cache selection and the allocation there was a bypass request.

As long as we keep the bypass requests memcg-internal, it should not be
a problem.

So in a summary: We will need two patches instead of one to tackle this.
I will send you shortly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

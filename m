Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6F26B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:32:49 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id g12so983576oah.17
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:32:49 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id sp3si1327961obb.95.2014.02.19.11.32.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 11:32:48 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 14:32:47 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9D01D6E8060
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:32:40 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1JJT8pq5571068
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 19:32:45 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1JGVRjb010817
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:31:27 -0500
Date: Wed, 19 Feb 2014 08:26:04 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140219162604.GC27108@linux.vnet.ibm.com>
References: <20140218090658.GA28130@dhcp22.suse.cz>
 <20140218233404.GB10844@linux.vnet.ibm.com>
 <20140219082313.GB14783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219082313.GB14783@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 19.02.2014 [09:23:13 +0100], Michal Hocko wrote:
> On Tue 18-02-14 15:34:05, Nishanth Aravamudan wrote:
> > Hi Michal,
> > 
> > On 18.02.2014 [10:06:58 +0100], Michal Hocko wrote:
> > > Hi,
> > > I have just noticed that ppc has RECLAIM_DISTANCE reduced to 10 set by
> > > 56608209d34b (powerpc/numa: Set a smaller value for RECLAIM_DISTANCE to
> > > enable zone reclaim). The commit message suggests that the zone reclaim
> > > is desirable for all NUMA configurations.
> > > 
> > > History has shown that the zone reclaim is more often harmful than
> > > helpful and leads to performance problems. The default RECLAIM_DISTANCE
> > > for generic case has been increased from 20 to 30 around 3.0
> > > (32e45ff43eaf mm: increase RECLAIM_DISTANCE to 30).
> > 
> > Interesting.
> > 
> > > I strongly suspect that the patch is incorrect and it should be
> > > reverted. Before I will send a revert I would like to understand what
> > > led to the patch in the first place. I do not see why would PPC use only
> > > LOCAL_DISTANCE and REMOTE_DISTANCE distances and in fact machines I have
> > > seen use different values.
> > > 
> > > Anton, could you comment please?
> > 
> > I'll let Anton comment here, but in looking into this issue in working
> > on CONFIG_HAVE_MEMORYLESS_NODE support, I realized that any LPAR with
> > memoryless nodes will set zone_reclaim_mode to 1. I think we want to
> > ignore memoryless nodes when we set up the reclaim mode like the
> > following? I'll send it as a proper patch if you agree?
> 
> Funny enough, ppc memoryless node setup is what led me to this code.
> We had a setup like this:
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
> node 0 size: 0 MB
> node 0 free: 0 MB
> node 2 cpus:
> node 2 size: 7168 MB
> node 2 free: 6019 MB
> node distances:
> node   0   2
> 0:  10  40
> 2:  40  10

Yeah, I think this happens fairly often ... and we didn't properly
support it (particularly with SLUB) on powerpc. I'll cc you on my
patchset.

> Which ends up enabling zone_reclaim although there is only a single node
> with memory. Not that RECLAIM_DISTANCE would make any difference here as
> the distance is even above default RECLAIM_DISTANCE.
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 5de4337..4f6ff6f 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1853,8 +1853,9 @@ static void __paginginit init_zone_allows_reclaim(int nid)
> >  {
> >         int i;
> >  
> > -       for_each_online_node(i)
> > -               if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> > +       for_each_online_node(i) {
> > +               if (node_distance(nid, i) <= RECLAIM_DISTANCE ||
> > +                                       local_memory_node(nid) != nid)
> >                         node_set(i, NODE_DATA(nid)->reclaim_nodes);
> >                 else
> >                         zone_reclaim_mode = 1;
> > 
> > Note, this won't actually do anything if CONFIG_HAVE_MEMORYLESS_NODES is
> > not set, but if it is, I think semantically it will indicate that
> > memoryless nodes *have* to reclaim remotely.
> > 
> > And actually the above won't work, because the callpath is
> > 
> > start_kernel -> setup_arch -> paging_init [-> free_area_init_nodes ->
> > free_area_init_node -> init_zone_allows_reclaim] which is called before
> > build_all_zonelists. This is a similar ordering problem as I'm having
> > with the MEMORYLESS_NODE support, will work on it.
> 
> I think you just want for_each_node_state(nid, N_MEMORY) and skip all
> the memory less nodes, no?

Yep, thanks!
-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

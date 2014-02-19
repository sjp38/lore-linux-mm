Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id BD0976B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 19:41:06 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id m1so20043045oag.20
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:41:06 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id tm2si13016278oeb.68.2014.02.18.16.41.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 16:41:06 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 18 Feb 2014 17:41:05 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 89EC71FF001A
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:41:01 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1IMcN768257796
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 23:38:23 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1J0f1Rh000880
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:41:01 -0700
Date: Tue, 18 Feb 2014 16:40:54 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140219004053.GA27108@linux.vnet.ibm.com>
References: <20140218090658.GA28130@dhcp22.suse.cz>
 <20140218233404.GB10844@linux.vnet.ibm.com>
 <20140218235800.GC10844@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140218235800.GC10844@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Anton Blanchard <anton@samba.org>, LKML <linux-kernel@vger.kernel.org>

On 18.02.2014 [15:58:00 -0800], Nishanth Aravamudan wrote:
> On 18.02.2014 [15:34:05 -0800], Nishanth Aravamudan wrote:
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
> > 
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
> How about the following?
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5de4337..1a0eced 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1854,7 +1854,8 @@ static void __paginginit init_zone_allows_reclaim(int nid)
>         int i;
>  
>         for_each_online_node(i)
> -               if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> +               if (node_distance(nid, i) <= RECLAIM_DISTANCE ||
> +                                       !NODE_DATA(nid)->node_present_pages)

err s/nid/i/ above.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA196B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:57:28 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so959067qcy.39
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 08:57:28 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id z79si1565936yhz.46.2014.02.19.08.57.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 08:57:27 -0800 (PST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 09:57:27 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 586043E4003F
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 09:57:23 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1JGuxxY55640068
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 17:56:59 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1JGcxO1001461
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 09:39:00 -0700
Date: Wed, 19 Feb 2014 08:33:45 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140219163345.GD27108@linux.vnet.ibm.com>
References: <20140218090658.GA28130@dhcp22.suse.cz>
 <20140218233404.GB10844@linux.vnet.ibm.com>
 <20140218235800.GC10844@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402181737530.17521@chino.kir.corp.google.com>
 <20140219162438.GB27108@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219162438.GB27108@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Anton Blanchard <anton@samba.org>, LKML <linux-kernel@vger.kernel.org>

On 19.02.2014 [08:24:38 -0800], Nishanth Aravamudan wrote:
> On 18.02.2014 [17:43:38 -0800], David Rientjes wrote:
> > On Tue, 18 Feb 2014, Nishanth Aravamudan wrote:
> > 
> > > How about the following?
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 5de4337..1a0eced 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1854,7 +1854,8 @@ static void __paginginit init_zone_allows_reclaim(int nid)
> > >         int i;
> > >  
> > >         for_each_online_node(i)
> > > -               if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> > > +               if (node_distance(nid, i) <= RECLAIM_DISTANCE ||
> > > +                                       !NODE_DATA(i)->node_present_pages)
> > >                         node_set(i, NODE_DATA(nid)->reclaim_nodes);
> > >                 else
> > >                         zone_reclaim_mode = 1;
> > 
> >  [ I changed the above from NODE_DATA(nid) -> NODE_DATA(i) as you caught 
> >    so we're looking at the right code. ]
> > 
> > That can't be right, it would allow reclaiming from a memoryless node.  I 
> > think what you want is
> 
> Gah, you're right.
> 
> > 	for_each_online_node(i) {
> > 		if (!node_present_pages(i))
> > 			continue;
> > 		if (node_distance(nid, i) <= RECLAIM_DISTANCE) {
> > 			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> > 			continue;
> > 		}
> > 		/* Always try to reclaim locally */
> > 		zone_reclaim_mode = 1;
> > 	}
> > 
> > but we really should be able to do for_each_node_state(i, N_MEMORY) here 
> > and memoryless nodes should already be excluded from that mask.
> 
> Yep, I found that afterwards, which simplifies the logic. I'll add this
> to my series :)

In looking at the code, I am wondering about the following:

init_zone_allows_reclaim() is called for each nid from
free_area_init_node(). Which means that calculate_node_totalpages for
other "later" nids and check_for_memory() [which sets up the N_MEMORY
nodemask] hasn't been called yet.

So, would it make sense to pull up the
                /* Any memory on that node */
                if (pgdat->node_present_pages)
                        node_set_state(nid, N_MEMORY);
                check_for_memory(pgdat, nid);
into free_area_init_node()?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

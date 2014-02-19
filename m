Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5FADE6B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 03:33:30 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id cc10so291387wib.17
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 00:33:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si5345355wif.78.2014.02.19.00.33.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 00:33:28 -0800 (PST)
Date: Wed, 19 Feb 2014 09:33:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140219083327.GC14783@dhcp22.suse.cz>
References: <20140218090658.GA28130@dhcp22.suse.cz>
 <20140218233404.GB10844@linux.vnet.ibm.com>
 <20140218235800.GC10844@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402181737530.17521@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402181737530.17521@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Anton Blanchard <anton@samba.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 18-02-14 17:43:38, David Rientjes wrote:
> On Tue, 18 Feb 2014, Nishanth Aravamudan wrote:
> 
> > How about the following?
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 5de4337..1a0eced 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1854,7 +1854,8 @@ static void __paginginit init_zone_allows_reclaim(int nid)
> >         int i;
> >  
> >         for_each_online_node(i)
> > -               if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> > +               if (node_distance(nid, i) <= RECLAIM_DISTANCE ||
> > +                                       !NODE_DATA(i)->node_present_pages)
> >                         node_set(i, NODE_DATA(nid)->reclaim_nodes);
> >                 else
> >                         zone_reclaim_mode = 1;
> 
>  [ I changed the above from NODE_DATA(nid) -> NODE_DATA(i) as you caught 
>    so we're looking at the right code. ]
> 
> That can't be right, it would allow reclaiming from a memoryless node.  I 
> think what you want is
> 
> 	for_each_online_node(i) {
> 		if (!node_present_pages(i))
> 			continue;
> 		if (node_distance(nid, i) <= RECLAIM_DISTANCE) {
> 			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> 			continue;
> 		}
> 		/* Always try to reclaim locally */
> 		zone_reclaim_mode = 1;
> 	}
> 
> but we really should be able to do for_each_node_state(i, N_MEMORY) here 
> and memoryless nodes should already be excluded from that mask.

Agreed! Actually the code I am currently interested in is based on 3.0
kernel where zone_reclaim_mode is set in build_zonelists which relies on
find_next_best_node which iterates only N_HIGH_MEMORY nodes which should
have non 0 present pages.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

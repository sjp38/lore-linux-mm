Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DFCBC6B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 16:56:02 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so933557pdj.11
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:56:02 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id fd10si972648pad.341.2014.02.19.13.56.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 13:56:02 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so971747pad.22
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:56:01 -0800 (PST)
Date: Wed, 19 Feb 2014 13:56:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm: exclude memory less nodes from zone_reclaim
In-Reply-To: <20140219175339.GG27108@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402191353540.31921@chino.kir.corp.google.com>
References: <20140219082313.GB14783@dhcp22.suse.cz> <1392829383-4125-1-git-send-email-mhocko@suse.cz> <20140219175339.GG27108@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 19 Feb 2014, Nishanth Aravamudan wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 3e953f07edb0..4a44bdc7a8cf 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1855,7 +1855,7 @@ static void __paginginit init_zone_allows_reclaim(int nid)
> >  {
> >  	int i;
> > 
> > -	for_each_online_node(i)
> > +	for_each_node_state(i, N_HIGH_MEMORY)
> >  		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> >  			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> >  		else
> > @@ -4901,7 +4901,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
> > 
> >  	pgdat->node_id = nid;
> >  	pgdat->node_start_pfn = node_start_pfn;
> > -	init_zone_allows_reclaim(nid);
> > +	if (node_state(nid, N_HIGH_MEMORY))
> > +		init_zone_allows_reclaim(nid);
> 
> I'm still new to this code, but isn't this saying that if a node has no
> memory, then it shouldn't reclaim from any node? But, for a memoryless
> node to ensure progress later if reclaim is necessary, it *must* reclaim
> from other nodes? So wouldn't we want to set reclaim_nodes() in that
> case to node_states[N_MEMORY]?
> 

The only time when pgdat->reclaim_nodes or zone_reclaim_mode matters is 
when iterating through a zonelist for page allocation and a memoryless 
node should never appear in a zonelist for page allocation, so this is 
just preventing setting zone_reclaim_mode unnecessarily because the only 
nodes with > RECLAIM_DISTANCE to another node are memoryless.  So this 
patch is fine as long as it gets s/N_HIGH_MEMORY/N_MEMORY/.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

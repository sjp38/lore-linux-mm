Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6513E6B0039
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:05:26 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id k15so1050911qaq.19
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 10:05:26 -0800 (PST)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id ew5si532918qab.87.2014.02.19.10.05.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 10:05:25 -0800 (PST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 13:05:23 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3A14538C803B
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:05:22 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1JI4uXx6488550
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:05:22 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1JGTrPI024056
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:29:53 -0500
Date: Wed, 19 Feb 2014 08:24:38 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140219162438.GB27108@linux.vnet.ibm.com>
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
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Anton Blanchard <anton@samba.org>, LKML <linux-kernel@vger.kernel.org>

On 18.02.2014 [17:43:38 -0800], David Rientjes wrote:
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

Gah, you're right.

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

Yep, I found that afterwards, which simplifies the logic. I'll add this
to my series :)

<snip>

> > I think it's safe to move init_zone_allows_reclaim, because I don't
> > think any allocates are occurring here that could cause us to reclaim
> > anyways, right? Moving it allows us to safely reference
> > node_present_pages.
> > 
> 
> Yeah, this is fine.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

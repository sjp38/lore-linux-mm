Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E5C4A6B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 18:10:28 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n99MAL3W015062
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 23:10:22 +0100
Received: from pzk13 (pzk13.prod.google.com [10.243.19.141])
	by zps37.corp.google.com with ESMTP id n99MAJBd010373
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 15:10:19 -0700
Received: by pzk13 with SMTP id 13so7154812pzk.25
        for <linux-mm@kvack.org>; Fri, 09 Oct 2009 15:10:19 -0700 (PDT)
Date: Fri, 9 Oct 2009 15:10:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 7/12] hugetlb:  add per node hstate attributes
In-Reply-To: <1255093027.14370.35.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0910091507350.12760@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162539.23192.3642.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910081339391.4765@chino.kir.corp.google.com>
 <1255093027.14370.35.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Oct 2009, Lee Schermerhorn wrote:

> > > +static void hugetlb_register_all_nodes(void)
> > > +{
> > > +	int nid;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > +		struct node *node = &node_devices[nid];
> > > +		if (node->sysdev.id == nid)
> > > +			hugetlb_register_node(node);
> > > +	}
> > 
> > This looks like another use of for_each_node_mask over N_HIGH_MEMORY.  I 
> > previously asked if the check for node->sysdev.id == nid is still 
> > necessary at this point?
> 
> 
> Sorry.  The check for sysdev.id == nid is there to ensure that this node
> sysdev has been registered when this function is called.  nr_node_ids is
> the maximum node id seen so far, but we can't assume that all nodes
> 0..nr_node_ids are present/on-line.  
> 
> As for using for_each_node_mask:  I think that would be OK.  This code
> works because hugetlb_register_node() filters out nodes w/o memory; so
> only visiting nodes with memory should work as well.  We can change this
> [for consistency] with an incremental patch, if you like.  
> 
> I'd hate to respin V11 for just this.  But, if we have to for other
> reasons, I'll [try to remember to] do this.
> 

I don't think it's necessary for a v11, I'd like to see this patchset 
(perhaps minus patch 12/12 until we figure out whether it's actually 
needed or not) added to -mm and then work on it there.  This particular 
case is only a small cleanup, but my curiosity really laid more in why 
node->sysdev.id == nid was necessary instead of simply using 
for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) since that should 
certainly be a subset of for_each_online_node(nid).

Thanks for the clarification, we can do an incremental patch on -mm once 
it's merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

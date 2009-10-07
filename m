Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BB0BC6B005A
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 10:13:33 -0400 (EDT)
Subject: Re: [PATCH 2/11] hugetlb:  add nodemask arg to huge page alloc,
 free and surplus adjust fcns
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0910062018070.3099@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
	 <20091006031751.22576.23355.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0910062018070.3099@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Wed, 07 Oct 2009 10:13:22 -0400
Message-Id: <1254924802.4483.70.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-10-06 at 20:26 -0700, David Rientjes wrote:
> On Mon, 5 Oct 2009, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-28 10:12:20.000000000 -0400
> > +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-09-30 11:41:36.000000000 -0400

> >  #ifdef CONFIG_HIGHMEM
> > -static void try_to_free_low(struct hstate *h, unsigned long count)
> > +static void try_to_free_low(struct hstate *h, unsigned long count,
> > +						nodemask_t *nodes_allowed)
> >  {
> >  	int i;
> >  
> >  	if (h->order >= MAX_ORDER)
> >  		return;
> >  
> > +	if (!nodes_allowed)
> > +		nodes_allowed = &node_online_map;
> > +
> >  	for (i = 0; i < MAX_NUMNODES; ++i) {
> >  		struct page *page, *next;
> >  		struct list_head *freel = &h->hugepage_freelists[i];
> > +		if (!node_isset(i, *nodes_allowed))
> > +			continue;
> >  		list_for_each_entry_safe(page, next, freel, lru) {
> >  			if (count >= h->nr_huge_pages)
> >  				return;
> 
> Simply converting the iteration to use
> for_each_node_mask(i, *nodes_allowed) would be cleaner.

OK.  That's equivalent.  Anyway, MAX_NUMNODES should probably have been
'numa_node_ids" or such.  And, now, nodes_allowed can't [shouldn't!] be
NULL here, as we default way up in the sysctl/sysfs handlers.  I'll fix
this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

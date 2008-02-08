Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m18GmZmZ019945
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 11:48:39 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18GmVUt194254
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 09:48:33 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18GmVXE016353
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 09:48:31 -0700
Date: Fri, 8 Feb 2008 08:48:29 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 1/3] hugetlb: numafy several functions
Message-ID: <20080208164829.GA15903@us.ibm.com>
References: <20080206231558.GI3477@us.ibm.com> <1202488644.11987.5.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1202488644.11987.5.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: wli@holomorphy.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.02.2008 [10:37:24 -0600], Adam Litke wrote:
> On Wed, 2008-02-06 at 15:15 -0800, Nishanth Aravamudan wrote:
> > @@ -141,6 +149,18 @@ static void free_huge_page(struct page *page)
> >   * balanced by operating on them in a round-robin fashion.
> >   * Returns 1 if an adjustment was made.
> >   */
> > +static int adjust_pool_surplus_node(int delta, int nid)
> > +{
> > +	if (delta < 0 && !surplus_huge_pages_node[nid])
> > +		return 0;
> > +	if (delta > 0 && surplus_huge_pages_node[nid] >=
> > +					nr_huge_pages_node[nid])
> > +		return 0;
> > +	surplus_huge_pages += delta;
> > +	surplus_huge_pages_node[nid] += delta;
> > +	return 1;
> > +}
> > +
> >  static int adjust_pool_surplus(int delta)
> >  {
> >  	static int prev_nid;
> > @@ -152,19 +172,9 @@ static int adjust_pool_surplus(int delta)
> >  		nid = next_node(nid, node_online_map);
> >  		if (nid == MAX_NUMNODES)
> >  			nid = first_node(node_online_map);
> > -
> > -		/* To shrink on this node, there must be a surplus page */
> > -		if (delta < 0 && !surplus_huge_pages_node[nid])
> > -			continue;
> > -		/* Surplus cannot exceed the total number of pages */
> > -		if (delta > 0 && surplus_huge_pages_node[nid] >=
> > -						nr_huge_pages_node[nid])
> > -			continue;
> 
> Unless I am misreading the diff, it seems the above comments were lost
> in translation.  I vote for preserving them :)  Otherwise this looks
> pretty good to me.

Oops, sorry about that, Adam. I'll update this in my next posting,
pending any other comments/testing feedback.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

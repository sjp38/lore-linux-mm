Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B14D6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:57:38 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i14so1564838pgf.13
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 22:57:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si806005pln.239.2017.11.28.22.57.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 22:57:37 -0800 (PST)
Date: Wed, 29 Nov 2017 07:57:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 1/2] mm, hugetlb: unify core page allocation
 accounting and initialization
Message-ID: <20171129065732.lm4yucdnaizr2mjb@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-2-mhocko@kernel.org>
 <4c919c6d-2e97-b66d-f572-439bb9f0587b@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c919c6d-2e97-b66d-f572-439bb9f0587b@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 28-11-17 13:34:53, Mike Kravetz wrote:
> On 11/28/2017 06:12 AM, Michal Hocko wrote:
[...]
> > +/*
> > + * Allocates a fresh page to the hugetlb allocator pool in the node interleaved
> > + * manner.
> > + */
> >  static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
> >  {
> >  	struct page *page;
> >  	int nr_nodes, node;
> > -	int ret = 0;
> > +	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
> >  
> >  	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
> > -		page = alloc_fresh_huge_page_node(h, node);
> > -		if (page) {
> > -			ret = 1;
> > +		page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask,
> > +				node, nodes_allowed);
> 
> I don't have the greatest understanding of node/nodemasks, but ...
> Since __hugetlb_alloc_buddy_huge_page calls __alloc_pages_nodemask(), do
> we still need to explicitly iterate over nodes with
> for_each_node_mask_to_alloc() here?

Yes we do, because callers depend on the round robin allocation policy
which is implemented by the ugly for_each_node_mask_to_alloc. I am not
saying I like the way this is done but this is user visible thing.

Or maybe I've missunderstood the whole thing...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

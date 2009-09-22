Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66F1A6B0055
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 16:13:31 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id n8MKDWuo005494
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 13:13:32 -0700
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by wpaz17.hot.corp.google.com with ESMTP id n8MKDTgR030967
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 13:13:29 -0700
Received: by pxi36 with SMTP id 36so62611pxi.18
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 13:13:29 -0700 (PDT)
Date: Tue, 22 Sep 2009 13:13:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/11] hugetlb:  rework hstate_next_node_* functions
In-Reply-To: <1253650095.4973.12.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0909221310390.24191@chino.kir.corp.google.com>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain> <20090915204333.4828.47722.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909221100000.10595@chino.kir.corp.google.com> <1253650095.4973.12.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009, Lee Schermerhorn wrote:

> > >  static int hstate_next_node_to_alloc(struct hstate *h)
> > >  {
> > > -	int next_nid;
> > > -	next_nid = next_node(h->next_nid_to_alloc, node_online_map);
> > > -	if (next_nid == MAX_NUMNODES)
> > > -		next_nid = first_node(node_online_map);
> > > +	int nid, next_nid;
> > > +
> > > +	nid = h->next_nid_to_alloc;
> > > +	next_nid = next_node_allowed(nid);
> > >  	h->next_nid_to_alloc = next_nid;
> > > -	return next_nid;
> > > +	return nid;
> > >  }
> > >  
> > >  static int alloc_fresh_huge_page(struct hstate *h)
> > 
> > I thought you had refactored this to drop next_nid entirely since gcc 
> > optimizes it away?
> 
> Looks like I handled that in the subsequent patch.  Probably you had
> commented about removing next_nid on that patch.
> 

Ah, I see it in 2/11, thanks.

> > > @@ -693,7 +711,7 @@ static int free_pool_huge_page(struct hs
> > >  	int next_nid;
> > >  	int ret = 0;
> > >  
> > > -	start_nid = h->next_nid_to_free;
> > > +	start_nid = hstate_next_node_to_free(h);
> > >  	next_nid = start_nid;
> > >  
> > >  	do {
> > > @@ -715,9 +733,10 @@ static int free_pool_huge_page(struct hs
> > >  			}
> > >  			update_and_free_page(h, page);
> > >  			ret = 1;
> > > +			break;
> > >  		}
> > >  		next_nid = hstate_next_node_to_free(h);
> > > -	} while (!ret && next_nid != start_nid);
> > > +	} while (next_nid != start_nid);
> > >  
> > >  	return ret;
> > >  }
> > > @@ -1028,10 +1047,9 @@ int __weak alloc_bootmem_huge_page(struc
> > >  		void *addr;
> > >  
> > >  		addr = __alloc_bootmem_node_nopanic(
> > > -				NODE_DATA(h->next_nid_to_alloc),
> > > +				NODE_DATA(hstate_next_node_to_alloc(h)),
> > >  				huge_page_size(h), huge_page_size(h), 0);
> > >  
> > > -		hstate_next_node_to_alloc(h);
> > >  		if (addr) {
> > >  			/*
> > >  			 * Use the beginning of the huge page to store the
> > 
> > Shouldn't that panic if hstate_next_node_to_alloc() returns a memoryless 
> > node since it uses node_online_map?
> 
> Well, the code has always been like this.  And, these allocs shouldn't
> panic given a memoryless node.  The run time ones don't anyway.  If
> '_THISNODE' is specified, it'll just fail with a NULL addr, else it's
> walk the generic zonelist to find the first node that can provide the
> requested page size.  Of course, we don't want that fallback when
> populating the pools with persistent huge pages, so we always use the
> THISNODE flag.
> 

Whether NODE_DATA() exists for a memoryless node is arch-dependent, I 
think, so the panic I was referring to was a NULL pointer in bootmem.  I 
think you're safe with the conversion to N_HIGH_MEMORY in patch 9/11 upon 
further inspection, though.

> Having said that, I've only recently started to [try to] create the
> gigabyte pages on my x86_64 [Shanghai] test system, but haven't been
> able to allocate any GB pages.  2.6.31 seems to hang early in boot with
> the command line options:  "hugepagesz=1GB, hugepages=16".  I've got
> 256GB of memory on this system, so 16GB shouldn't be a problem to find
> at boot time.  Just started looking at this.
> 

I can try to reproduce that on one of my systems too, I've never tried it 
before.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

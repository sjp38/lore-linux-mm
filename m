Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D27C6B004D
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 15:51:51 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id n88JptbR025244
	for <linux-mm@kvack.org>; Tue, 8 Sep 2009 12:51:55 -0700
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by wpaz5.hot.corp.google.com with ESMTP id n88JoZte029009
	for <linux-mm@kvack.org>; Tue, 8 Sep 2009 12:51:52 -0700
Received: by pzk17 with SMTP id 17so3623647pzk.16
        for <linux-mm@kvack.org>; Tue, 08 Sep 2009 12:51:52 -0700 (PDT)
Date: Tue, 8 Sep 2009 12:51:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for mempolicy
 based management.
In-Reply-To: <20090908104409.GB28127@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160351.11080.21379.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031254380.26408@chino.kir.corp.google.com> <1252012158.6029.215.camel@useless.americas.hpqcorp.net>
 <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com> <20090908104409.GB28127@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Mel Gorman wrote:

> > Yes, but the caveat I'm pointing out (and is really clearly described in 
> > your documentation changes here) is that existing applications, shell 
> > scripts, job schedulers, whatever, which currently free all system 
> > hugepages (or do so at a consistent interval down to the surplus 
> > value to reclaim memory) will now leak disjoint pages since the freeing is 
> > now governed by its mempolicy. 
> 
> While this is a possibility, it makes little sense to assume that behaviour. To
> be really bitten by the change, the policy used to allocate huge pages needs
> to be different than the policy used to free them. This would be a bit
> screwy as it would imply the job scheduler allocated pages that would
> then be unusable by the job if policies were being obeyed which makes
> very little sense.
> 

Au contraire, the hugepages= kernel parameter is not restricted to any 
mempolicy.

> > If the benefits of doing this 
> > significantly outweigh that potential for userspace breakage, I have no 
> > objection to it.  I just can't say for certain that it is.
> > 
> 
> An application depending on memory policies to be ignored is pretty broken
> to begin with.
> 

Theoretically, yes, but not in practice.  /proc/sys/vm/nr_hugepages has 
always allocated and freed with disregard to current's mempolicy prior to 
this patchset and it wouldn't be "broken" for an application to assume 
that it will continue to do so.  More broken is assuming that such an 
application should have been written to change its mempolicy to include 
all nodes that have hugepages prior to freeing because someday the kernel 
would change to do mempolicy-restricted hugepage freeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 941256B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 16:18:05 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n88KI8lZ012066
	for <linux-mm@kvack.org>; Tue, 8 Sep 2009 13:18:08 -0700
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by spaceape11.eur.corp.google.com with ESMTP id n88KI5mf018299
	for <linux-mm@kvack.org>; Tue, 8 Sep 2009 13:18:05 -0700
Received: by pzk31 with SMTP id 31so1948762pzk.23
        for <linux-mm@kvack.org>; Tue, 08 Sep 2009 13:18:04 -0700 (PDT)
Date: Tue, 8 Sep 2009 13:18:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for mempolicy
 based management.
In-Reply-To: <20090908200451.GA6481@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160351.11080.21379.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031254380.26408@chino.kir.corp.google.com> <1252012158.6029.215.camel@useless.americas.hpqcorp.net>
 <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com> <20090908104409.GB28127@csn.ul.ie> <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com> <20090908200451.GA6481@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Mel Gorman wrote:

> > Au contraire, the hugepages= kernel parameter is not restricted to any 
> > mempolicy.
> > 
> 
> I'm not seeing how it would be considered symmetric to compare allocation
> at a boot-time parameter with freeing happening at run-time within a mempolicy.
> It's more plausible to me that such a scenario will having the freeing
> thread either with no policy or the ability to run with no policy
> applied.
> 

Imagine a cluster of machines that are all treated equally to serve a 
variety of different production jobs.  One of those production jobs 
requires a very high percentage of hugepages.  In fact, its performance 
gain is directly proportional to the number of hugepages allocated.

It is quite plausible for all machines to be booted with hugepages= to 
achieve the maximum number of hugepages that those machines may support.  
Depending on what jobs they will serve, however, those hugepages may 
immediately be freed (or a subset, depending on other smaller jobs that 
may want them.)  If the job scheduler is bound to a mempolicy which does 
not include all nodes with memory, those hugepages are now leaked.  That 
was not the behavior over the past three or four years until this 
patchset.

That example is not dealing in hypotheticals or assumptions on how people 
use hugepages, it's based on reality.  As I said previously, I don't 
necessarily have an objection to that if it can be shown that the 
advantages significantly outweigh the disadvantages.  I'm not sure I see 
the advantage in being implict vs. explicit, however.  Mempolicy 
allocation and freeing is now _implicit_ because its restricted to 
current's mempolicy when it wasn't before, yet node-targeted hugepage 
allocation and freeing is _explicit_ because it's a new interface and on 
the same granularity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

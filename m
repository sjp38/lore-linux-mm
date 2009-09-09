Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CEF736B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 16:44:35 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n89KiaSc007286
	for <linux-mm@kvack.org>; Wed, 9 Sep 2009 13:44:36 -0700
Received: from pxi41 (pxi41.prod.google.com [10.243.27.41])
	by spaceape8.eur.corp.google.com with ESMTP id n89Khr2u026623
	for <linux-mm@kvack.org>; Wed, 9 Sep 2009 13:44:33 -0700
Received: by pxi41 with SMTP id 41so1797568pxi.30
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 13:44:33 -0700 (PDT)
Date: Wed, 9 Sep 2009 13:44:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for mempolicy
 based management.
In-Reply-To: <20090909081631.GB24614@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com>
References: <20090828160351.11080.21379.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031254380.26408@chino.kir.corp.google.com> <1252012158.6029.215.camel@useless.americas.hpqcorp.net> <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com>
 <20090908104409.GB28127@csn.ul.ie> <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com> <20090908200451.GA6481@csn.ul.ie> <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com> <20090908214109.GB6481@csn.ul.ie>
 <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com> <20090909081631.GB24614@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Sep 2009, Mel Gorman wrote:

> And to beat a dead horse, it does make sense that an application
> allocating hugepages obey memory policies. It does with dynamic hugepage
> resizing for example. It should have been done years ago and
> unfortunately wasn't but it's not the first time that the behaviour of
> hugepages differed from the core VM.
> 

I agree completely, I'm certainly not defending the current implementation 
as a sound design and I too would have preferred that it have done the 
same as Lee's patchset from the very beginning.  The issue I'm raising is 
that while we both agree the current behavior is suboptimal and confusing, 
it is the long-standing kernel behavior.  There are applications out there 
that are written to allocate and free hugepages and now changing the pool 
from which they can allocate or free to could be problematic.

I'm personally fine with the breakage since I'm aware of this discussion 
and can easily fix it in userspace.  I'm more concerned about others 
leaking hugepages or having their boot scripts break because they are 
allocating far fewer hugepages than before.  The documentation 
(Documentation/vm/hugetlbpage.txt) has always said 
/proc/sys/vm/nr_hugepaegs affects hugepages on a system level and now that 
it's changed, I think it should be done explicitly with a new flag than 
implicitly.

Would you explain why introducing a new mempolicy flag, MPOL_F_HUGEPAGES, 
and only using the new behavior when this is set would be inconsistent or 
inadvisible?  Since this is a new behavior that will differ from the 
long-standing default, it seems like it warrants a new mempolicy flag to 
avoid all userspace breakage and make hugepage allocation and freeing with 
an underlying mempolicy explicit.

This would address your audience that have been (privately) emailing you 
while confused about why the hugepages being allocated from a global 
tunable wouldn't be confined to their mempolicy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

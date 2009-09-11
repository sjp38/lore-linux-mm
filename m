Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 094626B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 18:38:32 -0400 (EDT)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n8BMcVwd028630
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 23:38:31 +0100
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by spaceape14.eur.corp.google.com with ESMTP id n8BMcScQ007880
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 15:38:28 -0700
Received: by pxi10 with SMTP id 10so1257685pxi.24
        for <linux-mm@kvack.org>; Fri, 11 Sep 2009 15:38:27 -0700 (PDT)
Date: Fri, 11 Sep 2009 15:38:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] hugetlb:  introduce alloc_nodemask_of_node
In-Reply-To: <1252674684.4392.222.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0909111529590.22083@chino.kir.corp.google.com>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain> <20090909163146.12963.79545.sendpatchset@localhost.localdomain> <20090910160541.9f902126.akpm@linux-foundation.org> <1252674684.4392.222.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 11 Sep 2009, Lee Schermerhorn wrote:

> > It's a bit rude to assume that the caller wanted to use GFP_KERNEL.
> 
> I can add a gfp_t parameter to the macro, but I'll still need to select
> value in the caller.  Do you have a suggested alternative to GFP_KERNEL
> [for both here and in alloc_nodemask_of_mempolicy()]?  We certainly
> don't want to loop forever, killing off tasks, as David mentioned.
> Silently failing is OK.  We handle that.
> 

Dynamically allocating the nodemask_t for small NODES_SHIFT and failing to 
find adequate memory isn't as troublesome as I may have made it sound; 
it's only a problem if we're low on memory and can't do order-0 GFP_KERNEL 
allocations and the kmalloc cache for that size is full.  That's going to 
be extremely rare, but the first requirement, being low on memory, is one 
of the reasons why people traditionally free hugepages via the tunable.

As far as the software engineering of alloc_nodemask_of_node() goes, I'd 
defer back to my previous suggestion of modifying NODEMASK_ALLOC() which 
has very much the same purpose.  It's also only used with mempolicies 
because we're frequently dealing with the same issue; this is not unique 
only to hugetlb, which is probably why it was made generic in the first 
place.

It has the added benefit of also incorporating my other suggestion, which 
was to allocate these on the stack when NODES_SHIFT is small, which it 
defaults to for all architectures other than ia64.  I think it would be 
nice to avoid the slab allocator for relatively small (<= 256 bytes?) 
amounts of memory that could otherwise be stack allocated.  That's more of 
a general statement with regard to the entire kernel, but I don't think 
you'll find much benefit in always allocating them from slab for code 
clarity when NODEMASK_ALLOC() exists for the same purpose such as 
set_mempolicy(), mbind(), etc.

So I'd ask that you reconsider using NODEMASK_ALLOC() by making it more 
general (i.e. not just allocating "structs of <name>" but rather pass in 
the entire type such as "nodemask_t" or "struct nodemask_scratch") and 
then using it to dynamically allocate your hugetlb nodemasks when 
necessary because of their size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

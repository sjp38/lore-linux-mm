Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B05156B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 19:43:54 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n8ANhtXO021347
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 16:43:55 -0700
Received: from qyk6 (qyk6.prod.google.com [10.241.83.134])
	by wpaz1.hot.corp.google.com with ESMTP id n8ANhMrR030860
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 16:43:53 -0700
Received: by qyk6 with SMTP id 6so42437qyk.9
        for <linux-mm@kvack.org>; Thu, 10 Sep 2009 16:43:52 -0700 (PDT)
Date: Thu, 10 Sep 2009 16:43:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] hugetlb:  introduce alloc_nodemask_of_node
In-Reply-To: <20090910163641.9ebaa601.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.00.0909101638290.27541@chino.kir.corp.google.com>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain> <20090909163146.12963.79545.sendpatchset@localhost.localdomain> <20090910160541.9f902126.akpm@linux-foundation.org> <alpine.DEB.1.00.0909101614060.25078@chino.kir.corp.google.com>
 <20090910163641.9ebaa601.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lee.schermerhorn@hp.com, linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 Sep 2009, Andrew Morton wrote:

> > > alloc_nodemask_of_node() has no callers, so I can think of a good fix
> > > for these problems.  If it _did_ have a caller then I might ask "can't
> > > we fix this by moving alloc_nodemask_of_node() into the .c file".  But
> > > it doesn't so I can't.
> > > 
> > 
> > It gets a caller in patch 5 of the series in set_max_huge_pages().
> 
> ooh, there it is.
> 
> So alloc_nodemask_of_node() could be moved into mm/hugetlb.c.
> 

We discussed that, but the consensus was that it specific to mempolicies 
not hugepages.  Perhaps someday it will gain another caller.

> > My early criticism of both alloc_nodemask_of_node() and 
> > alloc_nodemask_of_mempolicy() was that for small CONFIG_NODES_SHIFT (say, 
> > 6 or less, which covers all defconfigs except ia64), it is perfectly 
> > reasonable to allocate 64 bytes on the stack in the caller.
> 
> Spose so.  But this stuff is only called when userspace reconfigures
> via sysfs, so it'll be low bandwidth (one sincerely hopes).
> 

True, but order-0 GFP_KERNEL allocations will loop forever in the page 
allocator and kill off tasks if it can't allocate memory.  That wouldn't 
necessarily be a cause for concern other than the fact that this tunable 
is already frequently written when memory is low to reclaim pages.

 [ If we're really tailoring it only for its current use case, though, the 
   stack could easily support even NODES_SHIFT of 10. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

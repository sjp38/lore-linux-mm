Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 71E486B01F2
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:13:16 -0400 (EDT)
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.1004161105120.7710@router.home>
References: 
	 <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <4BC65237.5080408@kernel.org>
	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
	 <4BC6BE78.1030503@kernel.org>
	 <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
	 <4BC6CB30.7030308@kernel.org>
	 <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>
	 <4BC6E581.1000604@kernel.org>
	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
	 <4BC6FBC8.9090204@kernel.org>
	 <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>
	 <alpine.DEB.2.00.1004161105120.7710@router.home>
Content-Type: text/plain
Date: Fri, 16 Apr 2010 15:13:09 -0400
Message-Id: <1271445189.30360.280.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-04-16 at 11:07 -0500, Christoph Lameter wrote:
> On Thu, 15 Apr 2010, Minchan Kim wrote:
> 
> > I don't want to remove alloc_pages for UMA system.
> 
> alloc_pages is the same as alloc_pages_any_node so why have it?
> 
> > #define alloc_pages alloc_page_sexact_node
> >
> > What I want to remove is just alloc_pages_node. :)
> 
> Why remove it? If you want to get rid of -1 handling then check all the
> callsites and make sure that they are not using  -1.
> 
> Also could you define a constant for -1? -1 may have various meanings. One
> is the local node and the other is any node. 

NUMA_NO_NODE is #defined as (-1) and can be used for this purpose.  '-1'
has been replaced by this in many cases.   It can be interpreted as "No
node specified" == "any node is acceptable".  But, it also has multiple
meanings.  E.g., in the hugetlb sysfs attribute and sysctl functions it
indicates the global hstates [all nodes] vs a per node hstate.  So, I
suppose one could define a NUMA_ANY_NODE, to make the intention clear at
the call site.

I believe that all usage of -1 to mean the local node has been removed,
unless I missed one.  Local allocation is now indicated by a mempolicy
mode flag--MPOL_F_LOCAL.  It's treated as a special case of
MPOL_PREFERRED.

> The difference is if memory
> policies are obeyed or not. Note that alloc_pages follows memory policies
> whereas alloc_pages_node does not.
> 
> Therefore
> 
> alloc_pages() != alloc_pages_node(  , -1)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

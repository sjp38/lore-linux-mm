Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 698FB6B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 23:33:43 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n963XZvH009348
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 04:33:35 +0100
Received: from pzk42 (pzk42.prod.google.com [10.243.19.170])
	by wpaz21.hot.corp.google.com with ESMTP id n963XWjg024582
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 20:33:32 -0700
Received: by pzk42 with SMTP id 42so2154039pzk.31
        for <linux-mm@kvack.org>; Mon, 05 Oct 2009 20:33:32 -0700 (PDT)
Date: Mon, 5 Oct 2009 20:33:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/10] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <1254797641.21534.72.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0910052024570.17606@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910021513090.18180@chino.kir.corp.google.com> <1254741326.4389.16.camel@useless.americas.hpqcorp.net>
 <alpine.DEB.1.00.0910051354380.10476@chino.kir.corp.google.com> <1254797641.21534.72.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Lee Schermerhorn wrote:

> > this 
> > particular patch adds NODEMASK_ALLOC(nodemask, nodes_allowed) which would 
> > expand out to allocating a "struct nodemask" either dynamically or on the 
> > stack and such an object doesn't exist in the kernel.
> 
> and in include/linux/nodemask.h, I see:
> 
> 	typedef struct nodemask { DECLARE_BITMAP(bits, MAX_NUMNODES); } nodemask_t;
> 
> Don't know why you're seeing that error this series on mmotm-090925...
> 

This is

	typedef struct { DECLARE_BITMAP(bits, MAX_NUMNODES); } nodemask_t;

in include/linux/nodemask.h; it has been anonymous as long as Linus' git 
history has been around.  Perhaps you changed this locally but didn't 
generate a diff hunk for it when you sent the patches?

Regardless, there is no "struct nodemask" in the kernel so this patchset 
will fail to build on vanilla mmotm-09251435.  I think we can leave 
nodemask_t alone and simply merge my patch so that NODEMASK_ALLOC can work 
on anonymous structs as well.

> > Feel free to just fold it into patch 4 so the series builds incrementally.
> 
> In V9, I have it as a separate patch, primarily to maintain attribution
> for now.

Attribution is easy by just adding

	[rientjes@google.com: make NODEMASK_ALLOC more general]

before your Signed-off-by line and picking up my Signed-off-by line from 
my patch proposal; that's why I proposed it the way I did.  This indicates 
you've folded a fix by rientjes@google.com into your patch with a short 
description of what I did.

> I had originally thought that it would be easy to include this
> patch or not, depending on whether your NODEMASK_ALLOC generalization
> patch was already merged.  But, this fix causes a messy patch rejection
> in the per node attributes patch, so having separate really doesn't help
> that.  V9 depends on your patch now.
> 

Once your tree is cleaned so that it no longer includes a "struct 
nodemask," I think you'll favor my suggestion because then each patch in 
the series successfully builds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

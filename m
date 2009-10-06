Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 40CB46B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 22:54:09 -0400 (EDT)
Subject: Re: [PATCH 4/10] hugetlb:  derive huge pages nodes allowed from
 task mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0910051354380.10476@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
	 <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0910021513090.18180@chino.kir.corp.google.com>
	 <1254741326.4389.16.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.1.00.0910051354380.10476@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Mon, 05 Oct 2009 22:54:01 -0400
Message-Id: <1254797641.21534.72.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-10-05 at 13:58 -0700, David Rientjes wrote:
> On Mon, 5 Oct 2009, Lee Schermerhorn wrote:
> 
> > > mm/hugetlb.c: In function 'nr_hugepages_store_common':
> > > mm/hugetlb.c:1368: error: storage size of '_m' isn't known
> > > mm/hugetlb.c:1380: warning: passing argument 1 of 'init_nodemask_of_mempolicy' from incompatible pointer type
> > > mm/hugetlb.c:1382: warning: assignment from incompatible pointer type
> > > mm/hugetlb.c:1390: warning: passing argument 1 of 'init_nodemask_of_node' from incompatible pointer type
> > > mm/hugetlb.c:1392: warning: passing argument 3 of 'set_max_huge_pages' from incompatible pointer type
> > > mm/hugetlb.c:1394: warning: comparison of distinct pointer types lacks a cast
> > > mm/hugetlb.c:1368: warning: unused variable '_m'
> > > mm/hugetlb.c: In function 'hugetlb_sysctl_handler_common':
> > > mm/hugetlb.c:1862: error: storage size of '_m' isn't known
> > > mm/hugetlb.c:1864: warning: passing argument 1 of 'init_nodemask_of_mempolicy' from incompatible pointer type
> > > mm/hugetlb.c:1866: warning: assignment from incompatible pointer type
> > > mm/hugetlb.c:1868: warning: passing argument 3 of 'set_max_huge_pages' from incompatible pointer type
> > > mm/hugetlb.c:1870: warning: comparison of distinct pointer types lacks a cast
> > > mm/hugetlb.c:1862: warning: unused variable '_m'
> > 
> > 
> > ??? This is after your rework of NODEMASK_ALLOC has been applied?  I
> > don't see this when I build the mmotm that the patch is based on.  
> > 
> 
> This was mmotm-09251435 plus this entire patchset.
> 
> You may want to check your toolchain if you don't see these errors, 


Hmmm, I'm using :

	gcc (SUSE Linux) 4.3.2 [gcc-4_3-branch revision 141291]

> this 
> particular patch adds NODEMASK_ALLOC(nodemask, nodes_allowed) which would 
> expand out to allocating a "struct nodemask" either dynamically or on the 
> stack and such an object doesn't exist in the kernel.

and in include/linux/nodemask.h, I see:

	typedef struct nodemask { DECLARE_BITMAP(bits, MAX_NUMNODES); } nodemask_t;

Don't know why you're seeing that error this series on mmotm-090925...

> > I guess I'll tack this onto the end of V9 with a note that it depends on
> > your patch.  Altho' for bisection builds, I might want to break it into
> > separate patches that apply to the mempolicy and per node attributes
> > patches, respectively.
> > 
> 
> Feel free to just fold it into patch 4 so the series builds incrementally.

In V9, I have it as a separate patch, primarily to maintain attribution
for now.  I had originally thought that it would be easy to include this
patch or not, depending on whether your NODEMASK_ALLOC generalization
patch was already merged.  But, this fix causes a messy patch rejection
in the per node attributes patch, so having separate really doesn't help
that.  V9 depends on your patch now.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

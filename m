Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l943EFix013133
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 23:14:15 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l943CkrA521556
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 23:12:46 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l943Ca1I000505
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 23:12:36 -0400
Date: Wed, 3 Oct 2007 20:12:29 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 2/2] hugetlb: fix pool allocation with empty nodes
Message-ID: <20071004031229.GE29663@us.ibm.com>
References: <20071003224538.GB29663@us.ibm.com> <20071003224904.GC29663@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071003224904.GC29663@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: wli@holomorphy.com, anton@samba.org, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.10.2007 [15:49:04 -0700], Nishanth Aravamudan wrote:
> hugetlb: fix pool allocation with empty nodes
> 
> Anton found a problem with the hugetlb pool allocation when some nodes
> have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
> worked on versions that tried to fix it, but none were accepted.
> Christoph has created a set of patches which allow for GFP_THISNODE
> allocations to fail if the node has no memory and for exporting a
> nodemask indicating which nodes have memory. Simply interleave across
> this nodemask rather than the online nodemask.
> 
> Tested on x86 !NUMA, x86 NUMA, x86_64 NUMA, ppc64 NUMA with 2 memoryless
> nodes.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> ---
> Would it be better to combine this patch directly in 1/2? There is no
> functional difference, really, just a matter of 'correctness'. Without
> this patch, we'll iterate over nodes that we can't possibly do THISNODE
> allocations on. So I guess this falls more into an optimization?
> 
> Also, I see that Adam's patches have been pulled in for the next -mm. I
> can rebase on top of them and retest to minimise Andrew's work.

FWIW, both patches apply pretty easily on top of Adam's stack. 1/2
requires a bit of massaging because functions have moved out of their
context, but 2/2 applies cleanly. I noticed, though, that Adam's patches
use node_online_map when they should use node_states[N_HIGH_MEMORY], so
shall I modify this patch to simply be

hugetlb: only iterate over populated nodes

and fix all of the instances in hugetlb.c?

Still need to test the patches on top of Adam's stack before I'll ask
Andrew to pick them up.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

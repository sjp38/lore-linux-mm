Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9B4BMVG021587
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 00:11:22 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B4BL6x406382
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 22:11:21 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B4BKtk022534
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 22:11:21 -0600
Date: Wed, 10 Oct 2007 21:11:19 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] hugetlb: fix hugepage allocation with memoryless nodes
Message-ID: <20071011041119.GB32657@us.ibm.com>
References: <20071009012724.GA26472@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071009012724.GA26472@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, mel@csn.ul.ie, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.10.2007 [18:27:24 -0700], Nishanth Aravamudan wrote:
> hugetlb: fix hugepage allocation with memoryless nodes

<snip>

> ---
>  mm/hugetlb.c |   63 ++++++++++++++++++++++++++++++++++++++++-------------------
>  1 file changed, 43 insertions(+), 20 deletions(-)
> 
> Andrew, this patch alone suffices to fix the hugetlb pool allocation
> with memoryless nodes and is rebased on 2.6.23-rc8-mm2 + Adam's 5
> patches. What I had been sending as patch 2/2 (which pretty much just
> did `sed -i s/node_online_map/node_states[N_HIGH_MEMORY]/ mm/hugetlb.c`)
> will need to be extended/tested for the new loops in hugetlb.c, but that
> is an efficiency concern, not a correctness one. I'd like to see if we
> can get this patch in 2.6.24, so if you could pick it up for the next
> -mm, I'd greatly appreciate it.
> 
> Also, I wonder (and have suggested this before): would it make sense to
> put a VM_BUG_ON (VM_BUG_ON_ONCE, if it exists) for GFP_THISNODE
> allocations coming from a node other than the one specified in the core
> VM under DEBUG_VM or something? That would have caught the case that
> Mel's one-zonelist stack created, I think.
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3d1b111..098e608 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -32,6 +32,7 @@ static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
>  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
>  int hugetlb_dynamic_pool;
> +static int last_allocated_nid;

While reworking patch 2/2 to incorporate the current state of hugetlb.c
after Adam's stack is applied, I realized that this is not a very good
name. It actually is the *current* nid to try to allocate hugepages on.

Christoph, since you proposed the name, do you think

hugetlb_current_nid

is ok, too? If so I'll change the name throughout the patch (no
functional change).

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

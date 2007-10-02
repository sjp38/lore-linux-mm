Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l92MlLfU031017
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 18:47:21 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92MlLAK418094
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 16:47:21 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92MlLfn017118
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 16:47:21 -0600
Date: Tue, 2 Oct 2007 15:47:19 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 2/4] hugetlb: fix pool allocation with empty nodes
Message-ID: <20071002224719.GB13137@us.ibm.com>
References: <20070906182134.GA7779@us.ibm.com> <20070906182430.GB7779@us.ibm.com> <Pine.LNX.4.64.0709141152250.17038@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709141152250.17038@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: anton@samba.org, wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.09.2007 [11:53:25 -0700], Christoph Lameter wrote:
> On Thu, 6 Sep 2007, Nishanth Aravamudan wrote:
> 
> >  	if (nid < 0)
> > -		nid = first_node(node_online_map);
> > +		nid = first_node(node_states[N_HIGH_MEMORY]);
> >  	start_nid = nid;
> 
> Can huge pages live in high memory? Otherwise I think we could use
> N_REGULAR_MEMORY here. There may be issues on 32 bit NUMA if we
> attempt to allocate memory from the highmem nodes.

hugepages are allocated with:

	htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN

where

	static gfp_t htlb_alloc_mask = GFP_HIGHUSER;

which, in turn, is:

	#define GFP_HIGHUSER \
	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | __GFP_HIGHMEM)

So, yes, they can come from HIGHMEM, AFAICT. And I've tested this
patchset (at some point in the past admittedly) on NUMA-Q.

But I'm confused by your question altogether now. Looking at
2.6.23-rc8-mm2:

memoryless-nodes-introduce-mask-of-nodes-with-memory
(74a0f5ea5609629a07fd73d59bde255a56a57fa5):

A node has its bit in N_HIGH_MEMORY set if it has any memory regardless
of t type of memory.  If a node has memory then it has at least one zone
defined in its pgdat structure that is located in the pgdat itself.

And, indeed, if CONFIG_HIGHMEM is off, N_HIGH_MEMORY == N_NORMAL_MEMORY.

So I think I'm ok?

I'll make sure to test on 32-bit NUMA (well, if 2.6.23-rc8-mm2 works on
it, of course. Looks like -mm1 did and -mm2 is still pending.)

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

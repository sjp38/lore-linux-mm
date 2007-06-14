Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5EG9FHS011684
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 12:09:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5EG9Fus152936
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 12:09:15 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5EG9FPO020548
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 12:09:15 -0400
Date: Thu, 14 Jun 2007 09:09:13 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070614160913.GF7469@us.ibm.com>
References: <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com> <1181677473.5592.149.camel@localhost> <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com> <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost> <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost> <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com> <1181836247.5410.85.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181836247.5410.85.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.06.2007 [11:50:47 -0400], Lee Schermerhorn wrote:
> On Wed, 2007-06-13 at 15:51 -0700, Christoph Lameter wrote:
> > On Wed, 13 Jun 2007, Lee Schermerhorn wrote:
> > 
> > > Yep.  I'm testing the stack "as is" now.  If it doesn't spread the huge
> > > pages evenly because of our funky DMA-only node, I'll post a fix up
> > > patch for consideration.
> > 
> > Note that the memory from your DMA only node is allocated without 
> > requiring DMA memory. We just fall back in the allocation to DMA memory.
> > Thus you do not need special handling as far as I can tell.
> 
> Just a note to clarify what was happening.  I already described the
> zonelist selected by the gfp_zone for that node.  The first zone in
> the list was on node 0, so everytime the interleave cursor specified
> node 4, I got a page on node0.  I ended up with twice as many huge
> pages on node 0 as any other node.  
> 
> Nish's code also got the accounting wrong when he changed
> "nr_huge_pages_node[page_to_nid(page)]++;" to
> "nr_huge_pages_node[nid]++;" in his "numafy several functions" patch.
> This caused the total/free counts to get out of sync and the total
> count on node 0 to go negative when I free the pages.  This won't
> happen if alloc_pages_node() never returns off-node pages.  

Yep, that last sentence is the key. Regardless of NUMA layout, I would
like to rely (and I believe these are the semantics we are striving for)
on GFP_THISNODE allocations only returning pages on the node. Perhaps
we should add some WARN_ON()'s to the VM so any modifications that break
this assumption will be detected quickly? e.g.

	WARN_ON(page_to_nid(page) != nid)

<snip>

> The point of all this is that, as you've pointed out, the original
> NUMA and memory policy designs assumed a fairly symmetric system
> configuration with all nodes populated with [similar amounts?] of
> roughly equivalent memory.  That probably describes a majority of NUMA
> systems, so the system should handle this well, as a default.  We
> still need to be able to handle the less symmetric configs--with boot
> parameters, sysctls, cpusets, ...--that specify non-default behavior,
> and cause the generic code to do the right thing.  Certainly, the
> generic code can't "fall over and die" in the presence of memoryless
> nodes or other "interesting" configurations.

Agreed,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

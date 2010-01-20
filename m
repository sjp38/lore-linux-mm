Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 680A66B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 15:48:16 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o0KKmCrL016495
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 12:48:13 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by kpbe19.cbf.corp.google.com with ESMTP id o0KKmB2R024867
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 12:48:11 -0800
Received: by pwj4 with SMTP id 4so3663425pwj.20
        for <linux-mm@kvack.org>; Wed, 20 Jan 2010 12:48:11 -0800 (PST)
Date: Wed, 20 Jan 2010 12:48:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/7] Add /proc trigger for memory compaction
In-Reply-To: <20100120094813.GC5154@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1001201241540.6440@chino.kir.corp.google.com>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-6-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001071352100.23894@chino.kir.corp.google.com> <20100120094813.GC5154@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 2010, Mel Gorman wrote:

> > With Lee's work on mempolicy-constrained hugepage allocations, there is a 
> > use-case for this explicit trigger to be exported via sysfs in the 
> > longterm:
> 
> True, although the per-node structures are only available on NUMA making
> it necessary to have two interfaces. The per-node one is handy enough
> because it would be just
> 
> /sys/devices/system/node/nodeX/compact_node
> 	When written to, this node is compacted by the writing process
> 
> But there does not appear to be a "good" way of having a non-NUMA
> interface. /sys/devices/system/node does not exist .... Does anyone
> remember why !NUMA does not have a /sys/devices/system/node/node0? Is
> there a good reason or was there just no point?
> 

There doesn't seem to be a usecase for a fake node0 sysfs entry since it 
would be a duplication of procfs.

I think it would be best to create a global /proc/sys/vm/compact trigger 
that would walk all "compactable" zones system-wide and then a per-node 
/sys/devices/system/node/nodeX/compact trigger for that particular node, 
both with permissions 0200.

It would be helpful to be able to determine what is "compactable" at the 
same time by adding both global and per-node "compact_order" tunables that 
would default to HUGETLB_PAGE_ORDER.  Then, the corresponding "compact" 
trigger would only do work if fill_contig_page_info() shows 
!free_blocks_suitable for either all zones (global trigger) or each zone 
in the node's zonelist (per-node trigger).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

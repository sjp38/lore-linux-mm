Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 649036B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 11:09:41 -0500 (EST)
Date: Tue, 9 Mar 2010 10:09:11 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on
 pressure to relieve instead of congestion
In-Reply-To: <4B966F93.9060207@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1003091005310.28897@router.home>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <1268048904-19397-2-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003090946180.28897@router.home> <4B966F93.9060207@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010, Christian Ehrhardt wrote:

> > What happens if memory becomes available in another zone? Lets say we are
> > waiting on HIGHMEM and memory in ZONE_NORMAL becomes available?
>
> Do you mean the same as Nick asked or another aspect of it?
> citation:
> "I mean the other way around. If that zone's watermarks are not met, then why
> shouldn't it be woken up by other zones reaching their watermarks."

Just saw that exchange. Yes it is similar. Mel only thought about NUMA
but the situation can also occur in !NUMA because multiple zones do not
require NUMA.

If a process goes to sleep on an allocation that has a preferred zone of
HIGHMEM then other processors may free up memory in ZONE_DMA and
ZONE_NORMAL and therefore memory may become available but the process will
continue to sleep.

The wait structure needs to be placed in the pgdat structure to make it
node specific.

But then an overallocated node may stall processes. If that node is full
of unreclaimable memory then the process may never wake up?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

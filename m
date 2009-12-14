Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F02A96B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 08:15:03 -0500 (EST)
Date: Mon, 14 Dec 2009 08:14:44 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
Message-ID: <20091214131444.GA8990@infradead.org>
References: <20091210185626.26f9828a@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091210185626.26f9828a@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Dec 10, 2009 at 06:56:26PM -0500, Rik van Riel wrote:
> Under very heavy multi-process workloads, like AIM7, the VM can
> get into trouble in a variety of ways.  The trouble start when
> there are hundreds, or even thousands of processes active in the
> page reclaim code.
> 
> Not only can the system suffer enormous slowdowns because of
> lock contention (and conditional reschedules) between thousands
> of processes in the page reclaim code, but each process will try
> to free up to SWAP_CLUSTER_MAX pages, even when the system already
> has lots of memory free.  In Larry's case, this resulted in over
> 6000 processes fighting over locks in the page reclaim code, even
> though the system already had 1.5GB of free memory.
>
> It should be possible to avoid both of those issues at once, by
> simply limiting how many processes are active in the page reclaim
> code simultaneously.
> 

This sounds like a very good argument against using direct reclaim at
all.  It reminds a bit of the issue we had in XFS with lots of processes
pushing the AIL and causing massive slowdowns due to lock contention
and cacheline bonucing.  Moving all the AIL pushing into a dedicated
thread solved that nicely.  In the VM we already have that dedicated
per-node kswapd thread, so moving off as much as possible work to
should be equivalent.

Of course any of this kind of tuning really requires a lot of testing
and benchrmarking to verify those assumptions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

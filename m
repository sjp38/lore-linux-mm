Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D45C6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:19:33 -0500 (EST)
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20091214131444.GA8990@infradead.org>
References: <20091210185626.26f9828a@cuia.bos.redhat.com>
	 <20091214131444.GA8990@infradead.org>
Content-Type: text/plain
Date: Mon, 14 Dec 2009 09:22:16 -0500
Message-Id: <1260800536.6666.2.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-12-14 at 08:14 -0500, Christoph Hellwig wrote:
> On Thu, Dec 10, 2009 at 06:56:26PM -0500, Rik van Riel wrote:
> > Under very heavy multi-process workloads, like AIM7, the VM can
> > get into trouble in a variety of ways.  The trouble start when
> > there are hundreds, or even thousands of processes active in the
> > page reclaim code.
> > 
> > Not only can the system suffer enormous slowdowns because of
> > lock contention (and conditional reschedules) between thousands
> > of processes in the page reclaim code, but each process will try
> > to free up to SWAP_CLUSTER_MAX pages, even when the system already
> > has lots of memory free.  In Larry's case, this resulted in over
> > 6000 processes fighting over locks in the page reclaim code, even
> > though the system already had 1.5GB of free memory.
> >
> > It should be possible to avoid both of those issues at once, by
> > simply limiting how many processes are active in the page reclaim
> > code simultaneously.
> > 
> 
> This sounds like a very good argument against using direct reclaim at
> all.  It reminds a bit of the issue we had in XFS with lots of processes
> pushing the AIL and causing massive slowdowns due to lock contention
> and cacheline bonucing.  Moving all the AIL pushing into a dedicated
> thread solved that nicely.  In the VM we already have that dedicated
> per-node kswapd thread, so moving off as much as possible work to
> should be equivalent.

Some of the new systems have 16 CPUs per-node.

> 
> Of course any of this kind of tuning really requires a lot of testing
> and benchrmarking to verify those assumptions.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

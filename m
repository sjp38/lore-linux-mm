Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D2BAD6B002F
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 10:59:22 -0400 (EDT)
Date: Mon, 24 Oct 2011 09:59:16 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
Message-ID: <20111024145916.GA18070@sgi.com>
References: <alpine.DEB.2.00.1110140856420.6411@router.home>
 <20111014141921.GC28592@sgi.com>
 <alpine.DEB.2.00.1110140932530.6411@router.home>
 <alpine.DEB.2.00.1110140958550.6411@router.home>
 <20111014161603.GA30561@sgi.com>
 <20111018134835.GA16222@sgi.com>
 <m2mxcyz4f7.fsf@firstfloor.org>
 <alpine.DEB.2.00.1110181806570.12850@chino.kir.corp.google.com>
 <20111019145458.GA9266@sgi.com>
 <alpine.DEB.2.00.1110191029570.24001@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110191029570.24001@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Wed, Oct 19, 2011 at 10:31:54AM -0500, Christoph Lameter wrote:
> On Wed, 19 Oct 2011, Dimitri Sivanich wrote:
> 
> > For 120 threads writing in parallel (each to it's own mountpoint), the
> > threshold needs to be on the order of 1000.  At a threshold of 750, I
> > start to see a slowdown of 50-60 MB/sec.
> >
> > For 400 threads writing in parallel, the threshold needs to be on the order
> > of 2000 (although we're off by about 40 MB/sec at that point).
> >
> > The necessary deltas in these cases are quite a bit higher than the current
> > 125 maximum (see calculate*threshold in mm/vmstat.c).
> >
> > I like the idea of having certain areas triggering vm_stat sync, as long
> > as we know what those key areas are and how often they might be called.
> 
> You could potentially reduce the maximum necessary by applying my earlier
> patch (but please reduce the counters touched to the current cacheline).
> That should reduce the number of updates in the global cacheline and allow
> you to reduce the very high deltas that you have to deal with now.

I tried updating whole, single vm_stat cachelines as you suggest, but that
made little if any difference in tmpfs writeback performance.  The same higher
threshold values were still necessary to significantly reduce the contention
seen in __vm_enough_memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

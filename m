Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BFCD6B002F
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 10:55:04 -0400 (EDT)
Date: Wed, 19 Oct 2011 09:54:58 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
Message-ID: <20111019145458.GA9266@sgi.com>
References: <20111014122506.GB26737@sgi.com>
 <20111014135055.GA28592@sgi.com>
 <alpine.DEB.2.00.1110140856420.6411@router.home>
 <20111014141921.GC28592@sgi.com>
 <alpine.DEB.2.00.1110140932530.6411@router.home>
 <alpine.DEB.2.00.1110140958550.6411@router.home>
 <20111014161603.GA30561@sgi.com>
 <20111018134835.GA16222@sgi.com>
 <m2mxcyz4f7.fsf@firstfloor.org>
 <alpine.DEB.2.00.1110181806570.12850@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110181806570.12850@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Tue, Oct 18, 2011 at 06:16:21PM -0700, David Rientjes wrote:
> On Tue, 18 Oct 2011, Andi Kleen wrote:
> 
> > > Would it make sense to have the ZVC delta be tuneable (via /proc/sys/vm?), keeping the
> > > same default behavior as what we currently have?
> > 
> > Tunable is bad. We don't really want a "hundreds of lines magic shell script to
> > make large systems perform". Please find a way to auto tune.
> > 
> 
> Agreed, and I think even if we had a tunable that it would result in 
> potentially erradic VM performance because some areas depend on "fairly 
> accurate" ZVCs and it wouldn't be clear that you're trading other unknown 
> VM issues that will affect your workload because you've increased the 
> deltas.  Let's try to avoid having to ask "what is your ZVC delta tunable 
> set at?" when someone reports a bug about reclaim stopping preemptively.

Yes, I'm inclined to agree.

> 
> That said, perhaps we need higher deltas by default and then hints in key 
> areas in the form of sync_stats_if_delta_above(x) calls that would do 
> zone_page_state_add() only when that kind of precision is actually needed.  
> For public interfaces, that would be very easy to audit to see what the 
> level of precision is when parsing the data.

I did some manual tuning to see what deltas would be needed to achieve the
greatest tmpfs writeback performance on a system with 640 cpus and 64 nodes:

For 120 threads writing in parallel (each to it's own mountpoint), the
threshold needs to be on the order of 1000.  At a threshold of 750, I
start to see a slowdown of 50-60 MB/sec.

For 400 threads writing in parallel, the threshold needs to be on the order
of 2000 (although we're off by about 40 MB/sec at that point).

The necessary deltas in these cases are quite a bit higher than the current
125 maximum (see calculate*threshold in mm/vmstat.c).

I like the idea of having certain areas triggering vm_stat sync, as long
as we know what those key areas are and how often they might be called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

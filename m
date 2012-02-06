Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 29F2D6B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:14:29 -0500 (EST)
Received: by pbaa12 with SMTP id a12so6738294pba.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 14:14:28 -0800 (PST)
Date: Mon, 6 Feb 2012 14:14:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] compact_pgdat: workaround lockdep warning in kswapd
In-Reply-To: <4F304A9B.2030004@redhat.com>
Message-ID: <alpine.LSU.2.00.1202061359260.2576@eggly.anvils>
References: <alpine.LSU.2.00.1202061129040.2144@eggly.anvils> <20120206124952.75702d5c.akpm@linux-foundation.org> <4F304A9B.2030004@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

On Mon, 6 Feb 2012, Rik van Riel wrote:
> On 02/06/2012 03:49 PM, Andrew Morton wrote:
> > On Mon, 6 Feb 2012 11:40:08 -0800 (PST)
> > Hugh Dickins<hughd@google.com>  wrote:
> > 
> > > I get this lockdep warning from swapping load on linux-next
> > > (20120201 but I expect the same from more recent days):
> > 
> > The patch looks good as a standalone optimisation/cleanup.  The lack of
> > clarity on the lockdep thing is a concern - I have a feeling we'll be
> > bitten again.
> 
> Very strange, kswapd does not seem to be holding any locks
> when calling balance_pgdat...
> 
> I assume it must be this line in kswapd() that's causing
> lockdep to trigger:
> 
> 	lockdep_set_current_reclaim_state(GFP_KERNEL);

Certainly that's a part of what's bringing lockdep's GFP_FS checking
into play.  And I noticed that that does get modulated by whether
PF_MEMALLOC is set or not: maybe it needs another PF_MEMALLOC check
somewhere, maybe it's correct as is, I just don't pretend to know.

(Earlier on I moved the lockdep_set_current_reclaim_state call after
kswapd sets PF_MEMALLOC; but that's irrelevant and doesn't help,
I was simply misunderstanding what goes on.)

If we had an lru_add_drain_all() somewhere in the direct reclaim path,
then I'm sure lockdep would be right to complain.  It notices that
we once did a GFP_KERNEL allocation while holding pcpu_alloc_mutex,
so it would protest at trying to acquire pcpu_alloc_mutex down in
direct reclaim.

But whether that renders the call in kswapd dangerous or not,
I don't know: I forget the extent to which the limitations of
direct reclaim require kswapd to make progress - imagine a task
holding pcpu_alloc_mutex going down into direct reclaim, getting
nowhere, and needing kswapd to make progress, but kswapd wants to
take pcpu_alloc_mutex to compact_pgdat.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

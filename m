Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F66D6B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 20:36:06 -0400 (EDT)
Date: Mon, 19 Apr 2010 10:35:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100419003556.GC2520@dastard>
References: <20100413202021.GZ13327@think>
 <20100414014041.GD2493@dastard>
 <20100414155233.D153.A69D9226@jp.fujitsu.com>
 <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie>
 <20100415013436.GO2493@dastard>
 <20100415102837.GB10966@csn.ul.ie>
 <20100416041412.GY2493@dastard>
 <20100416151403.GM19264@csn.ul.ie>
 <20100417203239.dda79e88.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100417203239.dda79e88.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2010 at 08:32:39PM -0400, Andrew Morton wrote:
> 
> There are two issues here: stack utilisation and poor IO patterns in
> direct reclaim.  They are different.
> 
> The poor IO patterns thing is a regression.  Some time several years
> ago (around 2.6.16, perhaps), page reclaim started to do a LOT more
> dirty-page writeback than it used to.  AFAIK nobody attempted to work
> out why, nor attempted to try to fix it.

I think that part of the problem is that at roughly the same time
writeback started on a long down hill slide as well, and we've
really only fixed that in the last couple of kernel releases. Also,
it tends to take more that just writing a few large files to invoke
the LRU-based writeback code is it is generally not invoked in
filesystem "performance" testing. Hence my bet is on the fact that
the effects of LRU-based writeback are rarely noticed in common
testing.

IOWs, low memory testing is not something a lot of people do. Add to
that the fact that most fs people, including me, have been treating
the VM as a black box that a bunch of other people have been taking
care of and hence really just been hoping it does the right thing,
and we've got a recipe for an unnoticed descent into a Bad Place.

[snip]

> Any attempt to implement writearound in pageout will need to find a way
> to safely pin that address_space.  One way is to take a temporary ref
> on mapping->host, but IIRC that introduced nasties with inode_lock. 
> Certainly it'll put more load on that worrisomely-singleton lock.

A problem already solved in the background flusher threads....

> Regarding simply not doing any writeout in direct reclaim (Dave's
> initial proposal): the problem is that pageout() will clean a page in
> the target zone.  Normal writeout won't do that, so we could get into a
> situation where vast amounts of writeout is happening, but none of it
> is cleaning pages in the zone which we're trying to allocate from. 
> It's quite possibly livelockable, too.

That's true, but seeing as we can't safely do writeback from
reclaim, we need some method of telling the background threads to
write a certain region of an inode. Perhaps some extension of a
struct writeback_control?

> Doing writearound (if we can get it going) will solve that adequately
> (assuming that the target page gets reliably written), but it won't
> help the stack usage problem.
> 
> 
> To solve the IO-pattern thing I really do think we should first work
> out ytf we started doing much more IO off the LRU.  What caused it?  Is
> it really unavoidable?

/me wonders who has the time and expertise to do that archeology

> To solve the stack-usage thing: dunno, really.  One could envisage code
> which skips pageout() if we're using more than X amount of stack, but

Which, if we have to set it as low as 1.5k of stack used, may as
well just skip pageout()....

> that sucks.  Another possibility might be to hand the target page over
> to another thread (I suppose kswapd will do) and then synchronise with
> that thread - get_page()+wait_on_page_locked() is one way.  The helper
> thread could of course do writearound.

I'm fundamentally opposed to pushing IO to another place in the VM
when it could be just as easily handed to the flusher threads.
Also, consider that there's only one kswapd thread in a given
context (e.g. per CPU), but we can scale the number of flusher
threads as need be....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

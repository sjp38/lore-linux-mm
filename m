Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B70F46B0154
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 08:30:11 -0400 (EDT)
Date: Mon, 15 Mar 2010 12:29:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100315122948.GJ18274@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <20100311154124.e1e23900.akpm@linux-foundation.org> <4B99E19E.6070301@linux.vnet.ibm.com> <20100312020526.d424f2a8.akpm@linux-foundation.org> <20100312104712.GB18274@csn.ul.ie> <4B9A3049.7010602@linux.vnet.ibm.com> <20100312093755.b2393b33.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100312093755.b2393b33.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 12, 2010 at 09:37:55AM -0500, Andrew Morton wrote:
> On Fri, 12 Mar 2010 13:15:05 +0100 Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
> 
> > > It still feels a bit unnatural though that the page allocator waits on
> > > congestion when what it really cares about is watermarks. Even if this
> > > patch works for Christian, I think it still has merit so will kick it a
> > > few more times.
> > 
> > In whatever way I can look at it watermark_wait should be supperior to 
> > congestion_wait. Because as Mel points out waiting for watermarks is 
> > what is semantically correct there.
> 
> If a direct-reclaimer waits for some thresholds to be achieved then what
> task is doing reclaim?
> 
> Ultimately, kswapd. 

Well, not quite. The direct reclaimer will still wake up after a timeout
and try again regardless of whether watermarks have been met or not. The
intention is to back after after direct reclaim has failed. Granted, the
window during which a direct reclaim finishes and an allocation attempt
occurs is unnecessarily large. This may be addressed by the patch that
changes where cond_resched() is called.

> This will introduce a hard dependency upon kswapd
> activity.  This might introduce scalability problems.  And latency
> problems if kswapd if off doodling with a slow device (say), or doing a
> journal commit.  And perhaps deadlocks if kswapd tries to take a lock
> which one of the waiting-for-watermark direct relcaimers holds.
> 

What lock could they be holding? Even if that is the case, the direct
reclaimers do not wait indefinitily.

> Generally, kswapd is an optional, best-effort latency optimisation
> thing and we haven't designed for it to be a critical service. 
> Probably stuff would break were we to do so.
> 

No disagreements there.

> This is one of the reasons why we avoided creating such dependencies in
> reclaim.  Instead, what we do when a reclaimer is encountering lots of
> dirty or in-flight pages is
> 
> 	msleep(100);
> 
> then try again.  We're waiting for the disks, not kswapd.
> 
> Only the hard-wired 100 is a bit silly, so we made the "100" variable,
> inversely dependent upon the number of disks and their speed.  If you
> have more and faster disks then you sleep for less time.
> 
> And that's what congestion_wait() does, in a very simplistic fashion. 
> It's a facility which direct-reclaimers use to ratelimit themselves in
> inverse proportion to the speed with which the system can retire writes.
> 

The problem being hit is when a direct reclaimer goes to sleep waiting
on congestion when in reality there were not lots of dirty or in-flight
pages. It goes to sleep for the wrong reasons and doesn't get woken up
again until the timeout expires.

Bear in mind that even if congestion clears, it just means that dirty
pages are now clean although I admit that the next direct reclaim it
does is going to encounter clean pages and should succeed.

Lets see how the other patch that changes when cond_reched() gets called
gets on. If it also works out, then it's harder to justify this patch.
If it doesn't work out then it'll need to be kicked another few times.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 64B436B0156
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:39:23 -0500 (EST)
Date: Fri, 12 Mar 2010 09:37:55 -0500
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
 pressure
Message-Id: <20100312093755.b2393b33.akpm@linux-foundation.org>
In-Reply-To: <4B9A3049.7010602@linux.vnet.ibm.com>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
	<20100311154124.e1e23900.akpm@linux-foundation.org>
	<4B99E19E.6070301@linux.vnet.ibm.com>
	<20100312020526.d424f2a8.akpm@linux-foundation.org>
	<20100312104712.GB18274@csn.ul.ie>
	<4B9A3049.7010602@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 13:15:05 +0100 Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:

> > It still feels a bit unnatural though that the page allocator waits on
> > congestion when what it really cares about is watermarks. Even if this
> > patch works for Christian, I think it still has merit so will kick it a
> > few more times.
> 
> In whatever way I can look at it watermark_wait should be supperior to 
> congestion_wait. Because as Mel points out waiting for watermarks is 
> what is semantically correct there.

If a direct-reclaimer waits for some thresholds to be achieved then what
task is doing reclaim?

Ultimately, kswapd.  This will introduce a hard dependency upon kswapd
activity.  This might introduce scalability problems.  And latency
problems if kswapd if off doodling with a slow device (say), or doing a
journal commit.  And perhaps deadlocks if kswapd tries to take a lock
which one of the waiting-for-watermark direct relcaimers holds.

Generally, kswapd is an optional, best-effort latency optimisation
thing and we haven't designed for it to be a critical service. 
Probably stuff would break were we to do so.


This is one of the reasons why we avoided creating such dependencies in
reclaim.  Instead, what we do when a reclaimer is encountering lots of
dirty or in-flight pages is

	msleep(100);

then try again.  We're waiting for the disks, not kswapd.

Only the hard-wired 100 is a bit silly, so we made the "100" variable,
inversely dependent upon the number of disks and their speed.  If you
have more and faster disks then you sleep for less time.

And that's what congestion_wait() does, in a very simplistic fashion. 
It's a facility which direct-reclaimers use to ratelimit themselves in
inverse proportion to the speed with which the system can retire writes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

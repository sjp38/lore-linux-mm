Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA16883
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 15:58:22 -0700 (PDT)
Message-ID: <3D7D277E.7E179FA0@digeo.com>
Date: Mon, 09 Sep 2002 15:58:06 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com> <E17oXIx-0006vb-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Rik van Riel <riel@conectiva.com.br>, William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> On Monday 09 September 2002 11:38, Andrew Morton wrote:
> > One thing this patch did do was to speed up the initial untar of
> > the kernel source - 50 seconds down to 25.  That'll be due to not
> > having so much dirt on the inactive list.  The "nonblocking page
> > reclaim" code (needs a better name...)
> 
> Nonblocking kswapd, no?  Perhaps 'kscand' would be a better name, now.

Well, it blocks still.  But it doesn't block on "this particular
request queue" or on "that particular page ending IO".  It
blocks on "any queue putting back a write request".   Which is
basically equivalent to blocking on "a bunch of pages came clean".

This logic is too global at present.  It really needs to be per-zone,
to fix an oom problem which you-know-who managed to trigger.  All
ZONE_NORMAL is dirty, we keep on getting woken up by IO completion in ZONE_HIGHMEM, we end up scanning enough ZONE_NORMAL pages to conclude
that we're oom.  (Plus I reduced the maximum-scan-before-oom by 2.5x)

Then again, Bill had twiddled the dirty memory thresholds
to permit 12G of dirty ZONE_HIGHMEM.

> > ...does that in 18 secs.
> 
> Woohoo!  I didn't think it would make *that* much difference, did you
> dig into why?

That's nuthin.  Some tests are 10-50 times faster.  Tests like
trying to compile something while some other process is doing a
bunch of big file writes.
 
> My reason for wanting nonblocking kswapd has always been to be able to
> untangle the multiple-simultaneous-scanners mess, which we are now in
> a good position to do.  Erm, it never occurred to me it would be as easy
> as checking whether the page *might* block and skipping it if so.
> 

Skipping is dumb.  It shouldn't have been on that list in the
first place.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

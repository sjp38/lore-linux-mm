Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A1DEA6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 11:01:53 -0500 (EST)
Date: Fri, 4 Jan 2013 16:01:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130104160148.GB3885@suse.de>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130102200848.GA4500@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jan 02, 2013 at 08:08:48PM +0000, Eric Wong wrote:
> (changing Cc:)
> 
> Eric Wong <normalperson@yhbt.net> wrote:
> > I'm finding ppoll() unexpectedly stuck when waiting for POLLIN on a
> > local TCP socket.  The isolated code below can reproduces the issue
> > after many minutes (<1 hour).  It might be easier to reproduce on
> > a busy system while disk I/O is happening.
> 
> s/might be/is/
> 
> Strangely, I've bisected this seemingly networking-related issue down to
> the following commit:
> 
>   commit 1fb3f8ca0e9222535a39b884cb67a34628411b9f
>   Author: Mel Gorman <mgorman@suse.de>
>   Date:   Mon Oct 8 16:29:12 2012 -0700
> 
>       mm: compaction: capture a suitable high-order page immediately when it is made available
> 
> That commit doesn't revert cleanly on v3.7.1, and I don't feel
> comfortable touching that code myself.
> 

That patch introduced an accounting bug that was corrected by ef6c5be6
(fix incorrect NR_FREE_PAGES accounting (appears like memory leak)). In
some cases that could look like a hang and potentially confuses a bisection.

That said, I see that you report that 3.7.1 and 3.8-rc2 are affected that
includes that fix and the finger is pointed at compaction so something
is wrong.

> Instead, I disabled THP+compaction under v3.7.1 and I've been unable to
> reproduce the issue without THP+compaction.
> 

Implying that it's stuck in compaction somewhere. It could be the case
that compaction alters timing enough to trigger another bug. You say it
tests differently depending on whether TCP or unix sockets are used
which might indicate multiple problems. However, lets try and see if
compaction is the primary problem or not.

> As I mention in http://mid.gmane.org/20121229113434.GA13336@dcvr.yhbt.net
> I run my below test (`toosleepy') with heavy network and disk activity
> for a long time before hitting this.
> 

Using a 3.7.1 or 3.8-rc2 kernel, can you reproduce the problem and then
answer the following questions please?

1. What are the contents of /proc/vmstat at the time it is stuck?

2. What are the contents of /proc/PID/stack for every toosleepy
   process when they are stuck?

3. Can you do a sysrq+m and post the resulting dmesg?

What I'm looking for is a throttling bug (if pgscan_direct_throttle is
elevated), an isolated page accounting bug (nr_isolated_* is elevated
and process is stuck in congestion_wait in a too_many_isolated() loop)
or a free page accounting bug (big difference between nr_free_pages and
buddy list figures).

I'll try reproducing this early next week if none of that shows an
obvious candidate.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

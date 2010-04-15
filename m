Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A45BE6B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:21:14 -0400 (EDT)
Date: Thu, 15 Apr 2010 16:20:55 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415062055.GQ2493@dastard>
References: <20100414085132.GJ25756@csn.ul.ie>
 <20100415013436.GO2493@dastard>
 <20100415130212.D16E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415130212.D16E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 01:09:01PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > How about this? For now, we stop direct reclaim from doing writeback
> > only on order zero allocations, but allow it for higher order
> > allocations. That will prevent the majority of situations where
> > direct reclaim blows the stack and interferes with background
> > writeout, but won't cause lumpy reclaim to change behaviour.
> > This reduces the scope of impact and hence testing and validation
> > the needs to be done.
> 
> Tend to agree. but I would proposed slightly different algorithm for
> avoind incorrect oom.
> 
> for high order allocation
> 	allow to use lumpy reclaim and pageout() for both kswapd and direct reclaim

SO same as current.

> for low order allocation
> 	- kswapd:          always delegate io to flusher thread
> 	- direct reclaim:  delegate io to flusher thread only if vm pressure is low

IMO, this really doesn't fix either of the problems - the bad IO
patterns nor the stack usage. All it will take is a bit more memory
pressure to trigger stack and IO problems, and the user reporting the
problems is generating an awful lot of memory pressure...

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

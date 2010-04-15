Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B3EAE600375
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:51:49 -0400 (EDT)
Date: Thu, 15 Apr 2010 13:50:29 -0400
From: tytso@mit.edu
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415175029.GF19959@thunk.org>
References: <20100413202021.GZ13327@think>
 <20100414014041.GD2493@dastard>
 <20100414155233.D153.A69D9226@jp.fujitsu.com>
 <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie>
 <20100415013436.GO2493@dastard>
 <20100415102837.GB10966@csn.ul.ie>
 <20100415134217.GB3794@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415134217.GB3794@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 09:42:17AM -0400, Chris Mason wrote:
> I'd like to add one more:
> 
> 5. Don't dive into filesystem locks during reclaim.
> 
> This is different from splicing code paths together, but
> the filesystem writepage code has become the center of our attempts at
> doing big fat contiguous writes on disk.  We push off work as late as we
> can until just before the pages go down to disk.
> 
> I'll pick on ext4 and btrfs for a minute, just to broaden the scope
> outside of XFS.  Writepage comes along and the filesystem needs to
> actually find blocks on disk for all the dirty pages it has promised to
> write.
> 
> So, we start a transaction, we take various allocator locks, modify
> different metadata, log changed blocks, take a break (logging is hard
> work you know, need_resched() triggered a by now), stuff it
> all into the file's metadata, log that, and finally return.
> 
> Each of the steps above can block for a long time.  Ext4 solves
> this by not doing them.  ext4_writepage only writes pages that
> are already fully allocated on disk.
> 
> Btrfs is much more efficient at not doing them, it just returns right
> away for PF_MEMALLOC.

This is a real problem, BTW.  One of the problems we've been fighting
inside Google is because ext4_writepage() refuses to write pages that
are subject to delayed allocation, it can cause the OOM killer to get
invoked.  

I had thought this was because of some evil games we're playing for
container support that makes zones small, but just last night at the
LF Collaboration Summit reception, I ran into a technologist from a
major financial industry customer reported to me that when they tried
using ext4, they ran into the exact same problem because they were
running Oracle which was pinning down 3 gigs of memory, and then when
they tried writing a very big file using ext4, they had the same
problem of writepage() not being able to reclaim enough pages, so the
kernel fell back to invoking the OOM killer, and things got ugly in a
hurry...

One of the things I was proposing internally to try as a long-term
we-gotta-fix writeback is that we need some kind of signal so that we
can do the lumpy reclaim (a) in a separate process, to avoid a lock
inversion problem and the gee-its-going-to-take-a-long-time problem
which Chris Mentioned, and (b) to try to cluster I/O so that we're not
dribbling out writes to the disk in small, seeky, 4k writes, which is
really a disaster from a performance standpoint.  Maybe the VM guys
don't care about this, but this sort of things tends to get us
filesystem guys all up in a lather not just because of the really
sucky performance, but also because it tends to mean that the system
can thrash itself to death in low memory situations.

    	       	      	     	      	 - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

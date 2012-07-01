Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id E52636B00D3
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 19:55:03 -0400 (EDT)
Date: Mon, 2 Jul 2012 09:54:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120701235458.GM19223@dastard>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120629112505.GF14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com

On Fri, Jun 29, 2012 at 12:25:06PM +0100, Mel Gorman wrote:
> Configuration:	global-dhp__io-metadata-xfs
> Benchmarks:	dbench3, fsmark-single, fsmark-threaded
> 
> Summary
> =======
> Most of the figures look good and in general there has been consistent good
> performance from XFS. However, fsmark-single is showing a severe performance
> dip in a few cases somewhere between 3.1 and 3.4. fs-mark running a single
> thread took a particularly bad dive in 3.4 for two machines that is worth
> examining closer.

That will be caused by the fact we changed all the metadata updates
to be logged, which means a transaction every time .dirty_inode is
called.

This should mostly go away when XFS is converted to use .update_time
rather than .dirty_inode to only issue transactions when the VFS
updates the atime rather than every .dirty_inode call...

> Unfortunately it is harder to easy conclusions as the
> gains/losses are not consistent between machines which may be related to
> the available number of CPU threads.

It increases the CPU overhead (dirty_inode can be called up to 4
times per write(2) call, IIRC), so with limited numbers of
threads/limited CPU power it will result in lower performance. Where
you have lots of CPU power, there will be little difference in
performance...

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

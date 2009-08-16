Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 04A9E6B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 18:12:24 -0400 (EDT)
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n7GMBxos018875
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 15:12:01 -0700 (PDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-disposition: inline
Content-type: text/plain; CHARSET=US-ASCII
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KOH00500PGRL200@fe-sfbay-09.sun.com> for linux-mm@kvack.org; Sun,
 16 Aug 2009 15:11:59 -0700 (PDT)
Date: Sun, 16 Aug 2009 16:11:59 -0600
From: Andreas Dilger <adilger@sun.com>
Subject: Re: [rfc][patch] fs: turn iprune_mutex into rwsem
In-reply-to: <20090815195742.GA14842@infradead.org>
Message-id: <20090816221159.GR5931@webber.adilger.int>
References: <20090814152504.GA19195@wotan.suse.de>
 <20090815195742.GA14842@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Aug 15, 2009  15:57 -0400, Christoph Hellwig wrote:
> On Fri, Aug 14, 2009 at 05:25:05PM +0200, Nick Piggin wrote:
> > Now I think the main problem is having the filesystem block (and do IO
> > in inode reclaim. The problem is that this doesn't get accounted well
> > and penalizes a random allocator with a big latency spike caused by
> > work generated from elsewhere.
> > 
> > I think the best idea would be to avoid this. By design if possible,
> > or by deferring the hard work to an asynchronous context. If the latter,
> > then the fs would probably want to throttle creation of new work with
> > queue size of the deferred work, but let's not get into those details.
> 
> I don't really see a good way to avoid this.  For any filesystem that
> does some sort of preallocations we need to drop them in ->clear_inode.

One of the problems I've seen in the past is that filesystem memory reclaim
(in particular dentry/inode cleanup) cannot happen within filesystems due
to potential deadlocks.  This is particularly problematic when there is a
lot of memory pressure from within the kernel and very little from userspace
(e.g. updatedb or find).

However, many/most inodes/dentries in the filesystem could be discarded
quite easily and would not deadlock the system.  I wonder if it makes
sense to keep a mask in the inode that the filesystem could set that
determines whether it is safe to clean up the inode even though __GFP_FS
is not set?  That would potentially allow e.g. shrink_icache_memory()
to free a large number of "non-tricky" inodes if needed (e.g. ones without
locks/preallocation/expensive cleanup).

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 049816B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 06:05:23 -0400 (EDT)
Date: Sun, 16 Aug 2009 12:05:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] fs: turn iprune_mutex into rwsem
Message-ID: <20090816100521.GA8644@wotan.suse.de>
References: <20090814152504.GA19195@wotan.suse.de> <20090815195742.GA14842@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090815195742.GA14842@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 15, 2009 at 03:57:42PM -0400, Christoph Hellwig wrote:
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

OK, I agree sometimes it is not going to be possible. Although if the
preallocations are on-disk, do you still have to drop them? If not on
disk, then no IO is required.

But anyway, I propose this patch exactly because it is not always
possible to avoid slow/blocking ops (even in the vfs there are some).

If it ever turns up to be a problem after that, I guess it might be
possible to have another callback to schedule async slow work before
dropping the inode. Or something like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

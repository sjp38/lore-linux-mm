Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6126E8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 14:12:27 -0500 (EST)
Date: Mon, 15 Nov 2010 14:12:04 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Oops while rebalancing, now unmountable.
Message-ID: <20101115191204.GB11374@infradead.org>
References: <1289236257.3611.3.camel@mars>
 <1289310046-sup-839@think>
 <1289326892.4231.2.camel@mars>
 <1289764507.4303.9.camel@mars>
 <20101114204206.GV6809@random.random>
 <20101114220018.GA4512@infradead.org>
 <20101114221222.GX6809@random.random>
 <20101115182314.GA2493@infradead.org>
 <20101115184657.GJ6809@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101115184657.GJ6809@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 07:46:57PM +0100, Andrea Arcangeli wrote:
> I've been reading the writeout() in mm/migrate.c and I wonder if maybe
> that should have been WB_SYNC_ALL or if we miss a
> wait_on_page_writeback in after ->writepage() returns? Can you have a
> look there? We check the PG_writeback bit when the page is not dirty
> (well before fallback_migrate_page is called), but after calling
> writeout() we don't return to wait on PG_writeback. We make sure to
> hold the page lock after ->writepage returns but that doesn't mean
> PG_writeback isn't still set.

I didn't even notice that, but the WB_SYNC_NONE does indeed seem
buggy to me.  If we set the sync_mode to WB_SYNC_NONE filesystem
can and frequently do trylock operations and might just skip to
write it out completely.

So we defintively do need to change writeout to do a WB_SYNC_ALL
writeback.  In addition to that we'll also need the
wait_on_page_writeback call to make sure we actually wait for I/O
to finish.

Also what protects us from updating the page while we write it out?
PG_writeback on many filesystems doesn't protect writes from modifying
the in-flight buffer, and just locking the page after ->writepage
is racy without a check that nothing changed.

> Compaction practically only happens in the context of the task
> allocating memory (in my tree it is also used by kswapd). Not
> immediate to ask a separate daemon to invoke it. Not sure why this
> should screw delalloc. Compaction isn't freeing any memory at all,
> it's not reclaim. It just defragments and moves stuff around and it
> may have to write dirty pages to do so.

kswapd is fine.  Other task allocation memory are direct reclaimers.
Direct reclaim through the filesystem delalloc conversion and the I/O
stack guarantees you stack overflows, that's why filesystems refuse
to do anything in ->writepage for this case.  btrfs and XFS have
explicit checks for PF_MEMALLOC (with a carve out for kswapd in XFS),
and ext4 only writes already allocated blocks in ->writepage but never
does delalloc conversions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 586E68D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 14:29:20 -0500 (EST)
Date: Mon, 15 Nov 2010 20:29:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Oops while rebalancing, now unmountable.
Message-ID: <20101115192914.GL6809@random.random>
References: <1289236257.3611.3.camel@mars>
 <1289310046-sup-839@think>
 <1289326892.4231.2.camel@mars>
 <1289764507.4303.9.camel@mars>
 <20101114204206.GV6809@random.random>
 <20101114220018.GA4512@infradead.org>
 <20101114221222.GX6809@random.random>
 <20101115182314.GA2493@infradead.org>
 <20101115184657.GJ6809@random.random>
 <20101115191204.GB11374@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101115191204.GB11374@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 02:12:04PM -0500, Christoph Hellwig wrote:
> I didn't even notice that, but the WB_SYNC_NONE does indeed seem
> buggy to me.  If we set the sync_mode to WB_SYNC_NONE filesystem
> can and frequently do trylock operations and might just skip to
> write it out completely.

Scary stuff, so WB_SYNC_NONE wouldn't submit the dirty part of the
page down for I/O, so that it's all clean after wait_on_page_writeback
returns? (well of course unless the dirty bit was set again)

> So we defintively do need to change writeout to do a WB_SYNC_ALL
> writeback.  In addition to that we'll also need the
> wait_on_page_writeback call to make sure we actually wait for I/O
> to finish.

Ok that is ok... I misread it sorry. But the writeback must be started
by WB_SYNC_NONE (or _ALL) for wait_on_page_writeback to be effective.

migration will abort if ->writepage returns error, that's safe
though. It will retry calling on wait_on_page_writeback only if
->writepage returns 0.

> Also what protects us from updating the page while we write it out?
> PG_writeback on many filesystems doesn't protect writes from modifying
> the in-flight buffer, and just locking the page after ->writepage
> is racy without a check that nothing changed.

migrate established migration ptes already so nobody can write to the
page through pagetables. The only thing left is O_DIRECT which is also
taken care by the page count check in migrate_page_move_mapping,
before migrate_page called by fallback_migrate_page can succeed. So
nothing can be modifying the page if we go ahead with migrate_page
(and no pte dirty bit can happen either). The page is also locked down
for the whole migration so all writes syscalls should be stopped.

> kswapd is fine.  Other task allocation memory are direct reclaimers.
> Direct reclaim through the filesystem delalloc conversion and the I/O
> stack guarantees you stack overflows, that's why filesystems refuse
> to do anything in ->writepage for this case.  btrfs and XFS have
> explicit checks for PF_MEMALLOC (with a carve out for kswapd in XFS),
> and ext4 only writes already allocated blocks in ->writepage but never
> does delalloc conversions.

I didn't realize the stack overflow issue was specific to delalloc. I
think it's ok here to skip ->writepage for delalloc, it's not
mandatory, memory compaction isn't supposed to do much I/O anyway,
it's supposed to copy ram instead. Sure it'd be more reliable to
submit I/O but it's going to work pretty well, plus compaction will be
retried again later by khugepaged once every 10 sec. kswapd actually
with THP will not do anything because THP allocations are run with
__GFP_NO_KSWAPD to avoid kswapd to waste cpu by trying in the
background hard to create hugepages if 90% of ram goes in anonymous
memory (and there are background anon allocations that would wakeup
kswapd) but only 80% can be allocated as 2M contiguous beacuse 20% was
at some point allocated in slab caches.

In short with THP it's khugepaged that is supposed to run the
->writepage in migrate.c and it will run it once every 10 sec even
when it fails (and not in a 100% cpu wasting loop like kswapd), so if
you did something magic for kswapd in XFS you should do for khugepaged
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EDB86B01F5
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 09:43:18 -0400 (EDT)
Date: Thu, 15 Apr 2010 09:42:17 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415134217.GB3794@think>
References: <20100413202021.GZ13327@think>
 <20100414014041.GD2493@dastard>
 <20100414155233.D153.A69D9226@jp.fujitsu.com>
 <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie>
 <20100415013436.GO2493@dastard>
 <20100415102837.GB10966@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415102837.GB10966@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 11:28:37AM +0100, Mel Gorman wrote:
> On Thu, Apr 15, 2010 at 11:34:36AM +1000, Dave Chinner wrote:
> > On Wed, Apr 14, 2010 at 09:51:33AM +0100, Mel Gorman wrote:
> > > On Wed, Apr 14, 2010 at 05:28:30PM +1000, Dave Chinner wrote:
> > > > On Wed, Apr 14, 2010 at 03:52:44PM +0900, KOSAKI Motohiro wrote:
> > > > > > On Tue, Apr 13, 2010 at 04:20:21PM -0400, Chris Mason wrote:
> > > > > > > On Tue, Apr 13, 2010 at 08:34:29PM +0100, Mel Gorman wrote:
> > > > > > > > > Basically, there is not enough stack space available to allow direct
> > > > > > > > > reclaim to enter ->writepage _anywhere_ according to the stack usage
> > > > > > > > > profiles we are seeing here....
> > > > > > > > > 
> > > > > > > > 
> > > > > > > > I'm not denying the evidence but how has it been gotten away with for years
> > > > > > > > then? Prevention of writeback isn't the answer without figuring out how
> > > > > > > > direct reclaimers can queue pages for IO and in the case of lumpy reclaim
> > > > > > > > doing sync IO, then waiting on those pages.
> > > > > > > 
> > > > > > > So, I've been reading along, nodding my head to Dave's side of things
> > > > > > > because seeks are evil and direct reclaim makes seeks.  I'd really loev
> > > > > > > for direct reclaim to somehow trigger writepages on large chunks instead
> > > > > > > of doing page by page spatters of IO to the drive.
> > > > > 
> > > > > I agree that "seeks are evil and direct reclaim makes seeks". Actually,
> > > > > making 4k io is not must for pageout. So, probably we can improve it.
> > > > > 
> > > > > 
> > > > > > Perhaps drop the lock on the page if it is held and call one of the
> > > > > > helpers that filesystems use to do this, like:
> > > > > > 
> > > > > > 	filemap_write_and_wait(page->mapping);
> > > > > 
> > > > > Sorry, I'm lost what you talk about. Why do we need per-file
> > > > > waiting? If file is 1GB file, do we need to wait 1GB writeout?
> > > > 
> > > > So use filemap_fdatawrite(page->mapping), or if it's better only
> > > > to start IO on a segment of the file, use
> > > > filemap_fdatawrite_range(page->mapping, start, end)....
> > > 
> > > That does not help the stack usage issue, the caller ends up in
> > > ->writepages. From an IO perspective, it'll be better from a seek point of
> > > view but from a VM perspective, it may or may not be cleaning the right pages.
> > > So I think this is a red herring.
> > 
> > If you ask it to clean a bunch of pages around the one you want to
> > reclaim on the LRU, there is a good chance it will also be cleaning
> > pages that are near the end of the LRU or physically close by as
> > well. It's not a guarantee, but for the additional IO cost of about
> > 10% wall time on that IO to clean the page you need, you also get
> > 1-2 orders of magnitude other pages cleaned. That sounds like a
> > win any way you look at it...
> > 
> 
> At worst, it'll distort the LRU ordering slightly. Lets say the the
> file-adjacent-page you clean was near the end of the LRU. Before such a
> patch, it may have gotten cleaned and done another lap of the LRU.
> After, it would be reclaimed sooner. I don't know if we depend on such
> behaviour (very doubtful) but it's a subtle enough change. I can't
> predict what it'll do for IO congestion. Simplistically, there is more
> IO so it's bad but if the write pattern is less seeky and we needed to
> write the pages anyway, it might be improved.
> 
> > I agree that it doesn't solve the stack problem (Chris' suggestion
> > that we enable the bdi flusher interface would fix this);
> 
> I'm afraid I'm not familiar with this interface. Can you point me at
> some previous discussion so that I am sure I am looking at the right
> thing?

vi fs/direct-reclaim-helper.c, it has a few placeholders for where the
real code needs to go....just look for the ~ marks.

I mostly meant that the bdi helper threads were the best place to add
knowledge about which pages we want to write for reclaim.  We might need
to add a thread dedicated to just doing the VM's dirty work, but that's
where I would start discussing fancy new interfaces.

> 
> > what I'm
> > pointing out is that the arguments that it is too hard or there are
> > no interfaces available to issue larger IO from reclaim are not at
> > all valid.
> > 
> 
> Sure, I'm not resisting fixing this, just your first patch :) There are four
> goals here
> 
> 1. Reduce stack usage
> 2. Avoid the splicing of subsystem stack usage with direct reclaim
> 3. Preserve lumpy reclaims cleaning of contiguous pages
> 4. Try and not drastically alter LRU aging
> 
> 1 and 2 are important for you, 3 is important for me and 4 will have to
> be dealt with on a case-by-case basis.
> 
> Your patch fixes 2, avoids 1, breaks 3 and haven't thought about 4 but I
> guess dirty pages can cycle around more so it'd need to be cared for.

I'd like to add one more:

5. Don't dive into filesystem locks during reclaim.

This is different from splicing code paths together, but
the filesystem writepage code has become the center of our attempts at
doing big fat contiguous writes on disk.  We push off work as late as we
can until just before the pages go down to disk.

I'll pick on ext4 and btrfs for a minute, just to broaden the scope
outside of XFS.  Writepage comes along and the filesystem needs to
actually find blocks on disk for all the dirty pages it has promised to
write.

So, we start a transaction, we take various allocator locks, modify
different metadata, log changed blocks, take a break (logging is hard
work you know, need_resched() triggered a by now), stuff it
all into the file's metadata, log that, and finally return.

Each of the steps above can block for a long time.  Ext4 solves
this by not doing them.  ext4_writepage only writes pages that
are already fully allocated on disk.

Btrfs is much more efficient at not doing them, it just returns right
away for PF_MEMALLOC.

This is a long way of saying the filesystem writepage code is the
opposite of what direct reclaim wants.  Direct reclaim wants to
find free ram now, and if it does end up in the mess describe above,
it'll just get stuck for a long time on work entirely unrelated to
finding free pages.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

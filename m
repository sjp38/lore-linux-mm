Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8C06B0087
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:55:41 -0500 (EST)
Date: Fri, 19 Nov 2010 14:54:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
Message-Id: <20101119145442.ddf0c0e8.akpm@linux-foundation.org>
In-Reply-To: <20101119072316.GA14388@google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com>
	<1289996638-21439-4-git-send-email-walken@google.com>
	<20101117125756.GA5576@amd>
	<1290007734.2109.941.camel@laptop>
	<AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
	<20101117231143.GQ22876@dastard>
	<20101118133702.GA18834@infradead.org>
	<alpine.LSU.2.00.1011180934400.3210@tigran.mtv.corp.google.com>
	<20101119072316.GA14388@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 23:23:16 -0800
Michel Lespinasse <walken@google.com> wrote:

> On Thu, Nov 18, 2010 at 09:41:22AM -0800, Hugh Dickins wrote:
> > On Thu, 18 Nov 2010, Christoph Hellwig wrote:
> > > On Thu, Nov 18, 2010 at 10:11:43AM +1100, Dave Chinner wrote:
> > > > Hence I think that avoiding ->page_mkwrite callouts is likely to
> > > > break some filesystems in subtle, undetected ways.  IMO, regardless
> > > > of what is done, it would be really good to start by writing a new
> > > > regression test to exercise and encode the expected the mlock
> > > > behaviour so we can detect regressions later on....
> > > 
> > > I think it would help if we could drink a bit of the test driven design
> > > coolaid here. Michel, can you write some testcases where pages on a
> > > shared mapping are mlocked, then dirtied and then munlocked, and then
> > > written out using msync/fsync.  Anything that fails this test on
> > > btrfs/ext4/gfs/xfs/etc obviously doesn't work.
> 
> I think it's still under debate what's an acceptable result for this test
> (i.e. what's supposed to happen during mlock of a shared mapping of
> a sparsely allocated file - is a fallocate equivalent supposed to happen ?)
> But I agree discussing based on test results will make things more concrete.
> 
> > Whilst it's hard to argue against a request for testing, Dave's worries
> > just sprang from a misunderstanding of all the talk about "avoiding ->
> > page_mkwrite".  There's nothing strange or risky about Michel's patch,
> > it does not avoid ->page_mkwrite when there is a write: it just stops
> > pretending that there was a write when locking down the shared area.
> 
> So, I decided to test this using memtoy.

Wait.  You *tested* the kernel?

I dunno, kids these days...

> /data is a separate partition
> where I had just 10GB free space, and /data/hole20G was created using
> dd if=/dev/zero of=/data/hole20G bs=1M seek=20480 count=0.
> 
> memtoy>file /data/hole20G shared
> memtoy>map hole20G
> 
> At this point the file is mapped using a writable, shared VMA.
> 
> memtoy>touch hole20G
> memtoy:  touched 5242880 pages in 30.595 secs
> 
> At this point memtoy's address space is populated with zeroed
> pages. The pages are distinct (meminfo does show 20G of allocated pages),
> are classified as file pages, not anon, and are associated with the
> struct address_space for /data/hole20G. That file still does not have
> blocks allocated, as can be seen with du /data/hole20G.
> 
> memtoy>lock hole20G
> 
> memtoy tries to mlock the hole20G VMA.
> This is where things get interesting.
> 
> Using ext2, without my patch (ext3 should be similar):
>   - first, mlock does fast progress going though file pages, marking them
>     as dirty. Eventually, it hits the dirty limit and gets throttled.
>   - then, mlock does slow progress as it needs to wait for writeback.
>     writeback occurs and allocates blocks for the /data/hole20G.
>     Eventually, the /data partition gets full.
>   - then, mlock does no progress as it's at the dirty limit and nothing
>     gets written back.
>   - mlock never terminates.
> 
> Using ext2, with my patch (ext3 should be similar):
>   - mlock goes through all pages in ~5 seconds, marking them as mlocked
>     (but still not dirty)
>   - mlock completes. /data/hole20G still does not have blocks allocated.
>   - if memtoy is then instructed to dirty all the pages
>     (using 'touch hole20G write'):
>     - first, memtoy does fast progress faulting through file pages, marking
>       them as dirty. Eventually, it hits the dirty limit and gets throttled.
>     - then, memtoy does slow progress as it needs to wait for writeback.
>       writeback occurs and allocates blocks for the /data/hole20G.
>       Eventually, the /data partition gets full.
>     - then, memtoy does no progress as it's at the dirty limit and nothing
>       gets written back. It gets stuck into a write fault that never
>       completes.
>   - i.e. this is essentially the same lockup as without my patch, except that
>     it occurs when the application tries to dirty the shared file rather than
>     during mlock itself.

Seems to me that this bug is the first thing we should be looking at.

> Using ext4, without my patch:
>   - first, mlock does fast progress going though file pages, marking them
>     as dirty. Eventually, it hits the dirty limit and gets throttled.
>   - then, mlock does slow progress as it needs to wait for writeback.
>     writeback occurs and allocates blocks for the /data/hole20G.
>     Eventually, the /data partition gets full.
>   - then, mlock returns an error.
> 
> Using ext4, with my patch:
>   - mlock goes through all pages in ~5 seconds, marking them as mlocked
>     (but still not dirty)
>   - mlock completes. /data/hole20G still does not have blocks allocated.
>   - if memtoy is then instructed to dirty all the pages
>     (using 'touch hole20G write'):
>     - first, memtoy does fast progress faulting through file pages, marking
>       them as dirty. Eventually, it hits the dirty limit and gets throttled.
>     - then, memtoy does slow progress as it needs to wait for writeback.
>       writeback occurs and allocates blocks for the /data/hole20G.
>       Eventually, the /data partition gets full.
>     - at that point, memtoy dies of SIGBUS.
>   - i.e. for filesystems that define the page_mkwrite callback, the mlock
>     behavior when running out of space writing to sparse files is clearly
>     nicer without my patch than with it.
> 
> 
> Not 100% sure what to make of these results.
> 
> Approaching the problem the other way - would there be any objection to
> adding code to do an fallocate() equivalent at the start of mlock ?
> This would be a no-op when the file is fully allocated on disk, and would
> allow mlock to return an error if the file can't get fully allocated
> (no idea what errno should be for such case, though).

Dirtying all that memory at mlock() time is pretty obnoxious.

I'm inclined to agree that your patch implements the desirable
behaviour: don't dirty the page, don't do block allocation.  Take a
fault at first-dirtying and do it then.  This does degrade mlock a bit:
the user will find that the first touch of an mlocked page can cause
synchronous physical I/O, which isn't mlocky behaviour *at all*.  But
we have to be able to do this anyway - whenever the kupdate function
writes back the dirty pages it has to mark them read-only again so the
kernel knows when they get redirtied.

I do agree that this will result in worse file layout for some
reasonable userspace code patterns.  But it was always that way, except
for the eleven-release window where we kinda accidentally fixed that up
in-kernel.  Hopefully most apps which care are already ensuring that
the file is well laid-out.


So all that leaves me thinking that we merge your patches as-is.  Then
work out why users can fairly trivially use mlock to hang the kernel on
ext2 and ext3 (and others?) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

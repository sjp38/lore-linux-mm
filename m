Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 094066B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:56:43 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so38255410wjy.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 00:56:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si1135069wrc.240.2017.01.26.00.56.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 00:56:41 -0800 (PST)
Date: Thu, 26 Jan 2017 09:56:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [ATTEND] many topics
Message-ID: <20170126085639.GA6590@dhcp22.suse.cz>
References: <20170119115243.GB22816@bombadil.infradead.org>
 <20170119121135.GR30786@dhcp22.suse.cz>
 <878tq5ff0i.fsf@notabene.neil.brown.name>
 <20170121131644.zupuk44p5jyzu5c5@thunk.org>
 <87ziijem9e.fsf@notabene.neil.brown.name>
 <20170123060544.GA12833@bombadil.infradead.org>
 <20170123170924.ubx2honzxe7g34on@thunk.org>
 <87mvehd0ze.fsf@notabene.neil.brown.name>
 <58357cf1-65fc-b637-de8e-6cf9c9d91882@suse.cz>
 <8760l2vibg.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8760l2vibg.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu 26-01-17 10:19:31, NeilBrown wrote:
> On Wed, Jan 25 2017, Vlastimil Babka wrote:
> 
> > On 01/23/2017 08:34 PM, NeilBrown wrote:
> >> On Tue, Jan 24 2017, Theodore Ts'o wrote:
> >>
> >>> On Sun, Jan 22, 2017 at 10:05:44PM -0800, Matthew Wilcox wrote:
> >>>>
> >>>> I don't have a clear picture in my mind of when Java promotes objects
> >>>> from nursery to tenure
> >>>
> >>> It's typically on the order of minutes.   :-)
> >>>
> >>>> ... which is not too different from my lack of
> >>>> understanding of what the MM layer considers "temporary" :-)  Is it
> >>>> acceptable usage to allocate a SCSI command (guaranteed to be freed
> >>>> within 30 seconds) from the temporary area?  Or should it only be used
> >>>> for allocations where the thread of control is not going to sleep between
> >>>> allocation and freeing?
> >>>
> >>> What the mm folks have said is that it's to prevent fragmentation.  If
> >>> that's the optimization, whether or not you the process is allocating
> >>> the memory sleeps for a few hundred milliseconds, or even seconds, is
> >>> really in the noise compared with the average lifetime of an inode in
> >>> the inode cache, or a page in the page cache....
> >>>
> >>> Why do you think it matters whether or not we sleep?  I've not heard
> >>> any explanation for the assumption for why this might be important.
> >>
> >> Because "TEMPORARY" implies a limit to the amount of time, and sleeping
> >> is the thing that causes a process to take a large amount of time.  It
> >> seems like an obvious connection to me.
> >
> > There's no simple connection to time, it depends on the larger picture - what's 
> > the state of the allocator and what other allocations/free's are happening 
> > around this one. Perhaps let me try to explain what the flag does and what 
> > benefits are expected.
> 
> If there is no simple connection to time, then I would discourage use of
> the word "TEMPORARY" as that has a strong connection with the concept of time.
> 
> >
> > GFP_TEMPORARY, compared to GFP_KERNEL, adds __GFP_RECLAIMABLE, which tries to 
> > place the allocation within MIGRATE_RECLAIMABLE pageblocks - GFP_KERNEL implies 
> > MIGRATE_UNMOVABLE pageblocks, and userspace allocations are typically 
> > MIGRATE_MOVABLE. The main goal of this "mobility grouping" is to prevent the 
> > unmovable pages spreading all over the memory, making it impossible to get 
> > larger blocks by defragmentation (compaction). Ideally we would have all these 
> > problematic pages fit neatly into the smallest possible number of pageblocks 
> > that can accomodate them. But we can't know in advance how many, and we don't 
> > know their lifetimes, so there are various heuristics for relabeling pageblocks 
> > between the 3 types as we exceed the existing ones.
> >
> > Now GFP_TEMPORARY means we tell the allocator about the relatively shorter 
> > lifetime, so it places the allocation within the RECLAIMABLE pageblocks, which 
> > are also used for slab caches that have shrinkers. The expected benefit of this 
> > is that we potentially prevent growing the number of UNMOVABLE pageblocks 
> > (either directly by this allocation, or a subsequent GFP_KERNEL one, that would 
> > otherwise fit within the existing pageblocks). While the RECLAIMABLE pages also 
> > cannot be defragmented (at least currently, there are some proposals for the 
> > slab caches...), we can at least shrink them, so the negative impact on 
> > compaction is considered less severe in the longer term.
> 
> Hmmm...  this seems like a fuzzy heuristic.
> I can use GFP_TEMPORARY as long  I'll free the memory eventually, or
> there is some way for you to ask me to free the memory, though I don't
> have to succeed - every.

I guess this was the original motivation. If you look at current users
then the pattern seems to be
	object = alloc(GFP_TEMPORARY);
	do_something_that_terminates_shortly();
	free(object);

Another pattern is
	cache = kmemcache_create(SLAB_RECLAIM_ACCOUNT)
	[...]
	object = kmem_cache_alloc(GFP_KERNEL)

so the later one is an implicit GFP_TEMPORARY.

I completely agree that GFP_TEMPORARY is confusing and it needs a much
better documentation.

> If this heuristic actually works, and reduces fragmentation, then I
> suspect it is more luck than good management.  You have maybe added
> GFP_TEMPORARY in a few places which fit with your understanding of what
> you want and which don't ruin the outcomes in your tests.  But without a
> strong definition of when it can and cannot be used, it seems quite
> likely that someone else will start using it in a way that fits within
> your vague statement of requirements, but actually results in much more
> fragmentation.

After more thinking about this I completely agree. And it wouldn't
be for the first time when this would happen. I actually think that
we should simply remove GFP_TEMPORARY. I seriously doubt those few
users would change anything wrt. to the memory fragmentation. The
SLAB_RECLAIM_ACCOUNT resp.  __GFP_RECLAIMABLE makes perfect sense but
the explicit usage of GFP_TEMPORARY without any contract just calls for
problems.
 
> i.e. I think this is a fragile heuristic and not a long term solution
> for anything.

Agreed!

> I think it would be better if we could discard the idea of "reclaimable"
> and just stick with "movable" and "unmovable".  Lots of things are not
> movable at present, but could be made movable with relatively little
> effort.  Once the interfaces are in place to allow arbitrary kernel code
> to find out when things should be moved, I suspect that a lot of
> allocations could become movable.

I believe we need both. There will be many objects which are hard to be
movable yet they are reclaimable which can help to reduce the
fragmentation longterm.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

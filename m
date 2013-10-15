Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id A1C636B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 19:41:58 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so155011pbb.14
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:41:58 -0700 (PDT)
Date: Wed, 16 Oct 2013 10:41:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131015234147.GA4446@dastard>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <20131011003930.GC4446@dastard>
 <20131014214250.GG856@cmpxchg.org>
 <20131015014123.GQ4446@dastard>
 <20131015174128.GH856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131015174128.GH856@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 15, 2013 at 01:41:28PM -0400, Johannes Weiner wrote:
> On Tue, Oct 15, 2013 at 12:41:23PM +1100, Dave Chinner wrote:
> > On Mon, Oct 14, 2013 at 05:42:50PM -0400, Johannes Weiner wrote:
> > > Hi Dave,
> > > 
> > > On Fri, Oct 11, 2013 at 11:39:30AM +1100, Dave Chinner wrote:
> > > > On Thu, Oct 10, 2013 at 05:46:54PM -0400, Johannes Weiner wrote:
> > > > Also, I really don't like the idea of a new inode cache shrinker
> > > > that is completely uncoordinated with the existing inode cache
> > > > shrinkers. It uses a global lock and list and is not node aware so
> > > > all it will do under many workloads is re-introduce a scalability
> > > > choke point we just got rid of in 3.12.
> > > 
> > > Shadow entries are mostly self-regulating and, unlike the inode case,
> > > the shrinker is not the primary means of resource control here.  I
> > > don't think this has the same scalability requirements as inode
> > > shrinking.
> > 
> > Anything that introduces a global lock that needs to be taken in the
> > inode evict() path is a scalability limitation. I've been working to
> > remove all global locks and lists from the evict() path precisely
> > because they severely limit VFS scalability. Hence new code that
> > that introduces a global lock and list into hot VFS paths is simply
> > not acceptible any more.
> 
> Fair enough as well.  But do keep in mind that the lock and list is
> only involved when the address space actually had pages evicted from
> it in the past.  As you said, most inodes don't even have pages...

.... because page reclaim typically removes them long before the
inode is evicted from the inode cache.

> > > > I think that you could simply piggy-back on inode_lru_isolate() to
> > > > remove shadow mappings in exactly the same manner it removes inode
> > > > buffers and page cache pages on inodes that are about to be
> > > > reclaimed.  Keeping the size of the inode cache down will have the
> > > > side effect of keeping the shadow mappings under control, and so I
> > > > don't see a need for a separate shrinker at all here.
> > > 
> > > Pinned inodes are not on the LRU, so you could send a machine OOM by
> > > simply catting a single large (sparse) file to /dev/null.
> > 
> > Then you have a serious design flaw if you are relying on a shrinker
> > to control memory consumed by page cache radix trees as a result of
> > page cache reclaim inserting exceptional entries into the radix
> > tree and then forgetting about them.
> 
> I'm not forgetting about them, I just track them very coarsely by
> linking up address spaces and then lazily enforce their upper limit
> when memory is tight by using the shrinker callback.  The assumption
> was that actually scanning them is such a rare event that we trade the
> rare computational costs for smaller memory consumption most of the
> time.

Sure, I understand the tradeoff that you made. But there's nothing
worse than a system that slows down unpredictably because of some
magic threshold in some subsystem has been crossed and
computationally expensive operations kick in.

Keep in mind that shrinkers are called in parallel, too, so once the
thresholdis crossed you have the possibility of every single CPU in
the system running that shrinker at the same time....

> > To work around this, you keep a global count of exceptional entries
> > and a global list of inodes with such exceptional radix tree
> > entries. The count doesn't really tell you how much memory is used
> > by the radix trees - the same count can mean an order of
> > magnitude difference in actual memory consumption (one shadow entry
> > per radix tree node vs 64) so it's not a very good measure to base
> > memory reclaim behaviour on but it is an inferred (rather than
> > actual) object count.
> 
> Capping shadow entries instead of memory consumption was intentional.
> They should be trimmed based on whether old shadow entries are still
> meaningful and have an effect if refaulted, not based on memory
> pressure.  These entries have an influence on future memory pressure
> so we shouldn't kick them out based on how tight resources are but
> based on whether there are too many expired entries.

Then I suspect that a shrinker is the wrong interface to us, as they
are designed to trim caches when resources are tight. What your
current design will lead to is windup, where it does nothing for
many calls and then when it passes the threshold the delta is so
large that it will ask the shrinker to scan the entire cache.

So, while your intention is that it reacts to expired entry count,
the reality is that it will result in a shadow entry count that
looks like a sawtooth over time instead of a smooth, slowly varying
line that changes value only as workloads change....

The architecture of shrinkers is that they act little by little to
memory pressure to keep all the caches in the system balanced
dynmaically, so when memory pressure occurs we don't have the
balance of the system change. Doing nothing until a magic threshold
is reached and then doing lots of work at that point results in
non-deterministic behaviour because the balance and behaviour of the
system will change drastically at that threshold point.  IOWs,
creating a shrinker that only does really expensive operations when
it passes a high threshold is not a good idea from a behavioural
POV.

> Previous implementations of non-resident history from Peter & Rik
> maintained a big system-wide hash table with a constant cost instead
> of using radix tree memory like this.  My idea was that this is cache
> friendlier and memory consumption should be lower in most cases and
> the shrinker is only there to cap the extreme / malicious cases.

Yes, it's an improvement on the hash table in some ways, but in
other ways it is much worse.

> > You walk the inode list by a shrinker and scan radix trees for
> > shadow entries that can be removed. It's expensive to scan radix
> > trees, especially for inodes with large amounts of cached data, so
> > this could do a lot of work to find very little in way of entries to
> > free.
> > 
> > The shrinker doesn't rotate inodes on the list, so it will always
> > scan the same inodes on the list in the same order and so if memory
> > reclaim removes a few pages from an inode with a large amount of
> > cached pages between each shrinker call, then those radix trees will
> > be repeatedly scanned in it's entirety on each call to the shrinker.
> >
> > Also, the shrinker only decrements nr_to_scan when it finds an entry
> > to reclaim. nr_to_scan is the number of objects to scan for reclaim,
> > not the number of objects to reclaim. hence the shrinker will be
> > doing a lot of scanning if there's inodes at the head of the list
> > with large radix trees....
> 
> I realize all of this.  The scanner is absolutely expensive, I just
> didn't care because it's not supposed to run in the first place but
> rather act like an emergency brake.
> 
> Again, the shrinker isn't even called until shadow entries are in
> excess, regardless of how bad memory pressure is.  On the other hand,
> the fact that this code is unneeded most of the time makes the struct
> inode size increase even worse.

Yup, and that's one of the big problems I have with the design.

> > > > And removing the special shrinker will bring the struct inode size
> > > > increase back to only 8 bytes, and I think we can live with that
> > > > increase given the workload improvements that the rest of the
> > > > functionality brings.
> > > 
> > > That would be very desirable indeed.
> > > 
> > > What we would really want is a means of per-zone tracking of
> > > radix_tree_nodes occupied by shadow entries but I can't see a way to
> > > do this without blowing up the radix tree structure at a much bigger
> > > cost than an extra list_head in struct address_space.
> > 
> > Putting a list_head in the radix tree node is likely to have a lower
> > cost than putting one in every inode. Most cached inodes don't have
> > any page cache associated with them. Indeed, my workstation right
> > now shows:
> > 
> > $ sudo grep "radix\|xfs_inode" /proc/slabinfo 
> > xfs_inode         277773 278432   1024    4    1 : tunables   54   27    8 : slabdata  69608  69608      0
> > radix_tree_node    74137  74956    560    7    1 : tunables   54   27    8 : slabdata  10708  10708      0
> 
> Is that a slab configuration?  On my slub config, this actually shows
> 568 even though the structure definition really adds up to 560 bytes.

I'm assuming that it is SLAB - it's the 3.11 kernel that debian
shipped out of experimental. yup:

$ grep SLAB /boot/config-3.11-trunk-amd64 
CONFIG_SLAB=y
CONFIG_SLABINFO=y
# CONFIG_DEBUG_SLAB is not set
$


> Yes, I really don't like the extra inode cost and the computational
> overhead in corner cases.

I think we are agreed on that :)

> What I do like is that the shadow entries are in-line and not in an
> auxiliary array and that memory consumption of shadow entries is
> mostly low, so I'm not eager to change the data structure.

And i'm not disagreeing with you there, either.

> But it
> looks like tracking radix tree nodes with a list and backpointers to
> the mapping object for the lock etc. will be a major pain in the ass.

Perhaps so - it may not work out when we get down to the fine
details...

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

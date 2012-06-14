Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2467B6B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 23:34:36 -0400 (EDT)
Date: Thu, 14 Jun 2012 13:34:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: add gfp_mask parameter to vm_map_ram()
Message-ID: <20120614033429.GD7339@dastard>
References: <20120612012134.GA7706@localhost>
 <20120613123932.GA1445@localhost>
 <20120614012026.GL3019@devil.redhat.com>
 <20120614014902.GB7289@localhost>
 <4FD94779.3030108@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD94779.3030108@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com

On Thu, Jun 14, 2012 at 11:07:53AM +0900, Minchan Kim wrote:
> Hi Fengguang,
> 
> On 06/14/2012 10:49 AM, Fengguang Wu wrote:
> 
> > On Thu, Jun 14, 2012 at 11:20:26AM +1000, Dave Chinner wrote:
> >> On Wed, Jun 13, 2012 at 08:39:32PM +0800, Fengguang Wu wrote:
> >>> Hi Christoph, Dave,
> >>>
> >>> I got this lockdep warning on XFS when running the xfs tests:

[rant warning]

> >> Bug in vm_map_ram - it does an unconditional GFP_KERNEL allocation
> >> here, and we are in a GFP_NOFS context. We can't pass a gfp_mask to
> >> vm_map_ram(), so until vm_map_ram() grows that we can't fix it...
> > 
> > This trivial patch should fix it.
.....
> 
> It shouldn't work because vmap_page_range still can allocate GFP_KERNEL by pud_alloc in vmap_pud_range.
> For it, I tried [1] but other mm guys want to add WARNING [2] so let's avoiding gfp context passing.

Oh, wonderful, you're pulling the "it's not a MM issue, don't use
vmalloc" card.

> [1] https://lkml.org/lkml/2012/4/23/77

https://lkml.org/lkml/2012/4/24/29

"vmalloc was never supposed to use gfp flags for allocation
"context" restriction. I.e., it was always supposed to have
blocking, fs, and io capable allocation context."

vmalloc always was a badly neglected, ugly step-sister of kmalloc
that was kept in the basement and only brought out when the tax
collector called.  But that inner ugliness doesn't change the fact
that beatiful things have been built around it. XFS has used
vm_map_ram() and it's predecessor since it was first ported to linux
some 13 or 14 years ago, so the above claim is way out of date. i.e.
vmalloc has been used in GFP_NOFS context since before that flag
even existed....

http://lkml.org/lkml/2012/4/24/67

"I would say add a bit of warnings and documentation, and see what
can be done about callers."

Wonderful. Well, there's about 2 years of work queued up for me
before I even get to the do the open heart surgery that would allow
XFS to handle memory allocation failures at this level without
causing the filesystem to shut down.

Andrew Morton's response:

https://lkml.org/lkml/2012/4/24/413

"There are gruesome problems in block/blk-throttle.c (thread
"mempool, percpu, blkcg: fix percpu stat allocation and remove
stats_lock").  It wants to do an alloc_percpu()->vmalloc() from the
IO submission path, under GFP_NOIO.

Changing vmalloc() to take a gfp_t does make lots of sense, although
I worry a bit about making vmalloc() easier to use!"

OK, so according to Andrew there is no technical reason why it can't
be done, it's just handwaving about "vmalloc is bad"....


> [2] https://lkml.org/lkml/2012/5/2/340

https://lkml.org/lkml/2012/5/2/452

"> Where are these offending callsites?

dm:
...
ubi:
....
ext4:
....
ntfs:
....
ubifs:
....
mm:
....
ceph:
...."

So, we've got a bunch of filesystems that require vmalloc under
GFP_NOFS conditions. Perhaps there's a reason for needing to be able
to do this in filesystem code? Like, perhaps, avoiding memory
reclaim deadlocks?

https://lkml.org/lkml/2012/5/3/27

"Note that in writeback paths, a "good citizen" filesystem should
not require any allocations, or at least it should be able to
tolerate allocation failures.  So fixing that would be a good idea
anyway."

Oh, please. I have been hearing this for years, and are we any
closer to it? No, we are further away from ever being able to
acheive this than ever. Face it, filesystems require memory
allocation to write dirty data to disk, and the amount is almost
impossible to define. Hence mempools can't be used because we can't
give any guarantees of forward progress. And for vmalloc?

Filesystems widely use vmalloc/vm_map_ram because kmalloc fails on
large contiguous allocations. This renders kmalloc unfit for
purpose, so we have to fall back to single page allocation and
vm_map_ram or vmalloc so that the filesystem can function properly.
And to avoid deadlocks, all memory allocation must be able to
specify GFP_NOFS to prevent the MM subsystem from recursing into the
filesystem. Therefore, vmalloc needs to support GFP_NOFS.

I don't care how you make it happen, just fix it. Trying to place
the blame on the filesystem folk for using vmalloc in GFP_NOFS
contexts is a total and utter cop-out, because mm folk of all people
should know that non-zero order kmalloc is not a reliable
alternative....

[end rant]

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

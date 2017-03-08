Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88CD4831E7
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 09:34:15 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w37so11504758wrc.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 06:34:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si4626529wrd.2.2017.03.08.06.34.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 06:34:13 -0800 (PST)
Date: Wed, 8 Mar 2017 15:34:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 0/6] Slab Fragmentation Reduction V16
Message-ID: <20170308143411.GC11034@dhcp22.suse.cz>
References: <20170307212429.044249411@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307212429.044249411@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

On Tue 07-03-17 15:24:29, Cristopher Lameter wrote:
> V15->V16
> - Reworked core logic against 4.11 kernel code
> - Just the bare bones for Matthew to have the ability to review
>   the patches and to see how slab defrag could work with the radix
>   tree and/or new xarrays. Skip reclaim integration etc etc.

JFTR the previous version was posted here: https://lwn.net/Articles/371892/
and Dave had some concerns https://lkml.org/lkml/2010/2/8/329 which led
to a different approach and design of the slab shrinking
https://lkml.org/lkml/2010/2/8/329.

I haven't looked at this series yet but has those concerns been
addressed/considered?

> 
> V14->V15
> - The lost version ... I posted it in 2010 but the material is nowhere
>   to be found on my backups.
> 
> V13->V14
> - Rediff against linux-next on request of Andrew
> - TestSetPageLocked -> trylock_page conversion.
> 
> Slab fragmentation is mainly an issue if Linux is used as a fileserver
> and large amounts of dentries, inodes and buffer heads accumulate. In some
> load situations the slabs become very sparsely populated so that a lot of
> memory is wasted by slabs that only contain one or a few objects. In
> extreme cases the performance of a machine will become sluggish since
> we are continually running reclaim without much succes.
> Slab defragmentation adds the capability to recover the memory that
> is wasted.
> 
> Memory reclaim for the following slab caches is possible:
> 
> 1. dentry cache
> 2. inode cache (with a generic interface to allow easy setup of more
>    filesystems than the currently supported ext2/3/4 reiserfs, XFS
>    and proc)
> 3. buffer_heads
> 
> One typical mechanism that triggers slab defragmentation on my systems
> is the daily run of
> 
> 	updatedb
> 
> Updatedb scans all files on the system which causes a high inode and dentry
> use. After updatedb is complete we need to go back to the regular use
> patterns (typical on my machine: kernel compiles). Those need the memory now
> for different purposes. The inodes and dentries used for updatedb will
> gradually be aged by the dentry/inode reclaim algorithm which will free
> up the dentries and inode entries randomly through the slabs that were
> allocated. As a result the slabs will become sparsely populated. If they
> become empty then they can be freed but a lot of them will remain sparsely
> populated. That is where slab defrag comes in: It removes the objects from
> the slabs with just a few entries reclaiming more memory for other uses.
> In the simplest case (as provided here) this is done by simply reclaiming
> the objects.
> 
> However, if the logic in the kick() function is made more
> sophisticated then we will be able to move the objects out of the slabs.
> Allocations of objects is possible if a slab is fragmented without the use of
> the page allocator because a large number of free slots are available. Moving
> an object will reduce fragmentation in the slab the object is moved to.
> 
> V12->v13:
> - Rebase onto Linux 2.6.27-rc1 (deal with page flags conversion, ctor parameters etc)
> - Fix unitialized variable issue
> 
> V11->V12:
> - Pekka and me fixed various minor issues pointed out by Andrew.
> - Split ext2/3/4 defrag support patches.
> - Add more documentation
> - Revise the way that slab defrag is triggered from reclaim. No longer
>   use a timeout but track the amount of slab reclaim done by the shrinkers.
>   Add a field in /proc/sys/vm/slab_defrag_limit to control the threshold.
> - Display current slab_defrag_counters in /proc/zoneinfo (for a zone) and
>   /proc/sys/vm/slab_defrag_count (for global reclaim).
> - Add new config vaue slab_defrag_limit to /proc/sys/vm/slab_defrag_limit
> - Add a patch that obsoletes SLAB and explains why SLOB does not support
>   defrag (Either of those could be theoretically equipped to support
>   slab defrag in some way but it seems that Andrew/Linus want to reduce
>   the number of slab allocators).
> 
> V10->V11
> - Simplify determination when to reclaim: Just scan over all partials
>   and check if they are sparsely populated.
> - Add support for performance counters
> - Rediff on top of current slab-mm.
> - Reduce frequency of scanning. A look at the stats showed that we
>   were calling into reclaim very frequently when the system was under
>   memory pressure which slowed things down. Various measures to
>   avoid scanning the partial list too frequently were added and the
>   earlier (expensive) method of determining the defrag ratio of the slab
>   cache as a whole was dropped. I think this addresses the issues that
>   Mel saw with V10.
> 
> V9->V10
> - Rediff against upstream
> 
> V8->V9
> - Rediff against 2.6.24-rc6-mm1
> 
> V7->V8
> - Rediff against 2.6.24-rc3-mm2
> 
> V6->V7
> - Rediff against 2.6.24-rc2-mm1
> - Remove lumpy reclaim support. No point anymore given that the antifrag
>   handling in 2.6.24-rc2 puts reclaimable slabs into different sections.
>   Targeted reclaim never triggers. This has to wait until we make
>   slabs movable or we need to perform a special version of lumpy reclaim
>   in SLUB while we scan the partial lists for slabs to kick out.
>   Removal simplifies handling significantly since we
>   get to slabs in a more controlled way via the partial lists.
>   The patchset now provides pure reduction of fragmentation levels.
> - SLAB/SLOB: Provide inlines that do nothing
> - Fix various smaller issues that were brought up during review of V6.
> 
> V5->V6
> - Rediff against 2.6.24-rc2 + mm slub patches.
> - Add reviewed by lines.
> - Take out the experimental code to make slab pages movable. That
>   has to wait until this has been considered by Mel.
> 
> V4->V5:
> - Support lumpy reclaim for slabs
> - Support reclaim via slab_shrink()
> - Add constructors to insure a consistent object state at all times.
> 
> V3->V4:
> - Optimize scan for slabs that need defragmentation
> - Add /sys/slab/*/defrag_ratio to allow setting defrag limits
>   per slab.
> - Add support for buffer heads.
> - Describe how the cleanup after the daily updatedb can be
>   improved by slab defragmentation.
> 
> V2->V3
> - Support directory reclaim
> - Add infrastructure to trigger defragmentation after slab shrinking if we
>   have slabs with a high degree of fragmentation.
> 
> V1->V2
> - Clean up control flow using a state variable. Simplify API. Back to 2
>   functions that now take arrays of objects.
> - Inode defrag support for a set of filesystems
> - Fix up dentry defrag support to work on negative dentries by adding
>   a new dentry flag that indicates that a dentry is not in the process
>   of being freed or allocated.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 95E9C6B006E
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 17:32:01 -0500 (EST)
Received: by pdbft15 with SMTP id ft15so17162969pdb.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 14:32:01 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id cx1si17264851pad.152.2015.03.02.14.31.58
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 14:32:00 -0800 (PST)
Date: Tue, 3 Mar 2015 09:31:54 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150302223154.GJ18360@dastard>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F42FEA.1020404@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F42FEA.1020404@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 10:39:54AM +0100, Vlastimil Babka wrote:
> On 02/23/2015 08:32 AM, Dave Chinner wrote:
> >On Sun, Feb 22, 2015 at 05:29:30PM -0800, Andrew Morton wrote:
> >>On Mon, 23 Feb 2015 11:45:21 +1100 Dave Chinner <david@fromorbit.com> wrote:
> >>
> >>Yes, as we do for __GFP_HIGH and PF_MEMALLOC etc.  Add a dynamic
> >>reserve.  So to reserve N pages we increase the page allocator dynamic
> >>reserve by N, do some reclaim if necessary then deposit N tokens into
> >>the caller's task_struct (it'll be a set of zone/nr-pages tuples I
> >>suppose).
> >>
> >>When allocating pages the caller should drain its reserves in
> >>preference to dipping into the regular freelist.  This guy has already
> >>done his reclaim and shouldn't be penalised a second time.  I guess
> >>Johannes's preallocation code should switch to doing this for the same
> >>reason, plus the fact that snipping a page off
> >>task_struct.prealloc_pages is super-fast and needs to be done sometime
> >>anyway so why not do it by default.
> >
> >That is at odds with the requirements of demand paging, which
> >allocate for objects that are reclaimable within the course of the
> >transaction. The reserve is there to ensure forward progress for
> >allocations for objects that aren't freed until after the
> >transaction completes, but if we drain it for reclaimable objects we
> >then have nothing left in the reserve pool when we actually need it.
> >
> >We do not know ahead of time if the object we are allocating is
> >going to modified and hence locked into the transaction. Hence we
> >can't say "use the reserve for this *specific* allocation", and so
> >the only guidance we can really give is "we will to allocate and
> >*permanently consume* this much memory", and the reserve pool needs
> >to cover that consumption to guarantee forwards progress.
> 
> I'm not sure I understand properly. You don't know if a specific
> allocation is permanent or reclaimable, but you can tell in advance
> how much in total will be permanent? Is it because you are
> conservative and assume everything will be permanent, or how?

Because we know the worst case object modification constraints
*exactly* (e.g. see fs/xfs/libxfs/xfs_trans_resv.c), we know
exactly what in memory objects we lock into the transaction and what
memory is required to modify and track those objects. e.g: for a
data extent allocation, the log reservation is as such:

/*
 * In a write transaction we can allocate a maximum of 2
 * extents.  This gives:
 *    the inode getting the new extents: inode size
 *    the inode's bmap btree: max depth * block size
 *    the agfs of the ags from which the extents are allocated: 2 * sector
 *    the superblock free block counter: sector size
 *    the allocation btrees: 2 exts * 2 trees * (2 * max depth - 1) * block size
 * And the bmap_finish transaction can free bmap blocks in a join:
 *    the agfs of the ags containing the blocks: 2 * sector size
 *    the agfls of the ags containing the blocks: 2 * sector size
 *    the super block free block counter: sector size
 *    the allocation btrees: 2 exts * 2 trees * (2 * max depth - 1) * block size
 */
STATIC uint
xfs_calc_write_reservation(
        struct xfs_mount        *mp)
{
        return XFS_DQUOT_LOGRES(mp) +
                MAX((xfs_calc_inode_res(mp, 1) +
                     xfs_calc_buf_res(XFS_BM_MAXLEVELS(mp, XFS_DATA_FORK),
                                      XFS_FSB_TO_B(mp, 1)) +
                     xfs_calc_buf_res(3, mp->m_sb.sb_sectsize) +
                     xfs_calc_buf_res(XFS_ALLOCFREE_LOG_COUNT(mp, 2),
                                      XFS_FSB_TO_B(mp, 1))),
                    (xfs_calc_buf_res(5, mp->m_sb.sb_sectsize) +
                     xfs_calc_buf_res(XFS_ALLOCFREE_LOG_COUNT(mp, 2),
                                      XFS_FSB_TO_B(mp, 1))));
}

It's trivial to extend this logic to to memory allocation
requirements, because the above is an exact encoding of all the
objects we "permanently consume" memory for within the transaction.

What we don't know is how many objects we might need to scan to find
the objects we will eventually modify.  Here's an (admittedly
extreme) example to demonstrate a worst case scenario: allocate a
64k data extent. Because it is an exact size allocation, we look it
up in the by-size free space btree. Free space is fragmented, so
there are about a million 64k free space extents in the tree.

Once we find the first 64k extent, we search them to find the best
locality target match.  The btree records are 16 bytes each, so we
fit roughly 500 to a 4k block. Say we search half the extents to
find the best match - i.e. we walk a thousand leaf blocks before
finding the match we want, and modify that leaf block.

Now, the modification removed an entry from the leaf and tht
triggers leaf merge thresholds, so a merge with the 1002nd block
occurs. That block now demand pages in and we then modify and join
it to the transaction. Now we walk back up the btree to update
indexes, merging blocks all the way back up to the root.  We have a
worst case size btree (5 levels) and we merge at every level meaning
we demand page another 8 btree blocks and modify them.

In this case, we've demand paged ~1010 btree blocks, but only
modified 10 of them. i.e. the memory we consumed permanently was
only 10 4k buffers (approx. 10 slab and 10 page allocations), but
the allocation demand was 2 orders of magnitude more than the
unreclaimable memory consumption of the btree modification.

I hope you start to see the scope of the problem now...

> Can you at least at some later point in transaction recognize that
> "OK, this object was not permanent after all" and tell mm that it
> can lower your reserve?

I'm not including any memory used by objects we know won't be locked
into the transaction in the reserve. Demand paged object memory is
essentially unbound but is easily reclaimable. That reclaim will
give us forward progress guarantees on the memory required here.

> >Yes, that's the big problem with preallocation, as well as your
> >proposed "depelete the reserved memory first" approach. They
> >*require* up front "preallocation" of free memory, either directly
> >by the application, or internally by the mm subsystem.
> 
> I don't see why it would deadlock, if during reserve time the mm can
> return ENOMEM as the reserver should be able to back out at that
> point.

Preallocated reserves do not allow for unbound demand paging of
reclaimable objects within reserved allocation contexts.

Cheers

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

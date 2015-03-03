Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C59966B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 04:13:12 -0500 (EST)
Received: by widem10 with SMTP id em10so19908585wid.0
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 01:13:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si1777446wiv.19.2015.03.03.01.13.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 01:13:11 -0800 (PST)
Message-ID: <54F57B20.3090803@suse.cz>
Date: Tue, 03 Mar 2015 10:13:04 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: How to handle TIF_MEMDIE stalls?
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp> <20150217125315.GA14287@phnom.home.cmpxchg.org> <20150217225430.GJ4251@dastard> <20150219102431.GA15569@phnom.home.cmpxchg.org> <20150219225217.GY12722@dastard> <20150221235227.GA25079@phnom.home.cmpxchg.org> <20150223004521.GK12722@dastard> <20150222172930.6586516d.akpm@linux-foundation.org> <20150223073235.GT4251@dastard> <54F42FEA.1020404@suse.cz> <20150302223154.GJ18360@dastard>
In-Reply-To: <20150302223154.GJ18360@dastard>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On 03/02/2015 11:31 PM, Dave Chinner wrote:
> On Mon, Mar 02, 2015 at 10:39:54AM +0100, Vlastimil Babka wrote:
>> On 02/23/2015 08:32 AM, Dave Chinner wrote:
>> >On Sun, Feb 22, 2015 at 05:29:30PM -0800, Andrew Morton wrote:
>> >>On Mon, 23 Feb 2015 11:45:21 +1100 Dave Chinner <david@fromorbit.com> wrote:
>> >We do not know ahead of time if the object we are allocating is
>> >going to modified and hence locked into the transaction. Hence we
>> >can't say "use the reserve for this *specific* allocation", and so
>> >the only guidance we can really give is "we will to allocate and
>> >*permanently consume* this much memory", and the reserve pool needs
>> >to cover that consumption to guarantee forwards progress.
>> 
>> I'm not sure I understand properly. You don't know if a specific
>> allocation is permanent or reclaimable, but you can tell in advance
>> how much in total will be permanent? Is it because you are
>> conservative and assume everything will be permanent, or how?
> 
> Because we know the worst case object modification constraints
> *exactly* (e.g. see fs/xfs/libxfs/xfs_trans_resv.c), we know
> exactly what in memory objects we lock into the transaction and what
> memory is required to modify and track those objects. e.g: for a
> data extent allocation, the log reservation is as such:
> 
> /*
>  * In a write transaction we can allocate a maximum of 2
>  * extents.  This gives:
>  *    the inode getting the new extents: inode size
>  *    the inode's bmap btree: max depth * block size
>  *    the agfs of the ags from which the extents are allocated: 2 * sector
>  *    the superblock free block counter: sector size
>  *    the allocation btrees: 2 exts * 2 trees * (2 * max depth - 1) * block size
>  * And the bmap_finish transaction can free bmap blocks in a join:
>  *    the agfs of the ags containing the blocks: 2 * sector size
>  *    the agfls of the ags containing the blocks: 2 * sector size
>  *    the super block free block counter: sector size
>  *    the allocation btrees: 2 exts * 2 trees * (2 * max depth - 1) * block size
>  */
> STATIC uint
> xfs_calc_write_reservation(
>         struct xfs_mount        *mp)
> {
>         return XFS_DQUOT_LOGRES(mp) +
>                 MAX((xfs_calc_inode_res(mp, 1) +
>                      xfs_calc_buf_res(XFS_BM_MAXLEVELS(mp, XFS_DATA_FORK),
>                                       XFS_FSB_TO_B(mp, 1)) +
>                      xfs_calc_buf_res(3, mp->m_sb.sb_sectsize) +
>                      xfs_calc_buf_res(XFS_ALLOCFREE_LOG_COUNT(mp, 2),
>                                       XFS_FSB_TO_B(mp, 1))),
>                     (xfs_calc_buf_res(5, mp->m_sb.sb_sectsize) +
>                      xfs_calc_buf_res(XFS_ALLOCFREE_LOG_COUNT(mp, 2),
>                                       XFS_FSB_TO_B(mp, 1))));
> }
> 
> It's trivial to extend this logic to to memory allocation
> requirements, because the above is an exact encoding of all the
> objects we "permanently consume" memory for within the transaction.
> 
> What we don't know is how many objects we might need to scan to find
> the objects we will eventually modify.  Here's an (admittedly
> extreme) example to demonstrate a worst case scenario: allocate a
> 64k data extent. Because it is an exact size allocation, we look it
> up in the by-size free space btree. Free space is fragmented, so
> there are about a million 64k free space extents in the tree.
> 
> Once we find the first 64k extent, we search them to find the best
> locality target match.  The btree records are 16 bytes each, so we
> fit roughly 500 to a 4k block. Say we search half the extents to
> find the best match - i.e. we walk a thousand leaf blocks before
> finding the match we want, and modify that leaf block.
> 
> Now, the modification removed an entry from the leaf and tht
> triggers leaf merge thresholds, so a merge with the 1002nd block
> occurs. That block now demand pages in and we then modify and join
> it to the transaction. Now we walk back up the btree to update
> indexes, merging blocks all the way back up to the root.  We have a
> worst case size btree (5 levels) and we merge at every level meaning
> we demand page another 8 btree blocks and modify them.
> 
> In this case, we've demand paged ~1010 btree blocks, but only
> modified 10 of them. i.e. the memory we consumed permanently was
> only 10 4k buffers (approx. 10 slab and 10 page allocations), but
> the allocation demand was 2 orders of magnitude more than the
> unreclaimable memory consumption of the btree modification.
> 
> I hope you start to see the scope of the problem now...

Thanks, that example did help me understand your position much better.
So you would need to reserve for a worst case number of the objects you modify,
plus some slack for the demand-paged objects that you need to temporarily
access, before you can drop and reclaim them (I suppose that in some of the tree
operations, you need to be holding references to e.g. two nodes at a time, or
maybe the full depth). Or maybe since all these temporary objects are
potentially modifiable, it's already accounted for in the "might be modified" part.

>> Can you at least at some later point in transaction recognize that
>> "OK, this object was not permanent after all" and tell mm that it
>> can lower your reserve?
> 
> I'm not including any memory used by objects we know won't be locked
> into the transaction in the reserve. Demand paged object memory is
> essentially unbound but is easily reclaimable. That reclaim will
> give us forward progress guarantees on the memory required here.
> 
>> >Yes, that's the big problem with preallocation, as well as your
>> >proposed "depelete the reserved memory first" approach. They
>> >*require* up front "preallocation" of free memory, either directly
>> >by the application, or internally by the mm subsystem.
>> 
>> I don't see why it would deadlock, if during reserve time the mm can
>> return ENOMEM as the reserver should be able to back out at that
>> point.
> 
> Preallocated reserves do not allow for unbound demand paging of
> reclaimable objects within reserved allocation contexts.

OK I think I get the point now.

So, lots of the concerns by me and others were about the wasted memory due to
reservations, and increased pressure on the rest of the system. I was thinking,
are you able, at the beginning of the transaction (for this purposes, I think of
transaction as the work that starts with the memory reservation, then it cannot
rollback and relies on the reserves, until it commits and frees the memory),
determine whether the transaction cannot be blocked in its progress by any other
transaction, and the only thing that would block it would be inability to
allocate memory during its course?

If that was the case, we could "share" the reserved memory for all ongoing
transactions of a single class (i.e. xfs transactions). If a transaction knows
it cannot be blocked by anything else, only then it passes the
GFP_CAN_USE_RESERVE flag to the allocator. Once the allocator gives part of the
reserve to one such transaction, it will deny the reserves to other such
transactions, until the first one finishes. In practice it would be more complex
of course, but it should guarantee forward progress without lots of
wasted memory (maybe we wouldn't have to rely on treting clean reclaimable pages
as reserve in that case, which was also pointed out to be problematic).

Of course it all depends on whether you are able to determine the "guaranteed to
not block". I can however easily imagine it's not possible...

> Cheers
> 
> Dave.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

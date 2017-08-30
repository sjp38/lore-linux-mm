Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1AFE6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 04:06:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r187so10543645pfr.8
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:06:16 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id p2si4490583pll.134.2017.08.30.01.06.14
        for <linux-mm@kvack.org>;
        Wed, 30 Aug 2017 01:06:15 -0700 (PDT)
Date: Wed, 30 Aug 2017 18:05:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170830080558.GK10621@dastard>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170829081453.GA10196@infradead.org>
 <20170829123126.GB10621@dastard>
 <20170829124536.GA26339@infradead.org>
 <20170829215157.GC10621@dastard>
 <20170830071403.GA8904@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830071403.GA8904@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, Aug 30, 2017 at 12:14:03AM -0700, Christoph Hellwig wrote:
> On Wed, Aug 30, 2017 at 07:51:57AM +1000, Dave Chinner wrote:
> > Right, I've looked at btrees, too, but it's more complex than just
> > using an rbtree. I originally looked at using Peter Z's old
> > RCU-aware btree code, but it doesn't hold data in the tree leaves.
> > So that needed significant modification to make work without a
> > memory alloc per extent and that didn't work with original aim of
> > RCU-safe extent lookups.  I also looked at that "generic" btree
> > stuff that came from logfs, and after a little while ran away
> > screaming.
> 
> I started with the latter, but it's not really looking like it any more:
> there nodes are formatted as a series of u64s instead of all the
> long magic,

Yeah, that was about where I started to run away and look for
something nicer....

> and the data is stored inline - in fact I use a cute
> trick to keep the size down, derived from our "compressed" on disk
> extent format:
> 
> Key:
> 
>  +-------+----------------------------+
>  | 00:51 | all 52 bits of startoff    |
>  | 52:63 | low 12 bits of startblock  |
>  +-------+----------------------------+
> 
> Value
> 
>  +-------+----------------------------+
>  | 00:20 | all 21 bits of length      |
>  |    21 | unwritten extent bit       |
>  | 22:63 | high 42 bits of startblock |
>  +-------+----------------------------+
> 
> So we only need a 64-bit key and a 64-bit value by abusing parts
> of the key to store bits of the startblock.

Neat! :)

> For non-leaf nodes we iterate through the keys only, never touching
> the cache lines for the value.  For the leaf nodes we have to touch
> the value anyway because we have to do a range lookup to find the
> exact record.
> 
> This works fine so far in an isolated simulator, and now I'm ammending
> it to be a b+tree with pointers to the previous and next node so
> that we can nicely implement our extent iterators instead of doing
> full lookups.

Ok, that sounds exactly what I have been looking towards....

> > The sticking point, IMO, is the extent array index based lookups in
> > all the bmbt code.  I've been looking at converting all that to use
> > offset based lookups and a cursor w/ lookup/inc/dec/insert/delete
> > ioperations wrapping xfs_iext_lookup_ext() and friends. This means
> > the modifications are pretty much identical to the on-disk extent
> > btree, so they can be abstracted out into a single extent update
> > interface for both trees.  Have you planned/done any cleanup/changes
> > with this code?
> 
> I've done various cleanups, but I've not yet consolidated the two.
> Basically step one at the moment is to move everyone to
> xfs_iext_lookup_extent + xfs_iext_get_extent that removes all the
> bad intrusion.

Yup.

> Once we move to the actual b+trees the extnum_t cursor will be replaced
> with a real cursor structure that contains a pointer to the current
> b+tree leaf node, and an index inside that, which will allows us very
> efficient iteration.  The xfs_iext_get_extent calls will be replaced
> with more specific xfs_iext_prev_extent, xfs_iext_next_extent calls
> that include the now slightly more complex cursor decrement, increment
> as well as a new xfs_iext_last_extent helper for the last extent
> that we need in a few places.

Ok, that's sounds like it'll fit right in with what I've been
prototyping for the extent code in xfs_bmap.c. I can make that work
with a cursor-based lookup/inc/dec/ins/del API similar to the bmbt
API. I've been looking to abstract the extent manipulations out into
functions that modify both trees like this:

[note: just put template code in to get my thoughts straight, it's
not working code]

+static int
+xfs_bmex_delete(
+       struct xfs_iext_cursor          *icur,
+       struct xfs_btree_cursor         *cur,
+       int                             *nextents)
+{
+       int                             i;
+
+       xfs_iext_remove(bma->ip, bma->idx + 1, 2, state);
+       if (nextents)
+               (*nextents)--;
+       if (!cur)
+               return 0;
+       error = xfs_btree_delete(cur, &i);
+       if (error)
+               return error;
+       XFS_WANT_CORRUPTED_RETURN(cur->bc_mp, i == 1);
+       return 0;
+}
+
+static int
+xfs_bmex_increment(
+       struct xfs_iext_cursor          *icur,
+       struct xfs_btree_cursor         *cur)
+{
+       int                             i;
+
+       icur->ep = xfs_iext_get_right_ext(icur->ep);
+       if (!cur)
+               return 0;
+       error = xfs_btree_increment(cur, 0, &i);
+       if (error)
+               return error;
+       XFS_WANT_CORRUPTED_RETURN(cur->bc_mp, i == 1);
+       return 0;
+}
+
+static int
+xfs_bmex_decrement(
+       struct xfs_iext_cursor          *icur,
+       struct xfs_btree_cursor         *cur)
+{
+       int                             i;
+
+       icur->ep = xfs_iext_get_left_ext(icur->ep);
+       if (!cur)
+               return 0;
+       error = xfs_btree_decrement(cur, 0, &i);
+       if (error)
+               return error;
+       XFS_WANT_CORRUPTED_RETURN(cur->bc_mp, i == 1);
+       return 0;
+}

And so what you're doing would fit straight into that. I'm
ending up with is extent operations that look like this:

xfs_bmap_add_extent_delay_real()
.....
	case BMAP_LEFT_FILLING | BMAP_LEFT_CONTIG |
             BMAP_RIGHT_FILLING | BMAP_RIGHT_CONTIG:
                /*
                 * Filling in all of a previously delayed allocation extent.
                 * The left and right neighbors are both contiguous with new.
                 */
+               rval |= XFS_ILOG_CORE;
+
+               /* remove the incore delalloc extent first */
+               error = xfs_bmex_delete(&icur, NULL, nextents);
+               if (error)
+                       goto done;
+
+               /*
+                * update incore and bmap extent trees
+                *      1. set cursors to the right extent
+                *      2. remove the right extent
+                *      3. update the left extent to span all 3 extent ranges
+                */
+               error = xfs_bmex_lookup_eq(&icur, bma->cur, RIGHT.br_startoff,
+                               RIGHT.br_startblock, RIGHT.br_blockcount, 1);
+               if (error)
+                       goto done;
+               error = xfs_bmex_delete(&icur, bma->cur, NULL);
+               if (error)
+                       goto done;
+               error = xfs_bmex_decrement(&icur, bma->cur);
+               if (error)
+                       goto done;
+               error = xfs_bmex_update(&icur, bma->cur, LEFT.br_startoff,
+                               LEFT.br_startblock,
+                               LEFT.br_blockcount + PREV.br_blockcount +
+                                       RIGHT.br_blockcount,
+                               LEFT.br_state);
+               if (error)
+                       goto done;
 		break;
....

And I'm starting to see where there are common extent manipulations
being done so there's probably a fair amount of further factoring
that can be done on top of this....

> insert/delete remain very similar to what they do right now, they'll
> get a different cursor type, and the manual xfs_iext_add calls will
> go away.  The new xfs_iext_update_extent helper I posted to the list
> yesterday will become a bit more complex, as changing the startoff
> will have to be propagated up the tree.

I've had a quick look at them and pulled it down into my tree for
testing (which had a cpu burning hang on xfs/020 a few minutes ago),
but I'll spend more time grokking them tomorrow.

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

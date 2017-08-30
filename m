Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0236B04B2
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 03:14:09 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id w204so4142869ita.2
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 00:14:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a8si1166584ioj.255.2017.08.30.00.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 00:14:06 -0700 (PDT)
Date: Wed, 30 Aug 2017 00:14:03 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170830071403.GA8904@infradead.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170829081453.GA10196@infradead.org>
 <20170829123126.GB10621@dastard>
 <20170829124536.GA26339@infradead.org>
 <20170829215157.GC10621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829215157.GC10621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, Aug 30, 2017 at 07:51:57AM +1000, Dave Chinner wrote:
> Right, I've looked at btrees, too, but it's more complex than just
> using an rbtree. I originally looked at using Peter Z's old
> RCU-aware btree code, but it doesn't hold data in the tree leaves.
> So that needed significant modification to make work without a
> memory alloc per extent and that didn't work with original aim of
> RCU-safe extent lookups.  I also looked at that "generic" btree
> stuff that came from logfs, and after a little while ran away
> screaming.

I started with the latter, but it's not really looking like it any more:
there nodes are formatted as a series of u64s instead of all the
long magic, and the data is stored inline - in fact I use a cute
trick to keep the size down, derived from our "compressed" on disk
extent format:

Key:

 +-------+----------------------------+
 | 00:51 | all 52 bits of startoff    |
 | 52:63 | low 12 bits of startblock  |
 +-------+----------------------------+

Value

 +-------+----------------------------+
 | 00:20 | all 21 bits of length      |
 |    21 | unwritten extent bit       |
 | 22:63 | high 42 bits of startblock |
 +-------+----------------------------+

So we only need a 64-bit key and a 64-bit value by abusing parts
of the key to store bits of the startblock.

For non-leaf nodes we iterate through the keys only, never touching
the cache lines for the value.  For the leaf nodes we have to touch
the value anyway because we have to do a range lookup to find the
exact record.

This works fine so far in an isolated simulator, and now I'm ammending
it to be a b+tree with pointers to the previous and next node so
that we can nicely implement our extent iterators instead of doing
full lookups.

> The sticking point, IMO, is the extent array index based lookups in
> all the bmbt code.  I've been looking at converting all that to use
> offset based lookups and a cursor w/ lookup/inc/dec/insert/delete
> ioperations wrapping xfs_iext_lookup_ext() and friends. This means
> the modifications are pretty much identical to the on-disk extent
> btree, so they can be abstracted out into a single extent update
> interface for both trees.  Have you planned/done any cleanup/changes
> with this code?

I've done various cleanups, but I've not yet consolidated the two.
Basically step one at the moment is to move everyone to
xfs_iext_lookup_extent + xfs_iext_get_extent that removes all the
bad intrusion.

Once we move to the actual b+trees the extnum_t cursor will be replaced
with a real cursor structure that contains a pointer to the current
b+tree leaf node, and an index inside that, which will allows us very
efficient iteration.  The xfs_iext_get_extent calls will be replaced
with more specific xfs_iext_prev_extent, xfs_iext_next_extent calls
that include the now slightly more complex cursor decrement, increment
as well as a new xfs_iext_last_extent helper for the last extent
that we need in a few places.

insert/delete remain very similar to what they do right now, they'll
get a different cursor type, and the manual xfs_iext_add calls will
go away.  The new xfs_iext_update_extent helper I posted to the list
yesterday will become a bit more complex, as changing the startoff
will have to be propagated up the tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

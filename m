Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 839EB6B006C
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:33:52 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so15848358pdb.7
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 17:33:52 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id sm4si2993308pab.151.2015.03.03.17.33.50
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 17:33:51 -0800 (PST)
Date: Wed, 4 Mar 2015 12:33:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150304013346.GP18360@dastard>
References: <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F42FEA.1020404@suse.cz>
 <20150302223154.GJ18360@dastard>
 <54F57B20.3090803@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F57B20.3090803@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Tue, Mar 03, 2015 at 10:13:04AM +0100, Vlastimil Babka wrote:
> On 03/02/2015 11:31 PM, Dave Chinner wrote:
> > On Mon, Mar 02, 2015 at 10:39:54AM +0100, Vlastimil Babka wrote:
> > 
> > /*
> >  * In a write transaction we can allocate a maximum of 2
> >  * extents.  This gives:
> >  *    the inode getting the new extents: inode size
> >  *    the inode's bmap btree: max depth * block size
> >  *    the agfs of the ags from which the extents are allocated: 2 * sector
> >  *    the superblock free block counter: sector size
> >  *    the allocation btrees: 2 exts * 2 trees * (2 * max depth - 1) * block size
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.....
> Thanks, that example did help me understand your position much better.
> So you would need to reserve for a worst case number of the objects you modify,
> plus some slack for the demand-paged objects that you need to temporarily
> access, before you can drop and reclaim them (I suppose that in some of the tree
> operations, you need to be holding references to e.g. two nodes at a time, or
> maybe the full depth). Or maybe since all these temporary objects are
> potentially modifiable, it's already accounted for in the "might be modified" part.

Already accounted for in the "might be modified path".

> >> Can you at least at some later point in transaction recognize that
> >> "OK, this object was not permanent after all" and tell mm that it
> >> can lower your reserve?
> > 
> > I'm not including any memory used by objects we know won't be locked
> > into the transaction in the reserve. Demand paged object memory is
> > essentially unbound but is easily reclaimable. That reclaim will
> > give us forward progress guarantees on the memory required here.
> > 
> >> >Yes, that's the big problem with preallocation, as well as your
> >> >proposed "depelete the reserved memory first" approach. They
> >> >*require* up front "preallocation" of free memory, either directly
> >> >by the application, or internally by the mm subsystem.
> >> 
> >> I don't see why it would deadlock, if during reserve time the mm can
> >> return ENOMEM as the reserver should be able to back out at that
> >> point.
> > 
> > Preallocated reserves do not allow for unbound demand paging of
> > reclaimable objects within reserved allocation contexts.
> 
> OK I think I get the point now.
> 
> So, lots of the concerns by me and others were about the wasted memory due to
> reservations, and increased pressure on the rest of the system. I was thinking,
> are you able, at the beginning of the transaction (for this purposes, I think of
> transaction as the work that starts with the memory reservation, then it cannot
> rollback and relies on the reserves, until it commits and frees the memory),
> determine whether the transaction cannot be blocked in its progress by any other
> transaction, and the only thing that would block it would be inability to
> allocate memory during its course?

No. e.g. any transaction that requires allocation or freeing of an
inode or extent can get stuck behind any other transaction that is
allocating/freeing and inode/extent. And this will happen when
holding inode locks, which means other transactions on that inode
will then get stuck on the inode lock, and so on. Blocking
dependencies within transactions are everywhere and cannot be
avoided.

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

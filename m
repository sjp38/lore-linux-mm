Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 876706B0355
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 16:39:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b1so326767948pgc.5
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 13:39:07 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id t76si23851065pgc.18.2016.12.20.13.39.05
        for <linux-mm@kvack.org>;
        Tue, 20 Dec 2016 13:39:06 -0800 (PST)
Date: Wed, 21 Dec 2016 08:39:01 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/9] xfs: introduce and use KM_NOLOCKDEP to silence
 reclaim lockdep false positives
Message-ID: <20161220213901.GQ4326@dastard>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-3-mhocko@kernel.org>
 <20161219212413.GN4326@dastard>
 <20161219220619.GA7296@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219220619.GA7296@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Dec 19, 2016 at 02:06:19PM -0800, Darrick J. Wong wrote:
> On Tue, Dec 20, 2016 at 08:24:13AM +1100, Dave Chinner wrote:
> > On Thu, Dec 15, 2016 at 03:07:08PM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > Now that the page allocator offers __GFP_NOLOCKDEP let's introduce
> > > KM_NOLOCKDEP alias for the xfs allocation APIs. While we are at it
> > > also change KM_NOFS users introduced by b17cb364dbbb ("xfs: fix missing
> > > KM_NOFS tags to keep lockdep happy") and use the new flag for them
> > > instead. There is really no reason to make these allocations contexts
> > > weaker just because of the lockdep which even might not be enabled
> > > in most cases.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > I'd suggest that it might be better to drop this patch for now -
> > it's not necessary for the context flag changeover but does
> > introduce a risk of regressions if the conversion is wrong.
> 
> I was just about to write in that while I didn't see anything obviously
> wrong with the NOFS removals, I also don't know for sure that we can't
> end up recursively in those code paths (specifically the directory
> traversal thing).

The issue is with code paths that can be called from both inside and
outside transaction context - lockdep complains when it sees an
allocation path that is used with both GFP_NOFS and GFP_KERNEL
context, as it doesn't know that the GFP_KERNEL usage is safe or
not.

So things like the directory buffer path, which can be called from
readdir without a transaction context, have various KM_NOFS flags
scattered through it so that lockdep doesn't get all upset every
time readdir is called...

There are other cases like this - btree manipulation via bunmapi()
can be called without transaction context to remove delayed alloc
extents, and that puts all of the btree cursor and  incore extent
list handling in the same boat (all those allocations are KM_NOFS),
etc.

So it's not really recursion that is the problem here - it's
different allocation contexts that lockdep can't know about unless
it's told about them. We've done that with KM_NOFS in the past; in
future we should use this KM_NOLOCKDEP flag, though I'd prefer a
better name for it. e.g. KM_NOTRANS to indicate that the allocation
can occur both inside and outside of transaction context....

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

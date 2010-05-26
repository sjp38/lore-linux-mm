Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B28B6B01B6
	for <linux-mm@kvack.org>; Wed, 26 May 2010 19:01:38 -0400 (EDT)
Date: Thu, 27 May 2010 09:01:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/5] inode: Make unused inode LRU per superblock
Message-ID: <20100526230129.GA1395@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-2-git-send-email-david@fromorbit.com>
 <20100526161732.GC22536@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100526161732.GC22536@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 02:17:33AM +1000, Nick Piggin wrote:
> On Tue, May 25, 2010 at 06:53:04PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > The inode unused list is currently a global LRU. This does not match
> > the other global filesystem cache - the dentry cache - which uses
> > per-superblock LRU lists. Hence we have related filesystem object
> > types using different LRU reclaimatin schemes.
> 
> Is this an improvement I wonder? The dcache is using per sb lists
> because it specifically requires sb traversal.

Right - I originally implemented the per-sb dentry lists for
scalability purposes. i.e. to avoid monopolising the dentry_lock
during unmount looking for dentries on a specific sb and hanging the
system for several minutes.

However, the reason for doing this to the inode cache is not for
scalability, it's because we have a tight relationship between the
dentry and inode cacheN?. That is, reclaim from the dentry LRU grows
the inode LRU.  Like the registration of the shrinkers, this is kind
of an implicit, undocumented behavour of the current shrinker
implemenation.

What this patch series does is take that implicit relationship and
make it explicit.  It also allows other filesystem caches to tie
into the relationship if they need to (e.g. the XFS inode cache).
What it _doesn't do_ is change the macro level behaviour of the
shrinkers...

> What allocation/reclaim really wants (for good scalability and NUMA
> characteristics) is per-zone lists for these things. It's easy to
> convert a single list into per-zone lists.
>
> It is much harder to convert per-sb lists into per-sb x per-zone lists.

No it's not. Just convert the s_{dentry,inode}_lru lists on each
superblock and call the shrinker with a new zone mask field to pick
the correct LRU. That's no harder than converting a global LRU.
Anyway, you'd still have to do per-sb x per-zone lists for the dentry LRUs,
so changing the inode cache to per-sb makes no difference.

However, this is a moot point because we don't have per-zone shrinker
interfaces. That's an entirely separate discussion because of the
macro-level behavioural changes it implies....

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

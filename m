Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C430C6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 21:40:27 -0400 (EDT)
Date: Sat, 4 Jun 2011 11:40:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 06/12] inode: Make unused inode LRU per superblock
Message-ID: <20110604014013.GC561@dastard>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-7-git-send-email-david@fromorbit.com>
 <20110604002552.GU11521@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110604002552.GU11521@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Sat, Jun 04, 2011 at 01:25:52AM +0100, Al Viro wrote:
> On Thu, Jun 02, 2011 at 05:01:01PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > The inode unused list is currently a global LRU. This does not match
> > the other global filesystem cache - the dentry cache - which uses
> > per-superblock LRU lists. Hence we have related filesystem object
> > types using different LRU reclaimation schemes.
> > 
> > To enable a per-superblock filesystem cache shrinker, both of these
> > caches need to have per-sb unused object LRU lists. Hence this patch
> > converts the global inode LRU to per-sb LRUs.
> > 
> > The patch only does rudimentary per-sb propotioning in the shrinker
> > infrastructure, as this gets removed when the per-sb shrinker
> > callouts are introduced later on.
> 
> What protects s_nr_inodes_unused?

For this patch, the modifications are protected by the
inode_lru_lock, but the reads are unprotected. That's the same
protection as the inode_stat.nr_unused field, and the same as the
existing dentry cache per-sb LRU accounting.  In the next patch
modifcations are moved under the sb->s_inode_lru_lock, but reads
still remain unprotected.

I can see how the multiple reads in shrink_icache_sb() could each
return a different value during the proportioning, but I don't think
that is a big problem. That proportioning code goes away in the next
patch and is replaced by different code in prune_super(), so if you
want the reads protected by locks or a single snapshot used for the
proportioning calculations I'll do it in the new code in
prune_super().

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

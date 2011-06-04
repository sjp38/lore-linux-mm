Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 521326B007B
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 21:52:21 -0400 (EDT)
Date: Sat, 4 Jun 2011 11:52:12 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 08/12] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20110604015212.GD561@dastard>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-9-git-send-email-david@fromorbit.com>
 <20110604004231.GV11521@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110604004231.GV11521@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Sat, Jun 04, 2011 at 01:42:31AM +0100, Al Viro wrote:
> > @@ -278,7 +325,12 @@ void generic_shutdown_super(struct super_block *sb)
> >  {
> >  	const struct super_operations *sop = sb->s_op;
> >  
> > -
> > +	/*
> > +	 * shut down the shrinker first so we know that there are no possible
> > +	 * races when shrinking the dcache or icache. Removes the need for
> > +	 * external locking to prevent such races.
> > +	 */
> > +	unregister_shrinker(&sb->s_shrink);
> >  	if (sb->s_root) {
> >  		shrink_dcache_for_umount(sb);
> >  		sync_filesystem(sb);
> 
> What it means is that shrinker_rwsem now nests inside ->s_umount...  IOW,
> if any ->shrink() gets stuck, so does every generic_shutdown_super().
> I'm still not convinced it's a good idea - especially since _this_
> superblock will be skipped anyway.

True, that's not nice.

> Is there any good reason to evict
> shrinker that early?

I wanted to put it early on in the unmount path so that the shrinker
was guaranteed to be gone before evict_inodes() was called. That
would mean that it is obviously safe to remove the iprune_sem
serialisation in that function.

The code in the umount path is quite different between 2.6.35 (the
original version of the patchset) and 3.0-rc1, so I'm not surprised
that I haven't put the unregister call in the right place.

> Note that doing that after ->s_umount is dropped
> should be reasonably safe - your shrinker will see that superblock is
> doomed if it's called anywhere in that window...

Agreed. In trying to find the best "early" place to unregister the
shrinker, I've completely missed the obvious "late is safe"
solution. I'll respin it with these changes.

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

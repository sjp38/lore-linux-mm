Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 053776B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 20:42:35 -0400 (EDT)
Date: Sat, 4 Jun 2011 01:42:31 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 08/12] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20110604004231.GV11521@ZenIV.linux.org.uk>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-9-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306998067-27659-9-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

> @@ -278,7 +325,12 @@ void generic_shutdown_super(struct super_block *sb)
>  {
>  	const struct super_operations *sop = sb->s_op;
>  
> -
> +	/*
> +	 * shut down the shrinker first so we know that there are no possible
> +	 * races when shrinking the dcache or icache. Removes the need for
> +	 * external locking to prevent such races.
> +	 */
> +	unregister_shrinker(&sb->s_shrink);
>  	if (sb->s_root) {
>  		shrink_dcache_for_umount(sb);
>  		sync_filesystem(sb);

What it means is that shrinker_rwsem now nests inside ->s_umount...  IOW,
if any ->shrink() gets stuck, so does every generic_shutdown_super().
I'm still not convinced it's a good idea - especially since _this_
superblock will be skipped anyway.  Is there any good reason to evict
shrinker that early?  Note that doing that after ->s_umount is dropped
should be reasonably safe - your shrinker will see that superblock is
doomed if it's called anywhere in that window...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

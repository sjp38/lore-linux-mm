Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 154226B00F3
	for <linux-mm@kvack.org>; Sat,  4 Jun 2011 10:24:53 -0400 (EDT)
Date: Sat, 4 Jun 2011 15:24:48 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 08/12] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20110604142448.GX11521@ZenIV.linux.org.uk>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-9-git-send-email-david@fromorbit.com>
 <20110604004231.GV11521@ZenIV.linux.org.uk>
 <20110604015212.GD561@dastard>
 <20110604140848.GA20404@infradead.org>
 <20110604141940.GW11521@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110604141940.GW11521@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Sat, Jun 04, 2011 at 03:19:40PM +0100, Al Viro wrote:
> > The iprune_sem removal is fine as soon as you have a per-sb shrinker
> > for the inodes which keeps an active reference on the superblock until
> > all the inodes are evicted.
> 
> I really don't like that.  Stuff keeping active refs, worse yet doing that
> asynchronously...  Shrinkers should *not* do that.  Just grab a passive
> ref (i.e. bump s_count), try grab s_umount (shared) and if that thing still
> has ->s_root while we hold s_umount, go ahead.  Unregister either at the
> end of generic_shutdown_super() or from deactivate_locked_super(), between
> the calls of ->kill_sb() and put_filesystem().

PS: shrinkers should not acquire active refs; more specifically, they should
not _drop_ active refs, lest they end up dropping the last active one and
trigger unregistering a shrinker for superblock in question.  From inside of
->shrink(), with shrinker_rwsem held by caller.  Deadlock...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

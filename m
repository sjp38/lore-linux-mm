Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 921556B00EE
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 04:19:27 -0400 (EDT)
Date: Mon, 25 Jul 2011 09:19:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/8] xfs: Warn if direct reclaim tries to writeback pages
Message-ID: <20110725081918.GZ5349@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-3-git-send-email-mgorman@suse.de>
 <20110724113200.GA26332@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110724113200.GA26332@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <jweiner@redhat.com>

On Sun, Jul 24, 2011 at 07:32:00AM -0400, Christoph Hellwig wrote:
> On Thu, Jul 21, 2011 at 05:28:44PM +0100, Mel Gorman wrote:
> > --- a/fs/xfs/linux-2.6/xfs_aops.c
> > +++ b/fs/xfs/linux-2.6/xfs_aops.c
> > @@ -930,12 +930,13 @@ xfs_vm_writepage(
> >  	 * random callers for direct reclaim or memcg reclaim.  We explicitly
> >  	 * allow reclaim from kswapd as the stack usage there is relatively low.
> >  	 *
> > -	 * This should really be done by the core VM, but until that happens
> > -	 * filesystems like XFS, btrfs and ext4 have to take care of this
> > -	 * by themselves.
> > +	 * This should never happen except in the case of a VM regression so
> > +	 * warn about it.
> >  	 */
> > -	if ((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC)
> > +	if ((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC) {
> > +		WARN_ON_ONCE(1);
> >  		goto redirty;
> 
> The nicer way to write this is
> 
> 	if (WARN_ON(current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC)
> 		goto redirty;
> 

I wanted to avoid side effects if WARN_ON was compiled out similar to
the care that is normally taken for BUG_ON but it's unnecessary and
your version is far tidier. Do you really want WARN_ON used instead
of WARN_ON_ONCE()?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

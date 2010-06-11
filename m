Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A531A6B01D9
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 12:29:17 -0400 (EDT)
Date: Fri, 11 Jun 2010 12:29:12 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100611162912.GC24707@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100608090811.GA5949@infradead.org>
 <20100608092814.GB27717@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100608092814.GB27717@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 08, 2010 at 10:28:14AM +0100, Mel Gorman wrote:
> >  - we also need to care about ->releasepage.  At least for XFS it
> >    can end up in the same deep allocator chain as ->writepage because
> >    it does all the extent state conversions, even if it doesn't
> >    start I/O. 
> 
> Dang.
> 
> >    I haven't managed yet to decode the ext4/btrfs codepaths
> >    for ->releasepage yet to figure out how they release a page that
> >    covers a delayed allocated or unwritten range.
> > 
> 
> If ext4/btrfs are also very deep call-chains and this series is going more
> or less the right direction, then avoiding calling ->releasepage from direct
> reclaim is one, somewhat unfortunate, option. The second is to avoid it on
> a per-filesystem basis for direct reclaim using PF_MEMALLOC to detect
> reclaimers and PF_KSWAPD to tell the difference between direct
> reclaimers and kswapd.

I went throught this a bit more and I can't actually hit that code in
XFS ->releasepage anymore.  I've also audited the caller and can't see
how we could theoretically hit it anymore.  Do the VM gurus know a case
where we would call ->releasepage on a page that's actually dirty and
hasn't been through block_invalidatepage before?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

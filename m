Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1C0E26B01B0
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 03:57:31 -0400 (EDT)
Date: Wed, 16 Jun 2010 17:57:23 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100616075723.GT6138@laptop>
References: <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615152526.GA3468@infradead.org>
 <20100615154516.GG28052@random.random>
 <20100615162600.GA9910@infradead.org>
 <4C17AF2D.2060904@redhat.com>
 <20100615165423.GA16868@infradead.org>
 <4C17D0C5.9030203@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C17D0C5.9030203@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 03:13:09PM -0400, Rik van Riel wrote:
> On 06/15/2010 12:54 PM, Christoph Hellwig wrote:
> >On Tue, Jun 15, 2010 at 12:49:49PM -0400, Rik van Riel wrote:
> >>This is already in a filesystem.  Why does ->writepage get
> >>called a second time?  Shouldn't this have a gfp_mask
> >>without __GFP_FS set?
> >
> >Why would it?  GFP_NOFS is not for all filesystem code, but only for
> >code where we can't re-enter the filesystem due to deadlock potential.
> 
> Why?   How about because you know the stack is not big enough
> to have the XFS call path on it twice? :)
> 
> Isn't the whole purpose of this patch series to prevent writepage
> from being called by the VM, when invoked from a deep callstack
> like xfs writepage?
> 
> That sounds a lot like simply wanting to not have GFP_FS...

buffered write path uses __GFP_FS by design because huge amounts
of (dirty) memory can be allocated in doing pagecache writes. If
would be nasty if that was not allowed to wait for filesystem
activity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

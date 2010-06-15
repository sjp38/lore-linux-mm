Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C0A1B6B025F
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:17:39 -0400 (EDT)
Date: Tue, 15 Jun 2010 15:17:16 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615191716.GA6778@infradead.org>
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
Cc: Christoph Hellwig <hch@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 03:13:09PM -0400, Rik van Riel wrote:
> Why?   How about because you know the stack is not big enough
> to have the XFS call path on it twice? :)
> 
> Isn't the whole purpose of this patch series to prevent writepage
> from being called by the VM, when invoked from a deep callstack
> like xfs writepage?

It's not invoked from xfs writepage, but from xfs_file_aio_write via
generic_file_buffered_write.  Which isn't actually an all that deep
callstack, just en example of one that's alread bad enough to overflow
the stack.

> That sounds a lot like simply wanting to not have GFP_FS...

There's no point in sprinkling random GFP_NOFS flags.  It's not just
the filesystem code that uses a lot of stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

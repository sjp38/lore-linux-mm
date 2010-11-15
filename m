Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C55368D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 15:55:04 -0500 (EST)
Date: Mon, 15 Nov 2010 15:54:51 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Oops while rebalancing, now unmountable.
Message-ID: <20101115205451.GA644@infradead.org>
References: <1289310046-sup-839@think>
 <1289326892.4231.2.camel@mars>
 <1289764507.4303.9.camel@mars>
 <20101114204206.GV6809@random.random>
 <20101114220018.GA4512@infradead.org>
 <20101114221222.GX6809@random.random>
 <20101115182314.GA2493@infradead.org>
 <20101115184657.GJ6809@random.random>
 <20101115191204.GB11374@infradead.org>
 <20101115192914.GL6809@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101115192914.GL6809@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 08:29:14PM +0100, Andrea Arcangeli wrote:
> Scary stuff, so WB_SYNC_NONE wouldn't submit the dirty part of the
> page down for I/O, so that it's all clean after wait_on_page_writeback
> returns? (well of course unless the dirty bit was set again)

It might not if we have lock contention or other resource starvation.
That's the reason why WB_SYNC_NONE was added - to not block the flusher
threads.

> I didn't realize the stack overflow issue was specific to delalloc.

It's not.  It's specific to direct reclaim.  Only ext4 special cases
delalloc, but I'm not sure if that's intentional or just an accidental
side effect of the mess that the ext4 writeback code is.

> In short with THP it's khugepaged that is supposed to run the
> ->writepage in migrate.c and it will run it once every 10 sec even
> when it fails (and not in a 100% cpu wasting loop like kswapd), so if
> you did something magic for kswapd in XFS you should do for khugepaged
> too.

If you have a PF_ flag for it that's easy to add once it goes into
mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C54D6B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 12:12:36 -0500 (EST)
Date: Wed, 18 Nov 2009 18:12:32 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: unconditional discard calls in the swap code
Message-ID: <20091118171232.GB25541@lst.de>
References: <20091030065102.GA2896@lst.de> <Pine.LNX.4.64.0910301629030.4106@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0910301629030.4106@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 30, 2009 at 05:26:18PM +0000, Hugh Dickins wrote:
> Yes, in practice TRIM seems a huge disappointment: is there a device on
> which it is really implemented, and not more trouble than it's worth?
> 
> I'd been waiting for OCZ to get a Vertex 1.4* firmware out of Beta
> before looking at swap discard again; but even then, the Linux ATA
> support is still up in the air, so far as I know.

I've tied it up now for libata, and testing with the releases OCZ 1.4
firmware.  Haven't tested anything else yet except for my own
implementations of TRIM and WRITE SAME in qemu which are a lot faster
than real hardware.

> 
> You don't mention swap's discard of the whole partition (or all
> extents of the swapfile) at swapon time: do you believe that usage
> is okay to retain?  Is it likely on some devices to take so long,
> that I ought to make it asynchronous?

The use on swapon seems fine - we've also added support to discard
on mkfs which is generally fast enough - the existing implementations
seem to have mostly constant overhead, the more blocks your discard,
the better.

> Assuming that initial swap discard is good, I wonder whether just
> to revert the discard of swap clusters for now: until such time as
> we find devices (other than mtd) that can implement it efficiently.
> 
> If we do retain the discard of swap clusters, under something more
> than an #if 0, any ideas for what I should make it conditional upon?

add a sysctl / sysfs tunable for it?  For all filesystems we now have
patches pending to require and -o discard option to use it, which will
be quite nessecary for 2.6.33 where all the block layer / scsi layer /
libata support will fall into place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0686B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:31:00 -0400 (EDT)
Subject: Re: [PATCH 2/7] writeback: switch to per-bdi threads for flushing
 data
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090316102253.GB9510@infradead.org>
References: <1236868428-20408-1-git-send-email-jens.axboe@oracle.com>
	 <1236868428-20408-3-git-send-email-jens.axboe@oracle.com>
	 <20090316102253.GB9510@infradead.org>
Content-Type: text/plain
Date: Mon, 16 Mar 2009 09:30:14 -0400
Message-Id: <1237210214.30224.3.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, david@fromorbit.com, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-03-16 at 06:22 -0400, Christoph Hellwig wrote:
> On Thu, Mar 12, 2009 at 03:33:43PM +0100, Jens Axboe wrote:
> > +static void bdi_kupdated(struct backing_dev_info *bdi)
> > +{
> > +	long nr_to_write;
> > +	struct writeback_control wbc = {
> > +		.bdi		= bdi,
> > +		.sync_mode	= WB_SYNC_NONE,
> > +		.nr_to_write	= 0,
> > +		.for_kupdate	= 1,
> > +		.range_cyclic	= 1,
> > +	};
> > +
> > +	sync_supers();
> 
> Not directly related to your patch, but can someone explain WTF
> sync_supers is doing here or in the old kupdated?  We're writing back
> dirty pages from the VM, and for some reason we try to also write back
> superblocks.   This doesn't really make any sense.

Some of our poor filesystem cousins don't write the super until kupdate
kicks them (see ext2_write_super).  kupdate has always been the periodic
FS thread of last resort.

-chris




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C64726B0037
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 21:36:40 -0400 (EDT)
Date: Thu, 28 Mar 2013 10:36:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: remove swapcache page early
Message-ID: <20130328013637.GD22908@blaptop>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <51532A0F.3010402@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51532A0F.3010402@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>

Hi Seth,

On Wed, Mar 27, 2013 at 12:19:11PM -0500, Seth Jennings wrote:
> On 03/26/2013 09:22 PM, Minchan Kim wrote:
> > Swap subsystem does lazy swap slot free with expecting the page
> > would be swapped out again so we can't avoid unnecessary write.
> > 
> > But the problem in in-memory swap is that it consumes memory space
> > until vm_swap_full(ie, used half of all of swap device) condition
> > meet. It could be bad if we use multiple swap device, small in-memory swap
> > and big storage swap or in-memory swap alone.
> > 
> > This patch changes vm_swap_full logic slightly so it could free
> > swap slot early if the backed device is really fast.
> 
> Great idea!

Thanks!

> 
> > For it, I used SWP_SOLIDSTATE but It might be controversial.
> 
> The comment for SWP_SOLIDSTATE is that "blkdev seeks are cheap". Just
> because seeks are cheap doesn't mean the read itself is also cheap.

The "read" isn't not concern but "write".

> For example, QUEUE_FLAG_NONROT is set for mmc devices, but some of
> them can be pretty slow.

Yeb.

> 
> > So let's add Ccing Shaohua and Hugh.
> > If it's a problem for SSD, I'd like to create new type SWP_INMEMORY
> > or something for z* family.
> 
> Afaict, setting SWP_SOLIDSTATE depends on characteristics of the
> underlying block device (i.e. blk_queue_nonrot()).  zram is a block
> device but zcache and zswap are not.
> 
> Any idea by what criteria SWP_INMEMORY would be set?

Just in-memory swap, zram, zswap and zcache at the moment. :)

> 
> Also, frontswap backends (zcache and zswap) are a caching layer on top
> of the real swap device, which might actually be rotating media.  So
> you have the issue of to different characteristics, in-memory caching
> on top of rotation media, present in a single swap device.

Please read my patch completely. I already pointed out the problem and
Hugh and Dan are suggesting ideas.

Thanks!

> 
> Thanks,
> Seth
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

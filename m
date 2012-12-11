Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8179F6B0074
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 01:26:04 -0500 (EST)
Date: Tue, 11 Dec 2012 15:26:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram /proc/swaps accounting weirdness
Message-ID: <20121211062601.GD22698@blaptop>
References: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org

Hi Dan,

On Fri, Dec 07, 2012 at 03:57:08PM -0800, Dan Magenheimer wrote:
> While playing around with zcache+zram (see separate thread),
> I was watching stats with "watch -d".
> 
> It appears from the code that /sys/block/num_writes only
> increases, never decreases.  In my test, num_writes got up

Never decreasement is natural.

> to 1863.  /sys/block/disksize is 104857600.
> 
> I have two swap disks, one zram (pri=60), one real (pri=-1),
> and as a I watched /proc/swaps, the "Used" field grew rapidly
> and reached the Size (102396k) of the zram swap, and then
> the second swap disk (a physical disk partition) started being
> used.  Then for awhile, the Used field for both swap devices
> was changing (up and down).
> 
> Can you explain how this could happen if num_writes never
> exceeded 1863?  This may be harmless in the case where

Odd.
I tried to reproduce it with zram and real swap device without
zcache but failed. Does the problem happen only if enabling zcache
together? 

> the only swap on the system is zram; or may indicate a bug
> somewhere?

> 
> It looks like num_writes is counting bio's not pages...
> which would imply the bio's are potentially quite large
> (and I'll guess they are of size SWAPFILE_CLUSTER which is
> defined to be 256).  Do large clusters make sense with zram?

Swap_writepage handles a page and zram_make_request doesn't use
pluging mechanism of block I/O. So every request for swap-over-zram
is a bio and a page. So your problem might be a BUG.

> 
> Late on a Friday so sorry if I am incomprehensible...
> 
> P.S. The corresponding stat for zcache indicates that
> it failed 8852 stores, so I would have expected zram
> to deal with no more than 8852 compressions.
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

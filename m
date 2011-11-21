Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CCD786B0073
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 09:46:22 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/8] block: limit default readahead size for small devices
References: <20111121091819.394895091@intel.com>
	<20111121093846.121502745@intel.com>
Date: Mon, 21 Nov 2011 09:46:10 -0500
In-Reply-To: <20111121093846.121502745@intel.com> (Wu Fengguang's message of
	"Mon, 21 Nov 2011 17:18:20 +0800")
Message-ID: <x49bos5fs99.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Li Shaohua <shaohua.li@intel.com>, Clemens Ladisch <clemens@ladisch.de>, Jens Axboe <jens.axboe@oracle.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

Wu Fengguang <fengguang.wu@intel.com> writes:

> Linus reports a _really_ small & slow (505kB, 15kB/s) USB device,
> on which blkid runs unpleasantly slow. He manages to optimize the blkid
> reads down to 1kB+16kB, but still kernel read-ahead turns it into 48kB.
>
>      lseek 0,    read 1024   => readahead 4 pages (start of file)
>      lseek 1536, read 16384  => readahead 8 pages (page contiguous)
>
> The readahead heuristics involved here are reasonable ones in general.
> So it's good to fix blkid with fadvise(RANDOM), as Linus already did.
>
> For the kernel part, Linus suggests:
>   So maybe we could be less aggressive about read-ahead when the size of
>   the device is small? Turning a 16kB read into a 64kB one is a big deal,
>   when it's about 15% of the whole device!
>
> This looks reasonable: smaller device tend to be slower (USB sticks as
> well as micro/mobile/old hard disks).
>
> Given that the non-rotational attribute is not always reported, we can
> take disk size as a max readahead size hint. This patch uses a formula
> that generates the following concrete limits:
>
>         disk size    readahead size
>      (scale by 4)      (scale by 2)
>                1M                8k
>                4M               16k
>               16M               32k
>               64M               64k
>              256M              128k
>         --------------------------- (*)
>                1G              256k
>                4G              512k
>               16G             1024k
>               64G             2048k
>              256G             4096k
>
> (*) Since the default readahead size is 128k, this limit only takes
> effect for devices whose size is less than 256M.

Scaling readahead by the size of the device may make sense up to a
point.  But really, that shouldn't be the only factor considered.  Just
because you have a big disk, it doesn't mean it's fast, and it sure
doesn't mean that you should waste memory with readahead data that may
not be used before it's evicted (whether due to readahead on data that
isn't needed or thrashing of the page cache).

So, I think reducing the readahead size for smaller devices is fine.
I'm not a big fan of going the other way.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

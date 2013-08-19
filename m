Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 217A16B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 13:46:45 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 19 Aug 2013 13:46:44 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2097638C8059
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 13:46:39 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7JHkekM203456
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 13:46:40 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7JHkcXZ005431
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 14:46:40 -0300
Date: Mon, 19 Aug 2013 12:46:34 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] mm: zswap: create a pseudo device /dev/zram0
Message-ID: <20130819174634.GB5703@variantweb.net>
References: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
 <1376815249-6611-5-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376815249-6611-5-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, eternaleye@gmail.com, minchan@kernel.org, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org, Bob Liu <bob.liu@oracle.com>

On Sun, Aug 18, 2013 at 04:40:49PM +0800, Bob Liu wrote:
> This is used to replace previous zram.
> zram users can enable this feature, then a pseudo device will be created
> automaticlly after kernel boot.
> Just using "mkswp /dev/zram0; swapon /dev/zram0" to use it as a swap disk.
> 
> The size of this pseudeo is controlled by zswap boot parameter
> zswap.max_pool_percent.
> disksize = (totalram_pages * zswap.max_pool_percent/100)*PAGE_SIZE.

This /dev/zram0 will behave nothing like the block device that zram
creates.  It only allows reads/writes to the first PAGE_SIZE area of the
device, for mkswap to work, and then doesn't do anything for all other
accesses.

I guess if you disabled zswap writeback, then... it would somewhat be
the same thing.  We do need to disable zswap writeback in this case so
that zswap does decompressed a ton of pages into the swapcache for
writebacks that will just fail.  Since zsmalloc does not yet support the
reclaim functionality, zswap writeback is implicitly disabled.

But this is really weird conceptually since zswap is a caching layer
that uses frontswap.  If a frontswap store fails, it will try to send
the page to the zram0 device which will fail the write.  Then the page
will be... put back on the active or inactive list?

Also, using the max_pool_percent in calculating the psuedo-device size
isn't right.  Right now, the code makes the device the max size of the
_compressed_ pool, but the underlying swap device size is in
_uncompressed_ pages. So you'll never be able to fill zswap sizing the
device like this, unless every page is highly incompressible to the
point that each compressed page effectively uses a memory pool page, in
which case, the user shouldn't be using memory compression.

This also means that this hasn't been tested in the zswap pool-is-full
case since there is no way, in this code, to hit that case.

In the zbud case the expected compression is 2:1 so you could just
multiply the compressed pool size by 2 and get a good psuedo-device
size.  With zsmalloc the expected compression is harder to determine
since it can achieve very high effective compression ratios on highly
compressible pages.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

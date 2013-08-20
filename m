Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 2B4A46B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 22:04:12 -0400 (EDT)
Message-ID: <5212CE61.2090600@oracle.com>
Date: Tue, 20 Aug 2013 10:03:13 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: zswap: create a pseudo device /dev/zram0
References: <1376815249-6611-1-git-send-email-bob.liu@oracle.com> <1376815249-6611-5-git-send-email-bob.liu@oracle.com> <20130819174634.GB5703@variantweb.net>
In-Reply-To: <20130819174634.GB5703@variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eternaleye@gmail.com, minchan@kernel.org, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org


On 08/20/2013 01:46 AM, Seth Jennings wrote:
> On Sun, Aug 18, 2013 at 04:40:49PM +0800, Bob Liu wrote:
>> This is used to replace previous zram.
>> zram users can enable this feature, then a pseudo device will be created
>> automaticlly after kernel boot.
>> Just using "mkswp /dev/zram0; swapon /dev/zram0" to use it as a swap disk.
>>
>> The size of this pseudeo is controlled by zswap boot parameter
>> zswap.max_pool_percent.
>> disksize = (totalram_pages * zswap.max_pool_percent/100)*PAGE_SIZE.
> 
> This /dev/zram0 will behave nothing like the block device that zram
> creates.  It only allows reads/writes to the first PAGE_SIZE area of the
> device, for mkswap to work, and then doesn't do anything for all other
> accesses.

Yes, all the other data should be stored in zswap pool and don't need to
go through block layer.

> 
> I guess if you disabled zswap writeback, then... it would somewhat be
> the same thing.  We do need to disable zswap writeback in this case so
> that zswap does decompressed a ton of pages into the swapcache for
> writebacks that will just fail.  Since zsmalloc does not yet support the
> reclaim functionality, zswap writeback is implicitly disabled.
> 

Yes, ZSWAP_PSEUDO_BLKDEV depends on zsmalloc and if using zsmalloc as
the allocator then the writeback is disabled(not implemented and no
requirement).

> But this is really weird conceptually since zswap is a caching layer
> that uses frontswap.  If a frontswap store fails, it will try to send
> the page to the zram0 device which will fail the write.  Then the page

That's a problem. We should disable sending the page to zram0 if
frontswap store fails. Return fail just like the swap device is full.

> will be... put back on the active or inactive list?
> 
> Also, using the max_pool_percent in calculating the psuedo-device size
> isn't right.  Right now, the code makes the device the max size of the
> _compressed_ pool, but the underlying swap device size is in
> _uncompressed_ pages. So you'll never be able to fill zswap sizing the
> device like this, unless every page is highly incompressible to the
> point that each compressed page effectively uses a memory pool page, in
> which case, the user shouldn't be using memory compression.
> 
> This also means that this hasn't been tested in the zswap pool-is-full
> case since there is no way, in this code, to hit that case.

Yes, but in my understanding there is no need to trigger this path. It's
the same with zram. Eg. create /dev/zram0 with disksize(eg. 100M), then
mm-core will store ~100M uncompressed pages to /dev/zram0 at most. But
the real memory spent for storing those pages are depended on the
compression ratio. It's rare that zram will need 100M real memory.

> 
> In the zbud case the expected compression is 2:1 so you could just
> multiply the compressed pool size by 2 and get a good psuedo-device
> size.  With zsmalloc the expected compression is harder to determine
> since it can achieve very high effective compression ratios on highly
> compressible pages.
> 

Some users can know the compression ratio of their workloads even using
zsmalloc.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

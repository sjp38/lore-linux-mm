Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFC66B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 17:38:58 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1586885pab.36
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:38:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qd8si6615259pac.101.2014.05.15.14.38.57
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 14:38:58 -0700 (PDT)
Date: Thu, 15 May 2014 14:38:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] zram: remove global tb_lock with fine grain lock
Message-Id: <20140515143856.58bc6d723fc4aefb6b5ed5c3@linux-foundation.org>
In-Reply-To: <000101cf7013$f646ac30$e2d40490$%yang@samsung.com>
References: <000101cf7013$f646ac30$e2d40490$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Heesub Shin' <heesub.shin@samsung.com>, 'Davidlohr Bueso' <davidlohr@hp.com>, 'Joonsoo Kim' <js1304@gmail.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Thu, 15 May 2014 16:00:47 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

> Currently, we use a rwlock tb_lock to protect concurrent access to
> the whole zram meta table. However, according to the actual access model,
> there is only a small chance for upper user to access the same table[index],
> so the current lock granularity is too big.
> 
> The idea of optimization is to change the lock granularity from whole
> meta table to per table entry (table -> table[index]), so that we can
> protect concurrent access to the same table[index], meanwhile allow
> the maximum concurrency.
> With this in mind, several kinds of locks which could be used as a
> per-entry lock were tested and compared:
> 
> Test environment:
> x86-64 Intel Core2 Q8400, system memory 4GB, Ubuntu 12.04,
> kernel v3.15.0-rc3 as base, zram with 4 max_comp_streams LZO.
> 
> iozone test:
> iozone -t 4 -R -r 16K -s 200M -I +Z
> (1GB zram with ext4 filesystem, take the average of 10 tests, KB/s)
> 
>       Test       base      CAS    spinlock    rwlock   bit_spinlock
> -------------------------------------------------------------------
>  Initial write  1381094   1425435   1422860   1423075   1421521
>        Rewrite  1529479   1641199   1668762   1672855   1654910
>           Read  8468009  11324979  11305569  11117273  10997202
>        Re-read  8467476  11260914  11248059  11145336  10906486
>   Reverse Read  6821393   8106334   8282174   8279195   8109186
>    Stride read  7191093   8994306   9153982   8961224   9004434
>    Random read  7156353   8957932   9167098   8980465   8940476
> Mixed workload  4172747   5680814   5927825   5489578   5972253
>   Random write  1483044   1605588   1594329   1600453   1596010
>         Pwrite  1276644   1303108   1311612   1314228   1300960
>          Pread  4324337   4632869   4618386   4457870   4500166

Did you investigate seqlocks?

> To enhance the possibility of access the same table[index] concurrently,
> set zram a small disksize(10MB) and let threads run with large loop count.
> 
> fio test:
> fio --bs=32k --randrepeat=1 --randseed=100 --refill_buffers
> --scramble_buffers=1 --direct=1 --loops=3000 --numjobs=4
> --filename=/dev/zram0 --name=seq-write --rw=write --stonewall
> --name=seq-read --rw=read --stonewall --name=seq-readwrite
> --rw=rw --stonewall --name=rand-readwrite --rw=randrw --stonewall
> (10MB zram raw block device, take the average of 10 tests, KB/s)
> 
>     Test     base     CAS    spinlock    rwlock  bit_spinlock
> -------------------------------------------------------------
> seq-write   933789   999357   1003298    995961   1001958
>  seq-read  5634130  6577930   6380861   6243912   6230006
>    seq-rw  1405687  1638117   1640256   1633903   1634459
>   rand-rw  1386119  1614664   1617211   1609267   1612471
> 
> All the optimization methods show a higher performance than the base,
> however, it is hard to say which method is the most appropriate.
> 
> On the other hand, zram is mostly used on small embedded system, so we
> don't want to increase any memory footprint.
> 
> This patch pick the bit_spinlock method, pack object size and page_flag
> into an unsigned long table.value, so as to not increase any memory
> overhead on both 32-bit and 64-bit system.

bit_spinlocks are not a particularly good or complete mechanism - they
don't have lockdep support and iirc they are somewhat slow.

So we need a pretty good reason to use them.  How much memory saving
are we expecting here?

> On the third hand, even though different kinds of locks have different
> performances, we can ignore this difference, because:
> if zram is used as zram swapfile, the swap subsystem can prevent concurrent
> access to the same swapslot;
> if zram is used as zram-blk for set up filesystem on it, the upper filesystem
> and the page cache also prevent concurrent access of the same block mostly.
> So we can ignore the different performances among locks.

So do we need any locking at all?

>
> ....
>
>  static void zram_free_page(struct zram *zram, size_t index)
>  {
>  	struct zram_meta *meta = zram->meta;
>  	unsigned long handle = meta->table[index].handle;
> +	int size;
>  
>  	if (unlikely(!handle)) {
>  		/*
>  		 * No memory is allocated for zero filled pages.
>  		 * Simply clear zero page flag.
>  		 */
> -		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
> -			zram_clear_flag(meta, index, ZRAM_ZERO);
> +		if (zram_test_zero(meta, index)) {
> +			zram_clear_zero(meta, index);
>  			atomic64_dec(&zram->stats.zero_pages);

Having these atomic ops in the alloc/free hotpaths must be costing us?

>  		}
>  		return;
>
> ....
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

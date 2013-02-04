Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id D6C986B008C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 16:45:35 -0500 (EST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 4 Feb 2013 14:45:35 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 50B681FF0038
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 14:45:30 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r14LjKdK445984
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 14:45:20 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r14Llfqn011225
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 14:47:42 -0700
Message-ID: <51102BE8.3090301@linux.vnet.ibm.com>
Date: Mon, 04 Feb 2013 15:45:12 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 0/7] zswap: compressed swap caching
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com> <5110287A.5050200@linux.vnet.ibm.com>
In-Reply-To: <5110287A.5050200@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Joe Perches <joe@perches.com>

On 02/04/2013 03:30 PM, Seth Jennings wrote:
> On 01/29/2013 03:40 PM, Seth Jennings wrote:
>> Sorry for the churn but just this set might be easier to review.
>> The code required for the flushing is in a separate patch now
>> as requested.

I've got a large and valuable body of feedback to integrate for v5.
Thanks to all that reviewed/commented!

It will take a little time to compile it all and coordinate with
Minchan and Nitin on the additional documentation and rationale for
zsmalloc.

I just wanted to acknowledge the feedback and state that I'm working
on v5 and I'll get it out as soon as I can.

Thanks,
Seth

>
>>
>> Changelog:
>>
>> v4:
>> * Added Acks (Minchan)
>> * Separated flushing functionality into standalone patch
>>   for easier review (Minchan)
>> * fix comment on zswap enabled attribute (Minchan)
>> * add TODO for dynamic mempool size (Minchan)
>> * and check for NULL in zswap_free_page() (Minchan)
>> * add missing zs_free() in error path (Minchan)
>> * TODO: add comments for flushing/refcounting (Minchan)
>>
>> NOTE: To build, read this:
>> http://lkml.org/lkml/2013/1/28/586
>>
>> v3:
>> * Dropped the zsmalloc patches from the set, except the promotion patch
>>   which has be converted to a rename patch (vs full diff).  The dropped
>>   patches have been Acked and are going into Greg's staging tree soon.
>> * Separated [PATCHv2 7/9] into two patches since it makes changes for two
>>   different reasons (Minchan)
>> * Moved ZSWAP_MAX_OUTSTANDING_FLUSHES near the top in zswap.c (Rik)
>> * Rebase to v3.8-rc5. linux-next is a little volatile with the
>>   swapper_space per type changes which will effect this patchset.
>> * TODO: Move some stats from debugfs to sysfs. Which ones? (Rik)
>>
>> v2:
>> * Rename zswap_fs_* functions to zswap_frontswap_* to avoid
>>   confusion with "filesystem"
>> * Add comment about what the tree lock protects
>> * Remove "#if 0" code (should have been done before)
>> * Break out changes to existing swap code into separate patch
>> * Fix blank line EOF warning on documentation file
>> * Rebase to next-20130107
>>
>> Zswap Overview:
>>
>> Zswap is a lightweight compressed cache for swap pages. It takes
>> pages that are in the process of being swapped out and attempts to
>> compress them into a dynamically allocated RAM-based memory pool.
>> If this process is successful, the writeback to the swap device is
>> deferred and, in many cases, avoided completely.  This results in
>> a significant I/O reduction and performance gains for systems that
>> are swapping.
>>
>> The results of a kernel building benchmark indicate a
>> runtime reduction of 53% and an I/O reduction 76% with zswap vs normal
>> swapping with a kernel build under heavy memory pressure (see
>> Performance section for more).
>>
>> Some addition performance metrics regarding the performance
>> improvements and I/O reductions that can be achieved using zswap as
>> measured by SPECjbb are provided here:
>>
>> http://ibm.co/VCgHvM
>>
>> These results include runs on x86 and new results on Power7+ with
>> hardware compression acceleration.
>>
>> Of particular note is that zswap is able to evict pages from the compressed
>> cache, on an LRU basis, to the backing swap device when the compressed pool
>> reaches it size limit or the pool is unable to obtain additional pages
>> from the buddy allocator.  This eviction functionality had been identified
>> as a requirement in prior community discussions.
>>
>> Patchset Structure:
>> 1:   add atomic_t get/set to debugfs
>> 2:   promote zsmalloc to /lib
>> 3,4: changes to existing swap code for zswap
>> 5,6: add zswap and documentation
>>
>> Rationale:
>>
>> Zswap provides compressed swap caching that basically trades CPU cycles
>> for reduced swap I/O.  This trade-off can result in a significant
>> performance improvement as reads to/writes from to the compressed
>> cache almost always faster that reading from a swap device
>> which incurs the latency of an asynchronous block I/O read.
>>
>> Some potential benefits:
>> * Desktop/laptop users with limited RAM capacities can mitigate the
>>     performance impact of swapping.
>> * Overcommitted guests that share a common I/O resource can
>>     dramatically reduce their swap I/O pressure, avoiding heavy
>>     handed I/O throttling by the hypervisor.  This allows more work
>>     to get done with less impact to the guest workload and guests
>>     sharing the I/O subsystem
>> * Users with SSDs as swap devices can extend the life of the device by
>>     drastically reducing life-shortening writes.
>>
>> Compressed swap is also provided in zcache, along with page cache
>> compression and RAM clustering through RAMSter. Zswap seeks to deliver
>> the benefit of swap  compression to users in a discrete function.
>> This design decision is akin to Unix design philosophy of doing one
>> thing well, it leaves file cache compression and other features
>> for separate code.
>>
>> Design:
>>
>> Zswap receives pages for compression through the Frontswap API and
>> is able to evict pages from its own compressed pool on an LRU basis
>> and write them back to the backing swap device in the case that the
>> compressed pool is full or unable to secure additional pages from
>> the buddy allocator.
>>
>> Zswap makes use of zsmalloc for the managing the compressed memory
>> pool.  This is because zsmalloc is specifically designed to minimize
>> fragmentation on large (> PAGE_SIZE/2) allocation sizes.  Each
>> allocation in zsmalloc is not directly accessible by address.
>> Rather, a handle is return by the allocation routine and that handle
>> must be mapped before being accessed.  The compressed memory pool grows
>> on demand and shrinks as compressed pages are freed.  The pool is
>> not preallocated.
>>
>> When a swap page is passed from frontswap to zswap, zswap maintains
>> a mapping of the swap entry, a combination of the swap type and swap
>> offset, to the zsmalloc handle that references that compressed swap
>> page.  This mapping is achieved with a red-black tree per swap type.
>> The swap offset is the search key for the tree nodes.
>>
>> Zswap seeks to be simple in its policies.  Sysfs attributes allow for
>> two user controlled policies:
>> * max_compression_ratio - Maximum compression ratio, as as percentage,
>>     for an acceptable compressed page. Any page that does not compress
>>     by at least this ratio will be rejected.
>> * max_pool_percent - The maximum percentage of memory that the compressed
>>     pool can occupy.
>>
>> To enabled zswap, the "enabled" attribute must be set to 1 at boot time.
>>
>> Zswap allows the compressor to be selected at kernel boot time by
>> setting the a??compressora?? attribute.  The default compressor is lzo.
>>
>> A debugfs interface is provided for various statistic about pool size,
>> number of pages stored, and various counters for the reasons pages
>> are rejected.
>>
>> Performance, Kernel Building:
>>
>> Setup
>> ========
>> Gentoo w/ kernel v3.7-rc7
>> Quad-core i5-2500 @ 3.3GHz
>> 512MB DDR3 1600MHz (limited with mem=512m on boot)
>> Filesystem and swap on 80GB HDD (about 58MB/s with hdparm -t)
>> majflt are major page faults reported by the time command
>> pswpin/out is the delta of pswpin/out from /proc/vmstat before and after
>> the make -jN
>>
>> Summary
>> ========
>> * Zswap reduces I/O and improves performance at all swap pressure levels.
>>
>> * Under heavy swaping at 24 threads, zswap reduced I/O by 76%, saving
>>   over 1.5GB of I/O, and cut runtime in half.
>>
>> Details
>> ========
>> I/O (in pages)
>> 	base				zswap				change	change
>> N	pswpin	pswpout	majflt	I/O sum	pswpin	pswpout	majflt	I/O sum	%I/O	MB
>> 8	1	335	291	627	0	0	249	249	-60%	1
>> 12	3688	14315	5290	23293	123	860	5954	6937	-70%	64
>> 16	12711	46179	16803	75693	2936	7390	46092	56418	-25%	75
>> 20	42178	133781	49898	225857	9460	28382	92951	130793	-42%	371
>> 24	96079	357280	105242	558601	7719	18484	109309	135512	-76%	1653
>>
>> Runtime (in seconds)
>> N	base	zswap	%change
>> 8	107	107	0%
>> 12	128	110	-14%
>> 16	191	179	-6%
>> 20	371	240	-35%
>> 24	570	267	-53%
>>
>> %CPU utilization (out of 400% on 4 cpus)
>> N	base	zswap	%change
>> 8	317	319	1%
>> 12	267	311	16%
>> 16	179	191	7%
>> 20	94	143	52%
>> 24	60	128	113%
>>
>>
>> Seth Jennings (7):
>>   debugfs: add get/set for atomic types
>>   zsmalloc: promote to lib/
>>   zswap: add to mm/
>>   mm: break up swap_writepage() for frontswap backends
>>   mm: allow for outstanding swap writeback accounting
>>   zswap: add flushing support
>>   zswap: add documentation
>>
>>  Documentation/vm/zswap.txt                         |   73 ++
>>  drivers/staging/Kconfig                            |    2 -
>>  drivers/staging/Makefile                           |    1 -
>>  drivers/staging/zcache/zcache-main.c               |    3 +-
>>  drivers/staging/zram/zram_drv.h                    |    3 +-
>>  drivers/staging/zsmalloc/Kconfig                   |   10 -
>>  drivers/staging/zsmalloc/Makefile                  |    3 -
>>  fs/debugfs/file.c                                  |   42 +
>>  include/linux/debugfs.h                            |    2 +
>>  include/linux/swap.h                               |    4 +
>>  .../staging/zsmalloc => include/linux}/zsmalloc.h  |    0
>>  lib/Kconfig                                        |   18 +
>>  lib/Makefile                                       |    1 +
>>  .../zsmalloc/zsmalloc-main.c => lib/zsmalloc.c     |    3 +-
>>  mm/Kconfig                                         |   15 +
>>  mm/Makefile                                        |    1 +
>>  mm/page_io.c                                       |   22 +-
>>  mm/swap_state.c                                    |    2 +-
>>  mm/zswap.c                                         | 1073 ++++++++++++++++++++
>>  19 files changed, 1250 insertions(+), 28 deletions(-)
>>  create mode 100644 Documentation/vm/zswap.txt
>>  delete mode 100644 drivers/staging/zsmalloc/Kconfig
>>  delete mode 100644 drivers/staging/zsmalloc/Makefile
>>  rename {drivers/staging/zsmalloc => include/linux}/zsmalloc.h (100%)
>>  rename drivers/staging/zsmalloc/zsmalloc-main.c => lib/zsmalloc.c (99%)
>>  create mode 100644 mm/zswap.c
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

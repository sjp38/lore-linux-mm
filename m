Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1AFBE600365
	for <linux-mm@kvack.org>; Sat, 17 Jul 2010 22:23:01 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1540360pvc.14
        for <linux-mm@kvack.org>; Sat, 17 Jul 2010 19:22:59 -0700 (PDT)
Message-ID: <4C4265A0.5070602@vflare.org>
Date: Sun, 18 Jul 2010 07:53:28 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <201007171713.34903.edt@aei.ca>
In-Reply-To: <201007171713.34903.edt@aei.ca>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ed Tomlinson <edt@aei.ca>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Ed,

On 07/18/2010 02:43 AM, Ed Tomlinson wrote:
> 
> Would you have all this in a git tree somewhere?
> 
> Considering getting this working requires 24 patches it would really help with testing.
> 

Unfortunately, git tree for this is not hosted anywhere.

Anyways, I just uploaded monolithic zcache patch containing all its dependencies:
http://compcache.googlecode.com/hg/sub-projects/mainline/zcache_v1_2.6.35-rc5.patch

It applies on top of 2.6.35-rc5

Thanks for trying it out.
Nitin


> On Friday 16 July 2010 08:37:42 you wrote:
>> Frequently accessed filesystem data is stored in memory to reduce access to
>> (much) slower backing disks. Under memory pressure, these pages are freed and
>> when needed again, they have to be read from disks again. When combined working
>> set of all running application exceeds amount of physical RAM, we get extereme
>> slowdown as reading a page from disk can take time in order of milliseconds.
>>
>> Memory compression increases effective memory size and allows more pages to
>> stay in RAM. Since de/compressing memory pages is several orders of magnitude
>> faster than disk I/O, this can provide signifant performance gains for many
>> workloads. Also, with multi-cores becoming common, benefits of reduced disk I/O
>> should easily outweigh the problem of increased CPU usage.
>>
>> It is implemented as a "backend" for cleancache_ops [1] which provides
>> callbacks for events such as when a page is to be removed from the page cache
>> and when it is required again. We use them to implement a 'second chance' cache
>> for these evicted page cache pages by compressing and storing them in memory
>> itself.
>>
>> We only keep pages that compress to PAGE_SIZE/2 or less. Compressed chunks are
>> stored using xvmalloc memory allocator which is already being used by zram
>> driver for the same purpose. Zero-filled pages are checked and no memory is
>> allocated for them.
>>
>> A separate "pool" is created for each mount instance for a cleancache-aware
>> filesystem. Each incoming page is identified with <pool_id, inode_no, index>
>> where inode_no identifies file within the filesystem corresponding to pool_id
>> and index is offset of the page within this inode. Within a pool, inodes are
>> maintained in an rb-tree and each of its nodes points to a separate radix-tree
>> which maintains list of pages within that inode.
>>
>> While compression reduces disk I/O, it also reduces the space available for
>> normal (uncompressed) page cache. This can result in more frequent page cache
>> reclaim and thus higher CPU overhead. Thus, it's important to maintain good hit
>> rate for compressed cache or increased CPU overhead can nullify any other
>> benefits. This requires adaptive (compressed) cache resizing and page
>> replacement policies that can maintain optimal cache size and quickly reclaim
>> unused compressed chunks. This work is yet to be done. However, in the current
>> state, it allows manually resizing cache size using (per-pool) sysfs node
>> 'memlimit' which in turn frees any excess pages *sigh* randomly.
>>
>> Finally, it uses percpu stats and compression buffers to allow better
>> performance on multi-cores. Still, there are known bottlenecks like a single
>> xvmalloc mempool per zcache pool and few others. I will work on this when I
>> start with profiling.
>>
>>  * Performance numbers:
>>    - Tested using iozone filesystem benchmark
>>    - 4 CPUs, 1G RAM
>>    - Read performance gain: ~2.5X
>>    - Random read performance gain: ~3X
>>    - In general, performance gains for every kind of I/O
>>
>> Test details with graphs can be found here:
>> http://code.google.com/p/compcache/wiki/zcacheIOzone
>>
>> If I can get some help with testing, it would be intersting to find its
>> effect in more real-life workloads. In particular, I'm intersted in finding
>> out its effect in KVM virtualization case where it can potentially allow
>> running more number of VMs per-host for a given amount of RAM. With zcache
>> enabled, VMs can be assigned much smaller amount of memory since host can now
>> hold bulk of page-cache pages, allowing VMs to maintain similar level of
>> performance while a greater number of them can be hosted.
>>
>>  * How to test:
>> All patches are against 2.6.35-rc5:
>>
>>  - First, apply all prerequisite patches here:
>> http://compcache.googlecode.com/hg/sub-projects/zcache_base_patches
>>
>>  - Then apply this patch series; also uploaded here:
>> http://compcache.googlecode.com/hg/sub-projects/zcache_patches
>>
>>
>> Nitin Gupta (8):
>>   Allow sharing xvmalloc for zram and zcache
>>   Basic zcache functionality
>>   Create sysfs nodes and export basic statistics
>>   Shrink zcache based on memlimit
>>   Eliminate zero-filled pages
>>   Compress pages using LZO
>>   Use xvmalloc to store compressed chunks
>>   Document sysfs entries
>>
>>  Documentation/ABI/testing/sysfs-kernel-mm-zcache |   53 +
>>  drivers/staging/Makefile                         |    2 +
>>  drivers/staging/zram/Kconfig                     |   22 +
>>  drivers/staging/zram/Makefile                    |    5 +-
>>  drivers/staging/zram/xvmalloc.c                  |    8 +
>>  drivers/staging/zram/zcache_drv.c                | 1312 ++++++++++++++++++++++
>>  drivers/staging/zram/zcache_drv.h                |   90 ++
>>  7 files changed, 1491 insertions(+), 1 deletions(-)
>>  create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-zcache
>>  create mode 100644 drivers/staging/zram/zcache_drv.c
>>  create mode 100644 drivers/staging/zram/zcache_drv.h
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

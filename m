Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 5F2586B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:21:02 -0400 (EDT)
Message-ID: <4FEC9181.9060000@sandia.gov>
Date: Thu, 28 Jun 2012 11:16:49 -0600
From: "Jim Schutt" <jaschut@sandia.gov>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: have order>0 compaction start off where it
 left
References: <20120627233742.53225fc7@annuminas.surriel.com>
In-Reply-To: <20120627233742.53225fc7@annuminas.surriel.com>
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, linux-kernel@vger.kernel.org


On 06/27/2012 09:37 PM, Rik van Riel wrote:
> Order>  0 compaction stops when enough free pages of the correct
> page order have been coalesced. When doing subsequent higher order
> allocations, it is possible for compaction to be invoked many times.
>
> However, the compaction code always starts out looking for things to
> compact at the start of the zone, and for free pages to compact things
> to at the end of the zone.
>
> This can cause quadratic behaviour, with isolate_freepages starting
> at the end of the zone each time, even though previous invocations
> of the compaction code already filled up all free memory on that end
> of the zone.
>
> This can cause isolate_freepages to take enormous amounts of CPU
> with certain workloads on larger memory systems.
>
> The obvious solution is to have isolate_freepages remember where
> it left off last time, and continue at that point the next time
> it gets invoked for an order>  0 compaction. This could cause
> compaction to fail if cc->free_pfn and cc->migrate_pfn are close
> together initially, in that case we restart from the end of the
> zone and try once more.
>
> Forced full (order == -1) compactions are left alone.
>
> Reported-by: Jim Schutt<jaschut@sandia.gov>
> Signed-off-by: Rik van Riel<riel@redhat.com>

Tested-by: Jim Schutt<jaschut@sandia.gov>

Please let me know if you further refine this patch
and would like me to test it with my workload.

> ---
> CAUTION: due to the time of day, I have only COMPILE tested this code
>
>   include/linux/mmzone.h |    4 ++++
>   mm/compaction.c        |   25 +++++++++++++++++++++++--
>   mm/internal.h          |    1 +
>   mm/page_alloc.c        |    4 ++++
>   4 files changed, 32 insertions(+), 2 deletions(-)

This patch is working great for me.

FWIW here's a typical vmstat report, after ~20 minutes of my Ceph load:

2012-06-28 10:59:16.887-06:00
vmstat -w 4 16
procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
23 21          0     393128        480   36883448    0    0     8 49583   90  273   6 25  58 11  0
  6 18          0     397892        480   36912832    0    0   281 2293321 203321 168790  11 43  22 24  0
17 23          0     394540        480   36921356    0    0   262 2227505 202744 163158  11 45  20 23  0
25 17          0     359404        480   36972884    0    0   205 2243941 201087 167874  11 42  23 24  0
21 20          0     367400        480   36934416    0    0   232 2310577 200666 156693  12 50  17 22  0
12 18          0     378048        480   36890624    0    0   232 2235455 196480 165692  11 44  22 24  0
17 18          0     372444        480   36874484    0    0   280 2185592 195885 168416  11 43  24 23  0
51 16          0     372760        480   36841148    0    0   245 2211135 195711 158012  11 46  23 20  0
23 17          0     375272        480   36847292    0    0   228 2323708 207079 164988  12 49  19 20  0
10 26          0     373540        480   36889240    0    0   341 2290586 201708 167954  11 46  19 23  0
44 14          0     303828        480   37020940    0    0   302 2180893 199958 168619  11 40  23 26  0
24 14          0     359320        480   36970272    0    0   345 2173978 197097 163760  11 47  22 20  0
32 19          0     355744        480   36917372    0    0   267 2276251 200123 167776  11 46  19 23  0
34 19          0     360824        480   36900032    0    0   259 2252057 200942 170912  11 43  21 25  0
13 17          0     361288        480   36919360    0    0   253 2149189 188426 170940  10 40  27 23  0
15 16          0     341828        480   36883988    0    0   317 2272817 205203 173732  11 48  19 21  0

Also FWIW, here's a typical "perf top" report with the patch applied:

    PerfTop:   17575 irqs/sec  kernel:80.4%  exact:  0.0% [1000Hz cycles],  (all, 24 CPUs)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

              samples  pcnt function                    DSO
              _______ _____ ___________________________ ________________________________________________________________________________________

             27583.00 11.6% copy_user_generic_string    /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
             18387.00  7.8% __crc32c_le                 /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
             17264.00  7.3% _raw_spin_lock_irqsave      /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
             13890.00  5.9% ceph_crc32c_le              /usr/bin/ceph-osd
              5952.00  2.5% __copy_user_nocache         /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              4663.00  2.0% memmove                     /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              3141.00  1.3% _raw_spin_lock              /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2939.00  1.2% rb_prev                     /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2933.00  1.2% clflush_cache_range         /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2586.00  1.1% __list_del_entry            /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2357.00  1.0% intel_idle                  /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2168.00  0.9% __set_page_dirty_nobuffers  /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2110.00  0.9% get_pageblock_flags_group   /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2103.00  0.9% set_page_dirty              /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              2090.00  0.9% futex_wake                  /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1959.00  0.8% __memcpy                    /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1696.00  0.7% generic_bin_search          /lib/modules/3.5.0-rc4-00012-g3986cf7/kernel/fs/btrfs/btrfs.ko
              1628.00  0.7% btree_set_page_dirty        /lib/modules/3.5.0-rc4-00012-g3986cf7/kernel/fs/btrfs/btrfs.ko
              1606.00  0.7% _raw_spin_unlock_irqrestore /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1516.00  0.6% map_private_extent_buffer   /lib/modules/3.5.0-rc4-00012-g3986cf7/kernel/fs/btrfs/btrfs.ko
              1481.00  0.6% futex_requeue               /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1447.00  0.6% isolate_migratepages_range  /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1365.00  0.6% __schedule                  /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1361.00  0.6% memcpy                      /lib64/libc-2.12.so
              1263.00  0.5% trace_hardirqs_off          /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1238.00  0.5% tg_load_down                /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1220.00  0.5% move_freepages_block        /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1198.00  0.5% find_iova                   /lib/modules/3.5.0-rc4-00012-g3986cf7/build/vmlinux
              1139.00  0.5% process_responses           /lib/modules/3.5.0-rc4-00012-g3986cf7/kernel/drivers/net/ethernet/chelsio/cxgb4/cxgb4.ko

So far I've run a total of ~20 TB of data over fifty minutes
or so through 12 machines running this patch; no hint of
trouble, great performance.

Without this patch I would typically start having trouble
after just a few minutes of this load.

Thanks!

-- Jim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

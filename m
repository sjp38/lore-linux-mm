Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5D43C6B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:04:08 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so4286105pdj.33
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 03:04:08 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id mq4si10383428pbb.192.2014.06.16.03.04.06
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 03:04:07 -0700 (PDT)
Message-ID: <539EC117.1040105@cn.fujitsu.com>
Date: Mon, 16 Jun 2014 18:04:07 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] mm: add page cache limit and reclaim feature
References: <539EB7D6.8070401@huawei.com>
In-Reply-To: <539EB7D6.8070401@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

Hi,

On 06/16/2014 05:24 PM, Xishi Qiu wrote:
> When system(e.g. smart phone) running for a long time, the cache often takes
> a large memory, maybe the free memory is less than 50M, then OOM will happen
> if APP allocate a large order pages suddenly and memory reclaim too slowly. 

If there is really too many page caches, and the free memory is low. I think
the page allocator will enter the slowpath to free more memory for allocation.
And it the slowpath, there is indeed the direct reclaim operation, so is that
really not enough to reclaim pagecaches?

> 
> Use "echo 3 > /proc/sys/vm/drop_caches" will drop the whole cache, this will
> affect the performance, so it is used for debugging only. 
> 
> suse has this feature, I tested it before, but it can not limit the page cache
> actually. So I rewrite the feature and add some parameters.
> 
> Christoph Lameter has written a patch "Limit the size of the pagecache"
> http://marc.info/?l=linux-mm&m=116959990228182&w=2
> It changes in zone fallback, this is not a good way.
> 
> The patchset is based on v3.15, it introduces two features, page cache limit
> and page cache reclaim in circles.
> 
> Add four parameters in /proc/sys/vm
> 
> 1) cache_limit_mbytes
> This is used to limit page cache amount.
> The input unit is MB, value range is from 0 to totalram_pages.
> If this is set to 0, it will not limit page cache.
> When written to the file, cache_limit_ratio will be updated too.
> The default value is 0.
> 
> 2) cache_limit_ratio
> This is used to limit page cache amount.
> The input unit is percent, value range is from 0 to 100.
> If this is set to 0, it will not limit page cache.
> When written to the file, cache_limit_mbytes will be updated too.
> The default value is 0.
> 
> 3) cache_reclaim_s
> This is used to reclaim page cache in circles.
> The input unit is second, the minimum value is 0.
> If this is set to 0, it will disable the feature.
> The default value is 0.
> 
> 4) cache_reclaim_weight
> This is used to speed up page cache reclaim.
> It depend on enabling cache_limit_mbytes/cache_limit_ratio or cache_reclaim_s.
> Value range is from 1(slow) to 100(fast).
> The default value is 1.
> 
> I tested the two features on my system(x86_64), it seems to work right.
> However, as it changes the hot path "add_to_page_cache_lru()", I don't know
> how much it will the affect the performance,

Yeah, at a quick glance, for every invoke of add_to_page_cache_lru(), there is the 
newly added test:

if (vm_cache_limit_mbytes && page_cache_over_limit())

and if the test is passed, shrink_page_cache()->do_try_to_free_pages() is called.
And this is a sync operation. IMO, it is better to make such an operation async.
(You've implemented async operation but I doubt if it is suitable to put the sync operation
here.)

Thanks.

 maybe there are some errors
> in the patches too, RFC.
> 
> 
> *** BLURB HERE ***
> 
> Xishi Qiu (8):
>   mm: introduce cache_limit_ratio and cache_limit_mbytes
>   mm: add shrink page cache core
>   mm: implement page cache limit feature
>   mm: introduce cache_reclaim_s
>   mm: implement page cache reclaim in circles
>   mm: introduce cache_reclaim_weight
>   mm: implement page cache reclaim speed
>   doc: update Documentation/sysctl/vm.txt
> 
>  Documentation/sysctl/vm.txt |   43 +++++++++++++++++++
>  include/linux/swap.h        |   17 ++++++++
>  kernel/sysctl.c             |   35 +++++++++++++++
>  mm/filemap.c                |    3 +
>  mm/hugetlb.c                |    3 +
>  mm/page_alloc.c             |   51 ++++++++++++++++++++++
>  mm/vmscan.c                 |   97 ++++++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 248 insertions(+), 1 deletions(-)
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> .
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

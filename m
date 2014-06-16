Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id EABBF6B0039
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:14:25 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so3846605wiv.16
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 04:14:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id na16si8045021wic.50.2014.06.16.04.14.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 04:14:24 -0700 (PDT)
Date: Mon, 16 Jun 2014 13:14:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/8] mm: add page cache limit and reclaim feature
Message-ID: <20140616111422.GA16915@dhcp22.suse.cz>
References: <539EB7D6.8070401@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539EB7D6.8070401@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Mon 16-06-14 17:24:38, Xishi Qiu wrote:
> When system(e.g. smart phone) running for a long time, the cache often takes
> a large memory, maybe the free memory is less than 50M, then OOM will happen
> if APP allocate a large order pages suddenly and memory reclaim too slowly. 

Have you ever seen this to happen? Page cache should be easy to reclaim and
if there is too mach dirty memory then you should be able to tune the
amount by dirty_bytes/ratio knob. If the page allocator falls back to
OOM and there is a lot of page cache then I would call it a bug. I do
not think that limiting the amount of the page cache globally makes
sense. There are Unix systems which offer this feature but I think it is
a bad interface which only papers over the reclaim inefficiency or lack
of other isolations between loads.

> Use "echo 3 > /proc/sys/vm/drop_caches" will drop the whole cache, this will
> affect the performance, so it is used for debugging only. 
> 
> suse has this feature, I tested it before, but it can not limit the page cache
> actually. So I rewrite the feature and add some parameters.

The feature is there for historic reasons and I _really_ think the
interface is not appropriate. If there is a big pagecache usage which
affects other loads then Memory cgroup controller can be used to help
from interference.

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
> how much it will the affect the performance, maybe there are some errors
> in the patches too, RFC.

I haven't looked at patches yet but you would need to explain why the
feature is needed much better and why the existing features are not
sufficient.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24F4C6B025E
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 07:43:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so4562417wmz.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 04:43:24 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 9si29864755wjg.16.2016.08.17.04.43.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 04:43:23 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i138so23101151wmf.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 04:43:22 -0700 (PDT)
Date: Wed, 17 Aug 2016 13:43:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: kswapd struggles reclaiming the pages on 64GB server
Message-ID: <20160817114320.GA20719@dhcp22.suse.cz>
References: <CAK-uSPo9Nc-1HaURvwstOGYGuMEx4CXhPRv+cZevYLZX6URzYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK-uSPo9Nc-1HaURvwstOGYGuMEx4CXhPRv+cZevYLZX6URzYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andriy Tkachuk <andriy.tkachuk@seagate.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

[CCing linux-mm and Johannes]

On Fri 12-08-16 21:52:20, Andriy Tkachuk wrote:
> Hi,
> 
> our user-space application uses large amount of anon pages (private
> mapping of the large file, more than 64GB RAM available in the system)
> which are rarely accessible and are supposed to be swapped out.
> Instead, we see that most of these pages are kept in memory while the
> system suffers from the lack of free memory and overall performance
> (especially the disk I/O, vm.swappiness=100 does not help it). kswapd
> scans millions of pages per second but reclames hundreds per sec only.

I haven't looked at your numbers deeply but this smells like the long
standing problem/limitation we have. We are trying really hard to not
swap out and rather reclaim the page cache because the swap refault
tends to be more disruptive in many case. Not all, though, and trashing
like behavior you see is cetainly undesirable.

Johannes has been looking into that area recently. Have a look at
http://lkml.kernel.org/r/20160606194836.3624-1-hannes@cmpxchg.org

> Here are the 5 secs interval snapshots of some counters:
> 
> $ egrep 'Cached|nr_.*active_anon|pgsteal_.*_normal|pgscan_kswapd_normal|pgrefill_normal|nr_vmscan_write|nr_swap|pgact'
> proc-*-0616-1605[345]* | sed 's/:/ /' | sort -sk 2,2
> proc-meminfo-0616-160539.txt Cached:           347936 kB
> proc-meminfo-0616-160549.txt Cached:           316316 kB
> proc-meminfo-0616-160559.txt Cached:           322264 kB
> proc-meminfo-0616-160539.txt SwapCached:      2853064 kB
> proc-meminfo-0616-160549.txt SwapCached:      2853168 kB
> proc-meminfo-0616-160559.txt SwapCached:      2853280 kB
> proc-vmstat-0616-160535.txt nr_active_anon 14508616
> proc-vmstat-0616-160545.txt nr_active_anon 14513725
> proc-vmstat-0616-160555.txt nr_active_anon 14515197
> proc-vmstat-0616-160535.txt nr_inactive_anon 747407
> proc-vmstat-0616-160545.txt nr_inactive_anon 744846
> proc-vmstat-0616-160555.txt nr_inactive_anon 744509
> proc-vmstat-0616-160535.txt nr_vmscan_write 5589095
> proc-vmstat-0616-160545.txt nr_vmscan_write 5589097
> proc-vmstat-0616-160555.txt nr_vmscan_write 5589097
> proc-vmstat-0616-160535.txt pgactivate 246016824
> proc-vmstat-0616-160545.txt pgactivate 246033242
> proc-vmstat-0616-160555.txt pgactivate 246042064
> proc-vmstat-0616-160535.txt pgrefill_normal 22763262
> proc-vmstat-0616-160545.txt pgrefill_normal 22768020
> proc-vmstat-0616-160555.txt pgrefill_normal 22768178
> proc-vmstat-0616-160535.txt pgscan_kswapd_normal 111985367420
> proc-vmstat-0616-160545.txt pgscan_kswapd_normal 111996845554
> proc-vmstat-0616-160555.txt pgscan_kswapd_normal 112028276639
> proc-vmstat-0616-160535.txt pgsteal_direct_normal 344064
> proc-vmstat-0616-160545.txt pgsteal_direct_normal 344064
> proc-vmstat-0616-160555.txt pgsteal_direct_normal 344064
> proc-vmstat-0616-160535.txt pgsteal_kswapd_normal 53817848
> proc-vmstat-0616-160545.txt pgsteal_kswapd_normal 53818626
> proc-vmstat-0616-160555.txt pgsteal_kswapd_normal 53818637
> 
> The pgrefill_normal and pgactivate counters show that only few
> hundreds/sec pages move from active to inactive and vice versa lists -
> that is comparable with what was reclaimed. So it looks like kswapd
> scans the pages from inactive list mostly in kind of a loop and does
> not even have a chance to look at the pages from the active list
> (where most of the application's anon pages are located).
> 
> The kernel version: linux-3.10.0-229.14.1.el7.
> 
> Any ideas? Would be be useful to change inactive_ratio dynamically in
> such a cases so that more pages could be moved from active to inactive
> list and get a chance to be reclaimed? (Note: when application is
> restarted - the problem disappears for a while (days) until the
> correspondent number of privately mapped pages are dirtied again.)
> 
> Thank you,
>    Andriy

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

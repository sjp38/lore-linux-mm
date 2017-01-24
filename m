Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 79D906B02A1
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:46:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so29664525wmd.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:46:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s131si18933503wmf.117.2017.01.24.08.46.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 08:46:53 -0800 (PST)
Date: Tue, 24 Jan 2017 17:46:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/3] optimize kswapd when it does reclaim for hugepage
Message-ID: <20170124164646.GA30832@dhcp22.suse.cz>
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Tue 24-01-17 15:49:01, Jia He wrote:
> If there is a server with uneven numa memory layout:
> available: 7 nodes (0-6)
> node 0 cpus: 0 1 2 3 4 5 6 7
> node 0 size: 6603 MB
> node 0 free: 91 MB
> node 1 cpus:
> node 1 size: 12527 MB
> node 1 free: 157 MB
> node 2 cpus:
> node 2 size: 15087 MB
> node 2 free: 189 MB
> node 3 cpus:
> node 3 size: 16111 MB
> node 3 free: 205 MB
> node 4 cpus: 8 9 10 11 12 13 14 15
> node 4 size: 24815 MB
> node 4 free: 310 MB
> node 5 cpus:
> node 5 size: 4095 MB
> node 5 free: 61 MB
> node 6 cpus:
> node 6 size: 22750 MB
> node 6 free: 283 MB
> node distances:
> node   0   1   2   3   4   5   6
>   0:  10  20  40  40  40  40  40
>   1:  20  10  40  40  40  40  40
>   2:  40  40  10  20  40  40  40
>   3:  40  40  20  10  40  40  40
>   4:  40  40  40  40  10  20  40
>   5:  40  40  40  40  20  10  40
>   6:  40  40  40  40  40  40  10
> 
> In this case node 5 has less memory and we will alloc the hugepages
> from these nodes one by one after we trigger 
> echo 4000 > /proc/sys/vm/nr_hugepages
> 
> Then the kswapd5 will take 100% cpu for a long time. This is a livelock
> issue in kswapd. This patch set fixes it.

It would be really helpful to describe what is the issue and whether it
is specific to the configuration above. Also a highlevel overview of the
fix and why it is the right approach would be appreciated.
 
> The 3rd patch improves the kswapd's bad performance significantly.

Numbers?

> Jia He (3):
>   mm/hugetlb: split alloc_fresh_huge_page_node into fast and slow path
>   mm, vmscan: limit kswapd loop if no progress is made
>   mm, vmscan: correct prepare_kswapd_sleep return value
> 
>  mm/hugetlb.c |  9 +++++++++
>  mm/vmscan.c  | 28 ++++++++++++++++++++++++----
>  2 files changed, 33 insertions(+), 4 deletions(-)
> 
> -- 
> 2.5.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

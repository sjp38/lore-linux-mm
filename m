Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 007716B0388
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 19:13:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q126so2331604pga.0
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 16:13:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w70si80107pgw.402.2017.03.14.16.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 16:13:34 -0700 (PDT)
Message-ID: <1489533213.2733.33.camel@linux.intel.com>
Subject: Re: [PATCH -mm -v6 3/9] mm, THP, swap: Add swap cluster
 allocate/free functions
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 14 Mar 2017 16:13:33 -0700
In-Reply-To: <20170308072613.17634-4-ying.huang@intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com>
	 <20170308072613.17634-4-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, 2017-03-08 at 15:26 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> The swap cluster allocation/free functions are added based on the
> existing swap cluster management mechanism for SSD.A A These functions
> don't work for the rotating hard disks because the existing swap cluster
> management mechanism doesn't work for them.A A The hard disks support may
> be added if someone really need it.A A But that needn't be included in
> this patchset.
> 
> This will be used for the THP (Transparent Huge Page) swap support.
> Where one swap cluster will hold the contents of each THP swapped out.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
> A mm/swapfile.c | 217 +++++++++++++++++++++++++++++++++++++++++-----------------
> A 1 file changed, 156 insertions(+), 61 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index a744604384ff..91876c33114b 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -378,6 +378,14 @@ static void swap_cluster_schedule_discard(struct swap_info_struct *si,
> A 	schedule_work(&si->discard_work);
> A }
> A 
> +static void __free_cluster(struct swap_info_struct *si, unsigned long idx)
> +{
> +	struct swap_cluster_info *ci = si->cluster_info;
> +
> +	cluster_set_flag(ci + idx, CLUSTER_FLAG_FREE);
> +	cluster_list_add_tail(&si->free_clusters, ci, idx);
> +}
> +
> A /*
> A  * Doing discard actually. After a cluster discard is finished, the cluster
> A  * will be added to free cluster list. caller should hold si->lock.
> @@ -398,10 +406,7 @@ static void swap_do_scheduled_discard(struct swap_info_struct *si)
> A 
> A 		spin_lock(&si->lock);
> A 		ci = lock_cluster(si, idx * SWAPFILE_CLUSTER);
> -		cluster_set_flag(ci, CLUSTER_FLAG_FREE);
> -		unlock_cluster(ci);
> -		cluster_list_add_tail(&si->free_clusters, info, idx);
> -		ci = lock_cluster(si, idx * SWAPFILE_CLUSTER);
> +		__free_cluster(si, idx);
> A 		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
> A 				0, SWAPFILE_CLUSTER);
> A 		unlock_cluster(ci);

The __free_cluster definition and the above change to eliminate
the extra unlock_cluster and lock_cluster can perhaps be broken up
as a separate patch. A It can be independent of THP changes.


Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

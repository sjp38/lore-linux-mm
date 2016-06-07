Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFD96B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 20:24:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l188so45522272pfl.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 17:24:53 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id q66si31400441pfb.190.2016.06.06.17.24.50
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 17:24:51 -0700 (PDT)
Date: Tue, 7 Jun 2016 09:25:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 01/10] mm: allow swappiness that prefers anon over file
Message-ID: <20160607002550.GA26230@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

Hi Johannes,

Thanks for the nice work. I didn't read all patchset yet but the design
makes sense to me so it would be better for zram-based on workload
compared to as is.

On Mon, Jun 06, 2016 at 03:48:27PM -0400, Johannes Weiner wrote:
> With the advent of fast random IO devices (SSDs, PMEM) and in-memory
> swap devices such as zswap, it's possible for swap to be much faster
> than filesystems, and for swapping to be preferable over thrashing
> filesystem caches.
> 
> Allow setting swappiness - which defines the relative IO cost of cache
> misses between page cache and swap-backed pages - to reflect such
> situations by making the swap-preferred range configurable.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  Documentation/sysctl/vm.txt | 16 +++++++++++-----
>  kernel/sysctl.c             |  3 ++-
>  mm/vmscan.c                 |  2 +-
>  3 files changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 720355cbdf45..54030750cd31 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -771,14 +771,20 @@ with no ill effects: errors and warnings on these stats are suppressed.)
>  
>  swappiness
>  
> -This control is used to define how aggressive the kernel will swap
> -memory pages.  Higher values will increase agressiveness, lower values
> -decrease the amount of swap.  A value of 0 instructs the kernel not to
> -initiate swap until the amount of free and file-backed pages is less
> -than the high water mark in a zone.
> +This control is used to define the relative IO cost of cache misses
> +between the swap device and the filesystem as a value between 0 and
> +200. At 100, the VM assumes equal IO cost and will thus apply memory
> +pressure to the page cache and swap-backed pages equally. At 0, the
> +kernel will not initiate swap until the amount of free and file-backed
> +pages is less than the high watermark in a zone.

Generally, I agree extending swappiness value good but not sure 200 is
enough to represent speed gap between file and swap sotrage in every
cases. - Just nitpick.

Some years ago, I extended it to 200 like your patch and experimented it
based on zram in our platform workload. At that time, it was terribly
slow in app switching workload if swappiness is higher than 150.
Although it was highly dependent on the workload, it's dangerous to
recommend it before fixing balacing between file and anon, I think.
IOW, I think this patch should be last one in this patchset.

>  
>  The default value is 60.
>  
> +On non-rotational swap devices, a value of 100 (or higher, depending
> +on what's backing the filesystem) is recommended.
> +
> +For in-memory swap, like zswap, values closer to 200 are recommended.

                maybe, like zram

I'm not sure it would be good suggestion for zswap because it ends up
writing cached pages to swap device once it reaches threshold.
Then, the cost is compression + decompression + write I/O which is
heavier than normal swap device(i.e., write I/O). OTOH, zram have no
(writeback I/O+ decompression) cost.

> +
>  ==============================================================
>  
>  - user_reserve_kbytes
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 2effd84d83e3..56a9243eb171 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -126,6 +126,7 @@ static int __maybe_unused two = 2;
>  static int __maybe_unused four = 4;
>  static unsigned long one_ul = 1;
>  static int one_hundred = 100;
> +static int two_hundred = 200;
>  static int one_thousand = 1000;
>  #ifdef CONFIG_PRINTK
>  static int ten_thousand = 10000;
> @@ -1323,7 +1324,7 @@ static struct ctl_table vm_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
>  		.extra1		= &zero,
> -		.extra2		= &one_hundred,
> +		.extra2		= &two_hundred,
>  	},
>  #ifdef CONFIG_HUGETLB_PAGE
>  	{
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c4a2f4512fca..f79010bbcdd4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -136,7 +136,7 @@ struct scan_control {
>  #endif
>  
>  /*
> - * From 0 .. 100.  Higher means more swappy.
> + * From 0 .. 200.  Higher means more swappy.
>   */
>  int vm_swappiness = 60;
>  /*
> -- 
> 2.8.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

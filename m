Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 54B3A6B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 10:52:16 -0400 (EDT)
Received: by lbon3 with SMTP id n3so3063952lbo.14
        for <linux-mm@kvack.org>; Mon, 27 Aug 2012 07:52:14 -0700 (PDT)
Message-ID: <503B8997.4040604@openvz.org>
Date: Mon, 27 Aug 2012 18:52:07 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [patch v2]swap: add a simple random read swapin detection
References: <20120827040037.GA8062@kernel.org>
In-Reply-To: <20120827040037.GA8062@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "minchan@kernel.org" <minchan@kernel.org>

Shaohua Li wrote:
> The swapin readahead does a blind readahead regardless if the swapin is
> sequential. This is ok for harddisk and random read, because read big size has
> no penality in harddisk, and if the readahead pages are garbage, they can be
> reclaimed fastly. But for SSD, big size read is more expensive than small size
> read. If readahead pages are garbage, such readahead only has overhead.
>
> This patch addes a simple random read detection like what file mmap readahead
> does. If random read is detected, swapin readahead will be skipped. This
> improves a lot for a swap workload with random IO in a fast SSD.
>
> I run anonymous mmap write micro benchmark, which will triger swapin/swapout.
> 			runtime changes with path
> randwrite harddisk	-38.7%
> seqwrite harddisk	-1.1%
> randwrite SSD		-46.9%
> seqwrite SSD		+0.3%

Very nice!

>
> For both harddisk and SSD, the randwrite swap workload run time is reduced
> significant. sequential write swap workload hasn't chanage.
>
> Interesting is the randwrite harddisk test is improved too. This might be
> because swapin readahead need allocate extra memory, which further tights
> memory pressure, so more swapout/swapin.
>
> This patch depends on readahead-fault-retry-breaks-mmap-file-read-random-detection.patch
>
> V1->V2:
> 1. Move the swap readahead accounting to separate functions as suggested by Riel.
> 2. Enable the logic only with CONFIG_SWAP enabled as suggested by Minchan.
>
> Signed-off-by: Shaohua Li<shli@fusionio.com>
> ---
>   include/linux/mm_types.h |    3 +++
>   mm/internal.h            |   44 ++++++++++++++++++++++++++++++++++++++++++++
>   mm/memory.c              |    3 ++-
>   mm/swap_state.c          |    8 ++++++++
>   4 files changed, 57 insertions(+), 1 deletion(-)
>

> --- linux.orig/include/linux/mm_types.h	2012-08-22 11:44:53.077912855 +0800
> +++ linux/include/linux/mm_types.h	2012-08-24 13:07:11.798576941 +0800
> @@ -279,6 +279,9 @@ struct vm_area_struct {
>   #ifdef CONFIG_NUMA
>   	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>   #endif
> +#ifdef CONFIG_SWAP
> +	atomic_t swapra_miss;
> +#endif

You can place this atomic on vma->anon_vma, it has perfect 4-byte hole right 
after field "refcount". vma->anon_vma already exists since this vma already 
contains anon pages.

>   };
>
>   struct core_thread {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

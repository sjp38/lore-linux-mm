Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0FF66B030E
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 01:23:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 6so20360177pgh.0
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 22:23:05 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d9si1033067pln.700.2017.09.11.22.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Sep 2017 22:23:04 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 4/5] mm:swap: respect page_cluster for readahead
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
	<1505183833-4739-4-git-send-email-minchan@kernel.org>
Date: Tue, 12 Sep 2017 13:23:01 +0800
In-Reply-To: <1505183833-4739-4-git-send-email-minchan@kernel.org> (Minchan
	Kim's message of "Tue, 12 Sep 2017 11:37:12 +0900")
Message-ID: <87vakopk22.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "Huang, Ying" <ying.huang@intel.com>

Minchan Kim <minchan@kernel.org> writes:

> page_cluster 0 means "we don't want readahead" so in the case,
> let's skip the readahead detection logic.
>
> Cc: "Huang, Ying" <ying.huang@intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/swap.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 0f54b491e118..739d94397c47 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -427,7 +427,8 @@ extern bool has_usable_swap(void);
>  
>  static inline bool swap_use_vma_readahead(void)
>  {
> -	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
> +	return page_cluster > 0 && READ_ONCE(swap_vma_readahead)
> +				&& !atomic_read(&nr_rotate_swap);
>  }
>  
>  /* Swap 50% full? Release swapcache more aggressively.. */

Now the readahead window size of the VMA based swap readahead is
controlled by /sys/kernel/mm/swap/vma_ra_max_order, while that of the
original swap readahead is controlled by sysctl page_cluster.  It is
possible for anonymous memory to use VMA based swap readahead and tmpfs
to use original swap readahead algorithm at the same time.  So that, I
think it is necessary to use different control knob to control these two
algorithm.  So if we want to disable readahead for tmpfs, but keep it
for VMA based readahead, we can set 0 to page_cluster but non-zero to
/sys/kernel/mm/swap/vma_ra_max_order.  With your change, this will be
impossible.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

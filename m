Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6F382F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 00:19:02 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so55230830pad.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 21:19:01 -0700 (PDT)
Received: from out4133-34.mail.aliyun.com (out4133-34.mail.aliyun.com. [42.120.133.34])
        by mx.google.com with ESMTP id ax2si7671215pbc.170.2015.10.29.21.19.00
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 21:19:01 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org> <1446131835-3263-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1446131835-3263-3-git-send-email-mhocko@kernel.org>
Subject: Re: [RFC 2/3] mm: throttle on IO only when there are too many dirty and writeback pages
Date: Fri, 30 Oct 2015 12:18:50 +0800
Message-ID: <00f301d112ca$14db86c0$3e929440$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>, Christoph Lameter <cl@linux.com>


> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3191,8 +3191,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 */
>  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
>  				ac->high_zoneidx, alloc_flags, target)) {
> -			/* Wait for some write requests to complete then retry */
> -			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> +			unsigned long writeback = zone_page_state(zone, NR_WRITEBACK),
> +				      dirty = zone_page_state(zone, NR_FILE_DIRTY);
> +
> +			if (did_some_progress)
> +				goto retry;
> +
> +			/*
> +			 * If we didn't make any progress and have a lot of
> +			 * dirty + writeback pages then we should wait for
> +			 * an IO to complete to slow down the reclaim and
> +			 * prevent from pre mature OOM
> +			 */
> +			if (2*(writeback + dirty) > reclaimable)
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> +			else
> +				cond_resched();
> +

Looks the vmstat updater issue is not addressed.
>  			goto retry;
>  		}
>  	}
> --
> 2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

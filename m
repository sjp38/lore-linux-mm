Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 00E986B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 10:58:33 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l126so75933078wml.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 07:58:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b130si36566823wmf.119.2015.12.21.07.58.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 07:58:31 -0800 (PST)
Subject: Re: [PATCH/RFC] mm/swapfile: reduce kswapd overhead by not filling up
 disks
References: <1449846574-35511-1-git-send-email-borntraeger@de.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <567821A5.7050201@suse.cz>
Date: Mon, 21 Dec 2015 16:58:29 +0100
MIME-Version: 1.0
In-Reply-To: <1449846574-35511-1-git-send-email-borntraeger@de.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On 12/11/2015 04:09 PM, Christian Borntraeger wrote:
> if a user has more than one swap disk with different priorities, the
> swap code will fill up the hight prio disk until the last block is
> used.
> The swap code will continue to scan the first disk also when its
> already filling the 2nd or 3rd disk.
> We have seen kswapd running at 100% CPU, with the majority of hits
> in the scanning code of scan_swap_map, even for non-rotational disks
> when this happens.
> For example with 3 disks
> disk1 99.9%
> disk2 10%
> disk3 0%
> it will scan the bitmap of disk1 (and as the disk is full the
> cluster optimization does not trigger) for every page that will
> likely go to disk2 anyway.
>
> By doing a first scan that only uses up to 98%, we force the swap
> code to use the 2nd disk slightly earlier, but it reduces kswapd
> cpu usage significantly. The 2nd scan will then allow to fill
> the remaining 2%, again starting with the highest prio disk.
>
> The code does not affect cases with all the same swap priorities,
> unless all disks are about 98% full.
> There is one issue with mythis approach: If there is a mix between
> same and different priorities, the code will loop too often due
> to the requeue, so and idea for a better fix is welcome.
>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

IMHO you should resend with CCing the relevant people directly (e.g. via 
./scripts/get_maintainers.pl) or this might simply get lost in 
high-volume mailing lists.

Note that I'm not familiar with this code. But my first thought would be 
to put a cache with batch-refill/free before the bitmap. During the 
"first" round only consider si's with enough free to satisfy the whole 
batch-refill.

> ---
>   mm/swapfile.c | 11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 5887731..d3817cf 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -640,6 +640,7 @@ swp_entry_t get_swap_page(void)
>   {
>   	struct swap_info_struct *si, *next;
>   	pgoff_t offset;
> +	bool first = true;
>
>   	if (atomic_long_read(&nr_swap_pages) <= 0)
>   		goto noswap;
> @@ -653,6 +654,12 @@ start_over:
>   		plist_requeue(&si->avail_list, &swap_avail_head);
>   		spin_unlock(&swap_avail_lock);
>   		spin_lock(&si->lock);
> +		/* at 98% usage lets try the other swaps */
> +		if (first && si->inuse_pages / 98 * 100 > si->pages) {
> +			spin_lock(&swap_avail_lock);
> +			spin_unlock(&si->lock);
> +			goto nextsi;
> +		}
>   		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
>   			spin_lock(&swap_avail_lock);
>   			if (plist_node_empty(&si->avail_list)) {
> @@ -692,6 +699,10 @@ nextsi:
>   		if (plist_node_empty(&next->avail_list))
>   			goto start_over;
>   	}
> +	if (first) {
> +		first = false;
> +		goto start_over;
> +	}
>
>   	spin_unlock(&swap_avail_lock);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

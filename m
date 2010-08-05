Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 632206B02B2
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 16:24:48 -0400 (EDT)
Date: Thu, 5 Aug 2010 13:24:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] writeback: Adding pages_dirtied and
 pages_entered_writeback
Message-Id: <20100805132433.d1d7927b.akpm@linux-foundation.org>
In-Reply-To: <1280969004-29530-3-git-send-email-mrubin@google.com>
References: <1280969004-29530-1-git-send-email-mrubin@google.com>
	<1280969004-29530-3-git-send-email-mrubin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Wed,  4 Aug 2010 17:43:24 -0700
Michael Rubin <mrubin@google.com> wrote:

> To help developers and applications gain visibility into writeback
> behaviour adding four read only sysctl files into /proc/sys/vm.
> These files allow user apps to understand writeback behaviour over time
> and learn how it is impacting their performance.
> 
>    # cat /proc/sys/vm/pages_dirtied
>    3747
>    # cat /proc/sys/vm/pages_entered_writeback
>    3618
> 
> Documentation/vm.txt has been updated.
> 
> In order to track the "cleaned" and "dirtied" counts we added two
> vm_stat_items.  Per memory node stats have been added also. So we can
> see per node granularity:
> 
>    # cat /sys/devices/system/node/node20/writebackstat
>    Node 20 pages_writeback: 0 times
>    Node 20 pages_dirtied: 0 times
> 
> ...
>
> @@ -1091,6 +1115,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
>  {
>  	if (mapping_cap_account_dirty(mapping)) {
>  		__inc_zone_page_state(page, NR_FILE_DIRTY);
> +		__inc_zone_page_state(page, NR_FILE_PAGES_DIRTIED);
>  		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  		task_dirty_inc(current);
>  		task_io_account_write(PAGE_CACHE_SIZE);

I hope the utility of this change is worth the overhead :(

> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -740,6 +740,8 @@ static const char * const vmstat_text[] = {
>  	"numa_local",
>  	"numa_other",
>  #endif
> +	"nr_pages_entered_writeback",
> +	"nr_file_pages_dirtied",
>  

Wait.  These counters appear in /proc/vmstat.  So why create standalone
/proc/sys/vm files as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

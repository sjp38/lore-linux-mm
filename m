Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B17A76B006C
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:05:45 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1927192pad.36
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 13:05:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ci5si14658723pdb.178.2014.10.15.13.05.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Oct 2014 13:05:44 -0700 (PDT)
Date: Wed, 15 Oct 2014 13:05:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: count only dirty pages as congested
Message-Id: <20141015130544.380aca0acfcb1413459520b0@linux-foundation.org>
In-Reply-To: <1413403115-1551-1-git-send-email-jamieliu@google.com>
References: <1413403115-1551-1-git-send-email-jamieliu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jamie Liu <jamieliu@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 15 Oct 2014 12:58:35 -0700 Jamie Liu <jamieliu@google.com> wrote:

> shrink_page_list() counts all pages with a mapping, including clean
> pages, toward nr_congested if they're on a write-congested BDI.
> shrink_inactive_list() then sets ZONE_CONGESTED if nr_dirty ==
> nr_congested. Fix this apples-to-oranges comparison by only counting
> pages for nr_congested if they count for nr_dirty.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -875,7 +875,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * end of the LRU a second time.
>  		 */
>  		mapping = page_mapping(page);
> -		if ((mapping && bdi_write_congested(mapping->backing_dev_info)) ||
> +		if (((dirty || writeback) && mapping &&
> +		     bdi_write_congested(mapping->backing_dev_info)) ||
>  		    (writeback && PageReclaim(page)))
>  			nr_congested++;

What are the observed runtime effects of this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

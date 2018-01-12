Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 73B4E6B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 23:41:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u16so3952589pfh.7
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 20:41:40 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z1sor5158487pfh.107.2018.01.11.20.41.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 20:41:39 -0800 (PST)
Date: Fri, 12 Jan 2018 13:41:33 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: ratelimit end_swap_bio_write() error
Message-ID: <20180112044133.GA4314@jagdpanzerIV>
References: <20180106043407.25193-1-sergey.senozhatsky@gmail.com>
 <20180106094124.GB16576@dhcp22.suse.cz>
 <20180106100313.GA527@tigerII.localdomain>
 <20180106133417.GA23629@dhcp22.suse.cz>
 <20180108015818.GA533@jagdpanzerIV>
 <20180108083742.GB5717@dhcp22.suse.cz>
 <20180108102234.GA818@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108102234.GA818@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (01/08/18 19:22), Sergey Senozhatsky wrote:
[..]
> > Your changelog is rather modest on the information.
> 
> fair point!
> 
> > Could you be more specific on how the problem actually happens how
> > likely it is?
> 
> ok. so what we have is
> 
> 	slow_path / swap-out page
> 	 __zram_bvec_write(page)
> 	  compressed_page = zcomp_compress(page)
> 	   zs_malloc(compressed_page)
> 	    // no available zspage found, need to allocate new
> 	     alloc_zspage()
> 	     {
> 		for (i = 0; i < class->pages_per_zspage; i++)
> 		    page = alloc_page(gfp);
> 		    if (!page)
> 			    return NULL
> 	     }
> 
> 	 return -ENOMEM
> 	...
> 	printk("Write-error on swap-device...");
> 
> 
> zspage-s can consist of up to ->pages_per_zspage normal pages.
> if alloc_page() fails then we can't allocate the entire zspage,
> so we can't store the swapped out page, so it remains in ram
> and we don't make any progress. so we try to swap another page
> and may be do the whole zs_malloc()->alloc_zspage() again, may
> be not. depending on how bad the OOM situation is there can be
> few or many "Write-error on swap-device" errors.
> 
> > And again, I do not think the throttling is an appropriate counter
> > measure. We do want to print those messages when a critical situation
> > happens. If we have a fallback then simply do not print at all.
> 
> sure, but with the ratelimited printk we still print those messages.
> we just don't print it for every single page we failed to write
> to the device. the existing error messages can (*sometimes*) be noisy
> and not very informative - "Write-error on swap-device (%u:%u:%llu)\n";
> it's not like 1000 of those tell more than 1 or 10.

Michal, does that make sense? with the updated/reworked commit
message will the patch be good enough?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

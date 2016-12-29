Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9A86B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 04:13:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so62354382wmu.1
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 01:13:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k188si53426918wmd.64.2016.12.29.01.13.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Dec 2016 01:13:03 -0800 (PST)
Date: Thu, 29 Dec 2016 10:12:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
Message-ID: <20161229091256.GF29208@dhcp22.suse.cz>
References: <20161229023131.506-1-eric@anholt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229023131.506-1-eric@anholt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Anholt <eric@anholt.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

This has been already brought up
http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and there
was a proposed patch for that which ratelimited the output
http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terrarum.net

then the email thread just died out because the issue turned out to be a
configuration issue. Michal indicated that the message might be useful
so dropping it completely seems like a bad idea. I do agree that
something has to be done about that though. Can we reconsider the
ratelimit thing?

On Wed 28-12-16 18:31:31, Eric Anholt wrote:
> For CMA allocations, we expect to occasionally hit this error path, at
> which point CMA will retry.  Given that, we shouldn't be spamming
> dmesg about it.
> 
> The Raspberry Pi graphics driver does frequent CMA allocations, and
> during regression testing this printk was sometimes occurring 100s of
> times per second.
> 
> Signed-off-by: Eric Anholt <eric@anholt.net>
> Cc: linux-stable <stable@vger.kernel.org>
> ---
>  mm/page_alloc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..bea7204c14a5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7289,8 +7289,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  
>  	/* Make sure the range is really isolated. */
>  	if (test_pages_isolated(outer_start, end, false)) {
> -		pr_info("%s: [%lx, %lx) PFNs busy\n",
> -			__func__, outer_start, end);
>  		ret = -EBUSY;
>  		goto done;
>  	}
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

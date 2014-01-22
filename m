Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2436B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 02:01:21 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id c41so1279998yho.6
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 23:01:21 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id j24si9541737yhb.96.2014.01.21.23.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 23:01:20 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id y13so9224314pdi.23
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 23:01:19 -0800 (PST)
Date: Tue, 21 Jan 2014 23:00:44 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap: do not skip lowest_bit in scan_swap_map() scan
 loop
In-Reply-To: <1390357276-16521-1-git-send-email-jamieliu@google.com>
Message-ID: <alpine.LSU.2.11.1401212251310.1001@eggly.anvils>
References: <1390357276-16521-1-git-send-email-jamieliu@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jamie Liu <jamieliu@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 21 Jan 2014, Jamie Liu wrote:

> In the second half of scan_swap_map()'s scan loop, offset is set to
> si->lowest_bit and then incremented before entering the loop for the
> first time, causing si->swap_map[si->lowest_bit] to be skipped.
> 
> Signed-off-by: Jamie Liu <jamieliu@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

Good catch.  At first I was puzzled that this off-by-one could have
gone unnoticed for so long (ever since 2.6.29); but now I think that
almost always we have a good amount of slack, in those pages duplicated
between swap and swapcache, which can be reclaimed at the vm_swap_full()
check, and so conceal this loss of a single slot.

> ---
>  mm/swapfile.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 612a7c9..6635081 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -616,7 +616,7 @@ scan:
>  		}
>  	}
>  	offset = si->lowest_bit;
> -	while (++offset < scan_base) {
> +	while (offset < scan_base) {
>  		if (!si->swap_map[offset]) {
>  			spin_lock(&si->lock);
>  			goto checks;
> @@ -629,6 +629,7 @@ scan:
>  			cond_resched();
>  			latency_ration = LATENCY_LIMIT;
>  		}
> +		offset++;
>  	}
>  	spin_lock(&si->lock);
>  
> -- 
> 1.8.5.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

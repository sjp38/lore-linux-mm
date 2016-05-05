Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 995F96B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 06:01:55 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so108590451pac.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 03:01:55 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id sr4si10551586pab.10.2016.05.05.03.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 03:01:54 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id 77so36006062pfv.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 03:01:54 -0700 (PDT)
Date: Thu, 5 May 2016 19:03:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in
 get_pages_per_zspage()
Message-ID: <20160505100329.GA497@swordfish>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (05/05/16 13:17), Ganesh Mahendran wrote:
> if we find a zspage with usage == 100%, there is no need to
> try other zspages.

Hello,

well... we iterate there from 0 to 1<<2, which is not awfully
a lot to break it in the middle, and we do this only when we
initialize a new pool (for every size class).

the check is
 - true   15 times
 - false  492 times

so it _sort of_ feels like this new if-condition doesn't
buy us a lot, and most of the time it just sits there with
no particular gain. let's hear from Minchan.

	-ss

> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> ---
>  mm/zsmalloc.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index fda7177..310c7b0 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -765,6 +765,9 @@ static int get_pages_per_zspage(int class_size)
>  		if (usedpc > max_usedpc) {
>  			max_usedpc = usedpc;
>  			max_usedpc_order = i;
> +
> +			if (max_usedpc == 100)
> +				break;
>  		}
>  	}
>  
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

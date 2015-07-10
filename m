Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C53CF6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 22:05:53 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so159554237pab.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 19:05:53 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id v11si11966765pas.164.2015.07.09.19.05.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 19:05:53 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so43239718pdr.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 19:05:52 -0700 (PDT)
Date: Fri, 10 Jul 2015 11:06:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710020624.GB692@swordfish>
References: <1436491929-6617-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436491929-6617-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (07/10/15 10:32), Minchan Kim wrote:
>  static struct page *isolate_source_page(struct size_class *class)
>  {
>  	struct page *page;
> +	int i;
> +	bool found = false;
>  

why use 'bool found'? just return `page', which will be either NULL
or !NULL?

	-ss

> -	page = class->fullness_list[ZS_ALMOST_EMPTY];
> -	if (page)
> -		remove_zspage(page, class, ZS_ALMOST_EMPTY);
> +	for (i = ZS_ALMOST_EMPTY; i >= ZS_ALMOST_FULL; i--) {
> +		page = class->fullness_list[i];
> +		if (!page)
> +			continue;
>  
> -	return page;
> +		remove_zspage(page, class, i);
> +		found = true;
> +		break;
> +	}
> +
> +	return found ? page : NULL;
>  }

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

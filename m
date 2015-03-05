Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFB56B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 00:18:10 -0500 (EST)
Received: by pabli10 with SMTP id li10so39679737pab.2
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 21:18:10 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id qi10si7775949pbb.131.2015.03.04.21.18.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 04 Mar 2015 21:18:09 -0800 (PST)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NKQ00K0A427WQ00@mailout3.samsung.com> for linux-mm@kvack.org;
 Thu, 05 Mar 2015 14:18:07 +0900 (KST)
Message-id: <54F7E719.6070505@samsung.com>
Date: Thu, 05 Mar 2015 14:18:17 +0900
From: Heesub Shin <heesub.shin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 3/7] zsmalloc: support compaction
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
 <1425445292-29061-4-git-send-email-minchan@kernel.org>
In-reply-to: <1425445292-29061-4-git-send-email-minchan@kernel.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com

Hello Minchan,

Nice work!

On 03/04/2015 02:01 PM, Minchan Kim wrote:
> +static void putback_zspage(struct zs_pool *pool, struct size_class *class,
> +				struct page *first_page)
> +{
> +	int class_idx;
> +	enum fullness_group fullness;
> +
> +	BUG_ON(!is_first_page(first_page));
> +
> +	get_zspage_mapping(first_page, &class_idx, &fullness);
> +	insert_zspage(first_page, class, fullness);
> +	fullness = fix_fullness_group(class, first_page);

Removal and re-insertion of zspage above can be eliminated, like this:

	fullness = get_fullness_group(first_page);
	insert_zspage(first_page, class, fullness);
	set_zspage_mapping(first_page, class->index, fullness);

regards,
heesub

>  	if (fullness == ZS_EMPTY) {
> +		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
> +			class->size, class->pages_per_zspage));
>  		atomic_long_sub(class->pages_per_zspage,
>  				&pool->pages_allocated);
> +
>  		free_zspage(first_page);
>  	}
>  }
> -EXPORT_SYMBOL_GPL(zs_free);
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

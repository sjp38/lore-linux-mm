Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1EB6B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 01:23:37 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so281681033pac.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 22:23:37 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id gc6si1184453pab.18.2016.08.01.22.23.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 22:23:36 -0700 (PDT)
Subject: Re: [PATCH] mm/memblock.c: fix NULL dereference error
References: <57A029A9.6060303@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57A02DA6.4010501@zoho.com>
Date: Tue, 2 Aug 2016 13:20:38 +0800
MIME-Version: 1.0
In-Reply-To: <57A029A9.6060303@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: zijun_hu@htc.com, kuleshovmail@gmail.com, tangchen@cn.fujitsu.com, tj@kernel.org, weiyang@linux.vnet.ibm.com, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org


On 08/02/2016 01:03 PM, zijun_hu wrote:
> Hi Andrew,
> 
> this patch is part of https://lkml.org/lkml/2016/7/26/347 and isn't merged in
> as you advised in another mail, i release this patch against linus's mainline
> for fixing relevant bugs completely, see test patch attached for verification
> details
> 
>>From 5a74cb46b7754a45428ff95f4653ad27025c3131 Mon Sep 17 00:00:00 2001
> From: zijun_hu <zijun_hu@htc.com>
> Date: Tue, 2 Aug 2016 12:35:28 +0800
> Subject: [PATCH] mm/memblock.c: fix NULL dereference error
> 
> it causes NULL dereference error and failure to get type_a->regions[0] info
> if parameter type_b of __next_mem_range_rev() == NULL
> 
> the bugs are fixed by checking before dereferring and initializing idx_b
> to 0
> 
> the approach is tested by dumping all types of region via __memblock_dump_all()
> and __next_mem_range_rev() fixed to UART separately, the result is okay after
> checking the logs
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> Tested-by: zijun_hu <zijun_hu@htc.com>
> Acked-by: Tejun Heo <tj@kernel.org>
> ---
>  mm/memblock.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index ff5ff3b..250dd48 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -994,7 +994,10 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
>  
>  	if (*idx == (u64)ULLONG_MAX) {
>  		idx_a = type_a->cnt - 1;
> -		idx_b = type_b->cnt;
> +		if (type_b != NULL)
> +			idx_b = type_b->cnt;
> +		else
> +			idx_b = 0;
>  	}
>  
>  	for (; idx_a >= 0; idx_a--) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

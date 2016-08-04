Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 329AF6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:37:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so443519662pfd.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:37:54 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id a90si13555201pfk.184.2016.08.04.01.37.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 01:37:53 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: Re: [PATCH] mm/vmalloc: fix align value calculation error
References: <57A2F6A3.9080908@zoho.com>
Message-ID: <57A2FE7B.5070505@zoho.com>
Date: Thu, 4 Aug 2016 16:36:11 +0800
MIME-Version: 1.0
In-Reply-To: <57A2F6A3.9080908@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, hannes@cmpxchg.org
Cc: mhocko@kernel.org, minchan@kernel.org, zijun_hu@htc.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/04/2016 04:02 PM, zijun_hu wrote:
>>From e40d1066f61394992e0167f259001ae9d2581dc1 Mon Sep 17 00:00:00 2001
> From: zijun_hu <zijun_hu@htc.com>
> Date: Thu, 4 Aug 2016 14:22:52 +0800
> Subject: [PATCH] mm/vmalloc: fix align value calculation error
> 
> it causes double align requirement for __get_vm_area_node() if parameter
> size is power of 2 and VM_IOREMAP is set in parameter flags
> 
> it is fixed by using order_base_2 instead of fls_long() due to lack of
> get_count_order() for long parameter
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> ---
>  mm/vmalloc.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 91f44e7..8b17c51 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1357,11 +1357,19 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
>  {
>  	struct vmap_area *va;
>  	struct vm_struct *area;
> +	int ioremap_size_order;
>  
>  	BUG_ON(in_interrupt());
> -	if (flags & VM_IOREMAP)
> -		align = 1ul << clamp_t(int, fls_long(size),
> -				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
> +	if (flags & VM_IOREMAP) {
> +		if (unlikely(size < 2))
> +			ioremap_size_order = size;
> +		else if (unlikely((signed long)size < 0))
> +			ioremap_size_order = sizeof(size) * 8;
> +		else
> +			ioremap_size_order = order_base_2(size);
> +		align = 1ul << clamp_t(int, ioremap_size_order, PAGE_SHIFT,
> +				IOREMAP_MAX_ORDER);
> +	}
>  
>  	size = PAGE_ALIGN(size);
>  	if (unlikely(!size))
> 
another fix approach is shown as follows

From: zijun_hu <zijun_hu@htc.com>
Date: Thu, 4 Aug 2016 14:22:52 +0800
Subject: [PATCH] mm/vmalloc: fix align value calculation error

it causes double align requirement for __get_vm_area_node() if parameter
size is power of 2 and VM_IOREMAP is set in parameter flags

it is fixed by handling the specail case manually due to lack of
get_count_order() for long parameter

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/vmalloc.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..dbbca8a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1357,11 +1357,16 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 {
 	struct vmap_area *va;
 	struct vm_struct *area;
+	int ioremap_size_order;
 
 	BUG_ON(in_interrupt());
-	if (flags & VM_IOREMAP)
-		align = 1ul << clamp_t(int, fls_long(size),
-				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
+	if (flags & VM_IOREMAP) {
+		ioremap_size_order = fls_long(size);
+		if (is_power_of_2(size) && size != 1)
+			ioremap_size_order--;
+		align = 1ul << clamp_t(int, ioremap_size_order, PAGE_SHIFT,
+				IOREMAP_MAX_ORDER);
+	}
 
 	size = PAGE_ALIGN(size);
 	if (unlikely(!size))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

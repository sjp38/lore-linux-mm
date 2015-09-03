Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0152B6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 04:25:08 -0400 (EDT)
Received: by lbpo4 with SMTP id o4so19984149lbp.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 01:25:07 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id s8si22415641laa.81.2015.09.03.01.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 01:25:02 -0700 (PDT)
Received: by laeb10 with SMTP id b10so23775279lae.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 01:25:02 -0700 (PDT)
Subject: Re: [PATCH 2/4] kasan: MODULE_VADDR is not available on all archs
References: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1441266863-5435-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55E803E5.10809@gmail.com>
Date: Thu, 3 Sep 2015 11:25:09 +0300
MIME-Version: 1.0
In-Reply-To: <1441266863-5435-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 09/03/2015 10:54 AM, Aneesh Kumar K.V wrote:
> Use is_module_text_address instead
> 

It should be is_module_address().

We use kernel_or_module_addr() to determine whether this
address belongs to some global variable or not.
And variables are in .data section, .text is only code.

Something like is_module_data_address() would be more precise here.
But since we don't have it, we can just use is_module_address().
Definitely not is_module_text_address().

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/kasan/report.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 6c3f82b0240b..01d2efec8ea4 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -22,6 +22,7 @@
>  #include <linux/string.h>
>  #include <linux/types.h>
>  #include <linux/kasan.h>
> +#include <linux/module.h>
>  
>  #include <asm/sections.h>
>  
> @@ -85,9 +86,11 @@ static void print_error_description(struct kasan_access_info *info)
>  
>  static inline bool kernel_or_module_addr(const void *addr)
>  {
> -	return (addr >= (void *)_stext && addr < (void *)_end)
> -		|| (addr >= (void *)MODULES_VADDR
> -			&& addr < (void *)MODULES_END);
> +	if (addr >= (void *)_stext && addr < (void *)_end)
> +		return true;
> +	if (is_module_text_address((unsigned long)addr))
> +		return true;
> +	return false;
>  }
>  
>  static inline bool init_task_stack_addr(const void *addr)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

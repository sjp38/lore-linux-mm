Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3840D6B030D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:35:32 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so70135685pfy.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:35:32 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id y21si28870686pgh.97.2016.11.15.16.35.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 16:35:31 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id 144so8722595pfv.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:35:31 -0800 (PST)
Subject: Re: [PATCH] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
References: <1479207422-6535-1-git-send-email-mpe@ellerman.id.au>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <ab8d90fd-a0b9-d6df-b359-9a4b0d415f28@gmail.com>
Date: Wed, 16 Nov 2016 11:35:25 +1100
MIME-Version: 1.0
In-Reply-To: <1479207422-6535-1-git-send-email-mpe@ellerman.id.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org



On 15/11/16 21:57, Michael Ellerman wrote:
> POISON_POINTER_DELTA is defined in poison.h, and is intended to be used
> to shift poison values so that they don't alias userspace.
> 
> We should add it to ZERO_SIZE_PTR so that attackers can't use
> ZERO_SIZE_PTR as a way to get a pointer to userspace.
> 
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  include/linux/slab.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 084b12bad198..17ddd7aea2dd 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -12,6 +12,7 @@
>  #define	_LINUX_SLAB_H
>  
>  #include <linux/gfp.h>
> +#include <linux/poison.h>
>  #include <linux/types.h>
>  #include <linux/workqueue.h>
>  
> @@ -109,7 +110,7 @@
>   * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
>   * Both make kfree a no-op.
>   */
> -#define ZERO_SIZE_PTR ((void *)16)
> +#define ZERO_SIZE_PTR ((void *)(16 + POISON_POINTER_DELTA))
>  
>  #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
>  				(unsigned long)ZERO_SIZE_PTR)
> 

I wonder if we should make this a variable with boot time entropy
within a certain region

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

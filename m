Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A93A6B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 17:28:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so46031590pfg.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 14:28:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lf7si44485612pab.197.2016.08.09.14.28.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 14:28:33 -0700 (PDT)
Date: Tue, 9 Aug 2016 14:28:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: fix align value calculation error
Message-Id: <20160809142832.623dfdbf666c08b8fc8772d2@linux-foundation.org>
In-Reply-To: <fc045ecf-20fa-0722-b3ac-9a6140488fad@zoho.com>
References: <57A2F6A3.9080908@zoho.com>
	<57A2FE7B.5070505@zoho.com>
	<20160804142421.576426492d629f0839298f9a@linux-foundation.org>
	<fc045ecf-20fa-0722-b3ac-9a6140488fad@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: tj@kernel.org, hannes@cmpxchg.org, mhocko@kernel.org, minchan@kernel.org, zijun_hu@htc.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 5 Aug 2016 23:48:21 +0800 zijun_hu <zijun_hu@zoho.com> wrote:

> From: zijun_hu <zijun_hu@htc.com>
> Date: Fri, 5 Aug 2016 22:10:07 +0800
> Subject: [PATCH 1/1] mm/vmalloc: fix align value calculation error
> 
> it causes double align requirement for __get_vm_area_node() if parameter
> size is power of 2 and VM_IOREMAP is set in parameter flags
> 
> get_order_long() is implemented and used instead of fls_long() for
> fixing the bug

Makes sense.  I think.

> --- a/include/linux/bitops.h
> +++ b/include/linux/bitops.h
> @@ -192,6 +192,23 @@ static inline unsigned fls_long(unsigned long l)
>  }
>  
>  /**
> + * get_order_long - get order after rounding @l up to power of 2
> + * @l: parameter
> + *
> + * it is same as get_count_order() but long type parameter
> + * or 0 is returned if @l == 0UL
> + */
> +static inline int get_order_long(unsigned long l)
> +{
> +	if (l == 0UL)
> +		return 0;
> +	else if (l & (l - 1UL))
> +		return fls_long(l);
> +	else
> +		return fls_long(l) - 1;
> +}
> +
> +/**
>   * __ffs64 - find first set bit in a 64 bit word
>   * @word: The 64 bit word
>   *
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 91f44e7..7d717f3 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1360,7 +1360,7 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
>  
>  	BUG_ON(in_interrupt());
>  	if (flags & VM_IOREMAP)
> -		align = 1ul << clamp_t(int, fls_long(size),
> +		align = 1ul << clamp_t(int, get_order_long(size),
>  				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
>  
>  	size = PAGE_ALIGN(size);

It would be better to call this get_count_order_long(), I think?  To
match get_count_order()?

get_count_order() is a weird name and perhaps both of these should be
renamed to things which actually make sense.  That's a separate issue.

--- a/include/linux/bitops.h~mm-vmalloc-fix-align-value-calculation-error-fix
+++ a/include/linux/bitops.h
@@ -75,6 +75,23 @@ static inline int get_count_order(unsign
 	return order;
 }
 
+/**
+ * get_count_order_long - get order after rounding @l up to power of 2
+ * @l: parameter
+ *
+ * The same as get_count_order() but accepts a long type parameter
+ * or 0 is returned if @l == 0UL
+ */
+static inline int get_count_order_long(unsigned long l)
+{
+	if (l == 0UL)
+		return 0;
+	else if (l & (l - 1UL))
+		return fls_long(l);
+	else
+		return fls_long(l) - 1;
+}
+
 static __always_inline unsigned long hweight_long(unsigned long w)
 {
 	return sizeof(w) == 4 ? hweight32(w) : hweight64(w);
@@ -192,23 +209,6 @@ static inline unsigned fls_long(unsigned
 }
 
 /**
- * get_order_long - get order after rounding @l up to power of 2
- * @l: parameter
- *
- * it is same as get_count_order() but long type parameter
- * or 0 is returned if @l == 0UL
- */
-static inline int get_order_long(unsigned long l)
-{
-	if (l == 0UL)
-		return 0;
-	else if (l & (l - 1UL))
-		return fls_long(l);
-	else
-		return fls_long(l) - 1;
-}
-
-/**
  * __ffs64 - find first set bit in a 64 bit word
  * @word: The 64 bit word
  *
--- a/mm/vmalloc.c~mm-vmalloc-fix-align-value-calculation-error-fix
+++ a/mm/vmalloc.c
@@ -1360,7 +1360,7 @@ static struct vm_struct *__get_vm_area_n
 
 	BUG_ON(in_interrupt());
 	if (flags & VM_IOREMAP)
-		align = 1ul << clamp_t(int, get_order_long(size),
+		align = 1ul << clamp_t(int, get_count_order_long(size),
 				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
 
 	size = PAGE_ALIGN(size);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

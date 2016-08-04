Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B74B6B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 17:24:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so480609089pfg.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 14:24:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 191si16405185pfz.229.2016.08.04.14.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 14:24:22 -0700 (PDT)
Date: Thu, 4 Aug 2016 14:24:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: fix align value calculation error
Message-Id: <20160804142421.576426492d629f0839298f9a@linux-foundation.org>
In-Reply-To: <57A2FE7B.5070505@zoho.com>
References: <57A2F6A3.9080908@zoho.com>
	<57A2FE7B.5070505@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: tj@kernel.org, hannes@cmpxchg.org, mhocko@kernel.org, minchan@kernel.org, zijun_hu@htc.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> 
> it causes double align requirement for __get_vm_area_node() if parameter
> size is power of 2 and VM_IOREMAP is set in parameter flags
> 
> it is fixed by handling the specail case manually due to lack of
> get_count_order() for long parameter
> 
> ...
>
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1357,11 +1357,16 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
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
> +		ioremap_size_order = fls_long(size);
> +		if (is_power_of_2(size) && size != 1)
> +			ioremap_size_order--;
> +		align = 1ul << clamp_t(int, ioremap_size_order, PAGE_SHIFT,
> +				IOREMAP_MAX_ORDER);
> +	}
>  
>  	size = PAGE_ALIGN(size);
>  	if (unlikely(!size))

I'm having trouble with this, and a more complete description would
have helped!

As far as I can tell, the current code will decide the following:

size=0x10000: alignment=0x10000
size=0x0f000: alignment=0x8000

And your patch will change it so that

size=0x10000: alignment=0x8000
size=0x0f000: alignment=0x8000

Correct?

If so, I'm struggling to see the sense in this.  Shouldn't we be
changing things so that

size=0x10000: alignment=0x10000
size=0x0f000: alignment=0x10000

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

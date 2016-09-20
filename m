Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92C1A6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 02:54:54 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id wk8so16830717pab.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 23:54:54 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id fn10si33522589pab.94.2016.09.19.23.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 23:54:53 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id q2so507625pfj.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 23:54:53 -0700 (PDT)
Date: Tue, 20 Sep 2016 16:54:41 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/3] mm/vmalloc: correct a few logic error in
 __insert_vmap_area()
Message-ID: <20160920165441.76e5a01b@roar.ozlabs.ibm.com>
In-Reply-To: <57E0D0F2.1060707@zoho.com>
References: <57E0D0F2.1060707@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zijun_hu@htc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Tue, 20 Sep 2016 14:02:26 +0800
zijun_hu <zijun_hu@zoho.com> wrote:

> From: zijun_hu <zijun_hu@htc.com>
> 
> correct a few logic error in __insert_vmap_area() since the else if
> condition is always true and meaningless
> 
> avoid endless loop under [un]mapping improper ranges whose boundary
> are not aligned to page
> 
> correct lazy_max_pages() return value if the number of online cpus
> is power of 2
> 
> improve performance for pcpu_get_vm_areas() via optimizing vmap_areas
> overlay checking algorithm and finding near vmap_areas by list_head
> other than rbtree
> 
> simplify /proc/vmallocinfo implementation via seq_file helpers
> for list_head
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> Signed-off-by: zijun_hu <zijun_hu@zoho.com>

Could you submit each of these changes as a separate patch? Would you
consider using capitalisation and punctuation in the changelog?

Did you measure any performance improvements, or do you have a workload
where vmalloc shows up in profiles?


> @@ -108,6 +108,9 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
>  	unsigned long next;
>  
>  	BUG_ON(addr >= end);
> +	WARN_ON(!PAGE_ALIGNED(addr | end));

I prefer to avoid mixing bitwise and arithmetic operations unless it's
necessary. Gcc should be able to optimise

WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end))

> +	addr = round_down(addr, PAGE_SIZE);

I don't know if it's really necessary to relax the API like this for
internal vmalloc.c functions. If garbage is detected here, it's likely
due to a bug, and I'm not sure that rounding it would solve the problem.

For API functions perhaps it's reasonable -- in such cases you should
consider using WARN_ON_ONCE() or similar.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

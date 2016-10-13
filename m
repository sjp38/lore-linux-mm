Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF926B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 19:29:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 128so93375339pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 16:29:05 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id sm7si13549727pab.73.2016.10.13.16.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 16:29:04 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id hh10so5337709pac.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 16:29:04 -0700 (PDT)
Date: Thu, 13 Oct 2016 19:29:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 PATCH] mm/percpu.c: fix panic triggered by BUG_ON()
 falsely
Message-ID: <20161013232902.GD32534@mtj.duckdns.org>
References: <57FCF07C.2020103@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FCF07C.2020103@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, cl@linux.com

On Tue, Oct 11, 2016 at 10:00:28PM +0800, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> as shown by pcpu_build_alloc_info(), the number of units within a percpu
> group is educed by rounding up the number of CPUs within the group to
> @upa boundary, therefore, the number of CPUs isn't equal to the units's
> if it isn't aligned to @upa normally. however, pcpu_page_first_chunk()
> uses BUG_ON() to assert one number is equal the other roughly, so a panic
> is maybe triggered by the BUG_ON() falsely.
> 
> in order to fix this issue, the number of CPUs is rounded up then compared
> with units's, the BUG_ON() is replaced by warning and returning error code
> as well to keep system alive as much as possible.

I really can't decode what the actual issue is here.  Can you please
give an example of a concrete case?

> @@ -2113,21 +2120,22 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
>  
>  	/* allocate pages */
>  	j = 0;
> -	for (unit = 0; unit < num_possible_cpus(); unit++)
> +	for (unit = 0; unit < num_possible_cpus(); unit++) {
> +		unsigned int cpu = ai->groups[0].cpu_map[unit];
>  		for (i = 0; i < unit_pages; i++) {
> -			unsigned int cpu = ai->groups[0].cpu_map[unit];
>  			void *ptr;
>  
>  			ptr = alloc_fn(cpu, PAGE_SIZE, PAGE_SIZE);
>  			if (!ptr) {
>  				pr_warn("failed to allocate %s page for cpu%u\n",
> -					psize_str, cpu);
> +						psize_str, cpu);

And stop making gratuitous changes?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id CBFB66B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 22:44:04 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id n5so4678392pfn.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:44:04 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id u86si622275pfa.250.2016.03.22.19.44.03
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 19:44:03 -0700 (PDT)
Date: Tue, 22 Mar 2016 19:44:02 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC] high preempt off latency in vfree path
Message-ID: <20160323024402.GA27856@tassilo.jf.intel.com>
References: <56F1F4A6.2060400@lab126.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56F1F4A6.2060400@lab126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@lab126.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-rt-users@vger.kernel.org, Nick Piggin <npiggin@suse.de>

> (1)
> One is we reduce the number of lazy_max_pages (right now its around 32MB per core worth of pages).
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index aa3891e..2720f4f 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -564,7 +564,7 @@ static unsigned long lazy_max_pages(void)
> 
>         log = fls(num_online_cpus());
> 
> -       return log * (32UL * 1024 * 1024 / PAGE_SIZE);
> +       return log * (8UL * 1024 * 1024 / PAGE_SIZE);
>  }

This seems like the right fix to me.  Perhaps even make it somewhat smaller.

Even on larger systems it's probably fine because they have a lot more
cores/threads these days, so it will be still sufficiently large.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

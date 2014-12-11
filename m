Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 945A86B006C
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 08:19:51 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id s7so3475139qap.22
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 05:19:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k10si1211817qge.43.2014.12.11.05.19.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 05:19:50 -0800 (PST)
Date: Thu, 11 Dec 2014 14:19:38 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
Message-ID: <20141211141938.6420b94a@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1412101136520.6639@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
	<CAOJsxLFEN_w7q6NvbxkH2KTujB9auLkQgskLnGtN9iBQ4hV9sw@mail.gmail.com>
	<alpine.DEB.2.11.1412101107350.6291@gentwo.org>
	<CAOJsxLH4BGT9rGgg_4nxUMgW3sdEzLrmX2WtM8Ld3aytdR5e8g@mail.gmail.com>
	<alpine.DEB.2.11.1412101136520.6639@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, brouer@redhat.com


On Wed, 10 Dec 2014 11:37:56 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:

[...]
> 
> There were some other issues so its now:
> 
> 
> Subject: slub: Do not use c->page on free
> 
> Avoid using the page struct address on free by just doing an
> address comparison. That is easily doable now that the page address
> is available in the page struct and we already have the page struct
> address of the object to be freed calculated.
> 
> Reviewed-by: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-12-10 11:35:32.538563734 -0600
> +++ linux/mm/slub.c	2014-12-10 11:36:39.032447807 -0600
> @@ -2625,6 +2625,17 @@ slab_empty:
>  	discard_slab(s, page);
>  }
> 
> +static bool is_pointer_to_page(struct page *page, void *p)
> +{
> +	long d = p - page->address;
> +
> +	/*
> +	 * Do a comparison for a MAX_ORDER page first before using
> +	 * compound_order() to determine the actual page size.
> +	 */
> +	return d >= 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
> +}

My current compiler (gcc 4.9.1), choose not to inline is_pointer_to_page().

 (perf record of [1])
 Samples: 8K of event 'cycles', Event count (approx.): 5737618489
 +   46.13%  modprobe  [kernel.kallsyms]  [k] kmem_cache_free
 +   33.02%  modprobe  [kernel.kallsyms]  [k] kmem_cache_alloc
 +   16.14%  modprobe  [kernel.kallsyms]  [k] is_pointer_to_page

If I explicitly add "inline", then it gets inlined, and performance is good again.

Test[1] cost of kmem_cache_alloc+free:
 * baseline: 47 cycles(tsc) 19.032 ns  (net-next without patchset)
 * patchset: 50 cycles(tsc) 20.028 ns
 * inline  : 45 cycles(tsc) 18.135 ns  (inlined is_pointer_to_page())


>  /*
>   * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
>   * can perform fastpath freeing without additional function calls.
> @@ -2658,7 +2669,7 @@ redo:
>  	tid = c->tid;
>  	preempt_enable();
> 
> -	if (likely(page == c->page)) {
> +	if (likely(is_pointer_to_page(page, c->freelist))) {
>  		set_freepointer(s, object, c->freelist);
> 
>  		if (unlikely(!this_cpu_cmpxchg_double(


[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_kmem_cache1.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

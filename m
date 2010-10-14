Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C124E6B0137
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 03:09:48 -0400 (EDT)
Message-ID: <4CB6ACB7.8060006@kernel.org>
Date: Thu, 14 Oct 2010 10:09:43 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] slub tracing: move trace calls out of always inlined
 functions to reduce kernel code size
References: <1286986178.1901.60.camel@castor.rsk>
In-Reply-To: <1286986178.1901.60.camel@castor.rsk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

  On 10/13/10 7:09 PM, Richard Kennedy wrote:
> Having the trace calls defined in the always inlined kmalloc functions
> in include/linux/slub_def.h causes a lot of code duplication as the
> trace functions get instantiated for each kamalloc call site. This can
> simply be removed by pushing the trace calls down into the functions in
> slub.c.
>
> On my x86_64 built this patch shrinks the code size of the kernel by
> approx 29K and also shrinks the code size of many modules -- too many to
> list here ;)
>
> size vmlinux.o reports
>         text	   data	    bss	    dec	    hex	filename
>      4777011	 602052	 763072	6142135	 5db8b7	vmlinux.o
>      4747120	 602388	 763072	6112580	 5d4544	vmlinux.o.patch

Impressive kernel text savings!

> index 13fffe1..32b89ee 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> +void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
> +{
> +	void *ret = (void *) __get_free_pages(flags | __GFP_COMP, order);
> +
> +	kmemleak_alloc(ret, size, 1, flags);
> +	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE<<  order, flags);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(kmalloc_order);
> +
This doesn't make sense to be out-of-line for the !CONFIG_TRACE case. 
I'd just wrap that with "#ifdef CONFIG_TRACE" and put an inline version 
in the header for !TRACE.

             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

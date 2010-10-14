Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9D4B76B00CC
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 05:49:34 -0400 (EDT)
Subject: Re: [PATCH] [RFC] slub tracing: move trace calls out of always
 inlined functions to reduce kernel code size
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <4CB6ACB7.8060006@kernel.org>
References: <1286986178.1901.60.camel@castor.rsk>
	 <4CB6ACB7.8060006@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Oct 2010 10:49:29 +0100
Message-ID: <1287049769.1909.4.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-10-14 at 10:09 +0300, Pekka Enberg wrote:
> On 10/13/10 7:09 PM, Richard Kennedy wrote:
> > Having the trace calls defined in the always inlined kmalloc functions
> > in include/linux/slub_def.h causes a lot of code duplication as the
> > trace functions get instantiated for each kamalloc call site. This can
> > simply be removed by pushing the trace calls down into the functions in
> > slub.c.
> >
> > On my x86_64 built this patch shrinks the code size of the kernel by
> > approx 29K and also shrinks the code size of many modules -- too many to
> > list here ;)
> >
> > size vmlinux.o reports
> >         text	   data	    bss	    dec	    hex	filename
> >      4777011	 602052	 763072	6142135	 5db8b7	vmlinux.o
> >      4747120	 602388	 763072	6112580	 5d4544	vmlinux.o.patch
> 
> Impressive kernel text savings!
> 
> > index 13fffe1..32b89ee 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > +void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
> > +{
> > +	void *ret = (void *) __get_free_pages(flags | __GFP_COMP, order);
> > +
> > +	kmemleak_alloc(ret, size, 1, flags);
> > +	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE<<  order, flags);
> > +
> > +	return ret;
> > +}
> > +EXPORT_SYMBOL(kmalloc_order);
> > +
> This doesn't make sense to be out-of-line for the !CONFIG_TRACE case. 
> I'd just wrap that with "#ifdef CONFIG_TRACE" and put an inline version 
> in the header for !TRACE.
> 
>              Pekka

Yes, OK I'll do that.
regards
Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B67516B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:07:43 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BF98582C3CC
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:24:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NTOg1IQju7UB for <linux-mm@kvack.org>;
	Thu, 18 Jun 2009 10:24:09 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AB14D82C3A7
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:24:09 -0400 (EDT)
Date: Thu, 18 Jun 2009 10:07:38 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu
 operations
In-Reply-To: <4A39ADBF.1000505@kernel.org>
Message-ID: <alpine.DEB.1.10.0906181001420.15556@gentwo.org>
References: <20090617203337.399182817@gentwo.org> <20090617203444.731295080@gentwo.org> <4A39ADBF.1000505@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009, Tejun Heo wrote:

> > +#define __this_cpu_read(pcp)		percpu_from_op("mov", pcp)
>                                                              ^^^^
> 					              missing parentheses
> and maybe adding () around val is a good idea too?

() around pcp right.

> Also, I'm not quite sure these macros would operate on the correct
> address.  Checking... yeap, the following function,
>
>  DEFINE_PER_CPU(int, my_pcpu_cnt);
>  void my_func(void)
>  {
> 	 int *ptr = &per_cpu__my_pcpu_cnt;
>
> 	 *(int *)this_cpu_ptr(ptr) = 0;
> 	 this_cpu_add(ptr, 1);

Needs to be this_cpu_add(*ptr, 1). this_cpu_add does not take a pointer
to an int but a lvalue. The typical use case is with a struct. I.e.

struct {
	int x;
} * ptr = &per_cpu_var(m_cpu_pnt);

then do

this_cpu_add(ptr->x, 1)


> 	 percpu_add(my_pcpu_cnt, 1);
>  }
>
> So, this_cpu_add(ptr, 1) ends up accessing the wrong address.  Also,
> please note the use of 'addq' instead of 'addl' as the pointer
> variable is being modified.

You incremented the pointer instead of the value pointed to. Look at the
patches that use this_cpu_add(). You pass the object to be incremented not
a pointer. If the convention would be different then the address would
have to be taken of these objects everywhere.

> > +#define irqsafe_cpu_add(pcp, val)	percpu_to_op("add", (pcp), val)
> > +#define irqsafe_cpu_sub(pcp, val)	percpu_to_op("sub", (pcp), val)
> > +#define irqsafe_cpu_and(pcp, val)	percpu_to_op("and", (pcp), val)
> > +#define irqsafe_cpu_or(pcp, val)	percpu_to_op("or", (pcp), val)
> > +#define irqsafe_cpu_xor(pcp, val)	percpu_to_op("xor", (pcp), val)
>
> Wouldn't it be clearer / easier to define preempt and irqsafe versions
> as aliases of __ prefixed ones?

Ok will do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

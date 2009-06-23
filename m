Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EBBB16B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:58:52 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0602F82C603
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:17:37 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Wtiky4vtSvD7 for <linux-mm@kvack.org>;
	Tue, 23 Jun 2009 14:17:36 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D9F3682C607
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:17:30 -0400 (EDT)
Date: Tue, 23 Jun 2009 14:00:26 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu
 operations
In-Reply-To: <200906191511.50690.rusty@rustcorp.com.au>
Message-ID: <alpine.DEB.1.10.0906231353260.3680@gentwo.org>
References: <20090617203337.399182817@gentwo.org> <alpine.DEB.1.10.0906181134440.26369@gentwo.org> <4A3A65F7.6070404@kernel.org> <200906191511.50690.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net
List-ID: <linux-mm.kvack.org>


> > Functionally, there's no practical difference but it's just weird to
> > use scalar as input/output parameter.  All the atomic and bitops
> > operations are taking pointers.  In fact, there are only very few
> > which take lvalue input and modify it, so I think it would be much
> > better to take pointers like normal C functions and macros for the
> > sake of consistency.
>
> Absolutely agreed here; C is pass by value and any use of macros to violate
> that is abhorrent.  Let's not spread the horro of cpus_* or local_irq_save()!

All of those take a definite type. this_cpu takes an arbitrary type like
the existing percpu operations.

What you are suggesting would lead to strange results.

now

int a;

a = this_cpu_read(struct->a)

Both the result and argument are of the same type.

you suggest

a = this_cpu_read(&struct->a)

also

this_cpu_write(struct->a, a)

vs.

this_cpu_write(&struct->a, a)

Precedent for an lvalue exists in the percpu operations that work exactly
like this. Why would this_cpu deviate from that? The first parameter must
always be an assignable variable either statically allocated or
dynamically.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

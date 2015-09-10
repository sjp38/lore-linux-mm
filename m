Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1976B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 13:21:50 -0400 (EDT)
Received: by qgt47 with SMTP id 47so41211287qgt.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 10:21:49 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id g78si14105107qhc.132.2015.09.10.10.21.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Sep 2015 10:21:48 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 10 Sep 2015 11:21:47 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0C22E3E40087
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:21:46 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8AHKd8T44040370
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 10:20:39 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8AHLjss015244
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:21:45 -0600
Date: Thu, 10 Sep 2015 10:13:33 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Message-ID: <20150910171333.GD4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
 <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
 <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, Sep 10, 2015 at 11:55:35AM +0200, Dmitry Vyukov wrote:
> On Thu, Sep 10, 2015 at 1:31 AM, Christoph Lameter <cl@linux.com> wrote:
> > On Wed, 9 Sep 2015, Paul E. McKenney wrote:
> >
> >> Either way, Dmitry's tool got a hit on real code using the slab
> >> allocators.  If that hit is a false positive, then clearly Dmitry
> >> needs to fix his tool, however, I am not (yet) convinced that it is a
> >> false positive.  If it is not a false positive, we might well need to
> >> articulate the rules for use of the slab allocators.
> >
> > Could I get a clear definiton as to what exactly is positive? Was this
> > using SLAB, SLUB or SLOB?
> >
> >> > This would all use per cpu data. As soon as a handoff is required within
> >> > the allocators locks are being used. So I would say no.
> >>
> >> As in "no, it is not necessary for the caller of kfree() to invoke barrier()
> >> in this example", right?
> >
> > Actually SLUB contains a barrier already in kfree(). Has to be there
> > because of the way the per cpu pointer is being handled.
> 
> The positive was reporting of data races in the following code:
> 
> // kernel/pid.c
>          if ((atomic_read(&pid->count) == 1) ||
>               atomic_dec_and_test(&pid->count)) {
>                  kmem_cache_free(ns->pid_cachep, pid);
>                  put_pid_ns(ns);
>          }
> 
> //drivers/tty/tty_buffer.c
> while ((next = buf->head->next) != NULL) {
>      tty_buffer_free(port, buf->head);
>      buf->head = next;
> }
> 
> Namely, the tool reported data races between usage of the object in
> other threads before they released the object and kfree.
> 
> I am not sure why we are so concentrated on details like SLAB vs SLUB
> vs SLOB or cache coherency protocols. This looks like waste of time to
> me. General kernel code should not be safe only when working with SLxB
> due to current implementation details of SLxB, it should be safe
> according to memory allocator contract. And this contract seem to be:
> memory allocator can do arbitrary reads and writes to the object
> inside of kmalloc and kfree.

The reason we poked at this was to see if any of SLxB touched the
memory being freed.  If none of them touched the memory being freed,
and if that was a policy, then the idiom above would be legal.  However,
one of them does touch the memory being freed, so, yes, the above code
needs to be fixed.

> Similarly for memory model. There is officially documented kernel
> memory model, which all general kernel code must adhere to. Reasoning
> about whether a particular piece of code works on architecture X, or
> how exactly it can break on architecture Y in unnecessary in such
> context. In the end, there can be memory allocator implementation and
> new architectures.
> 
> My question is about contracts, not about current implementation
> details or specific architectures.
> 
> There are memory allocator implementations that do reads and writes of
> the object, and there are memory allocator implementations that do not
> do any barriers on fast paths. From this follows that objects must be
> passed in quiescent state to kfree.
> Now, kernel memory model says "A load-load control dependency requires
> a full read memory barrier".
> >From this follows that the following code is broken:
> 
> // kernel/pid.c
>          if ((atomic_read(&pid->count) == 1) ||
>               atomic_dec_and_test(&pid->count)) {
>                  kmem_cache_free(ns->pid_cachep, pid);
>                  put_pid_ns(ns);
>          }
> 
> and it should be:
> 
> // kernel/pid.c
>          if ((smp_load_acquire(&pid->count) == 1) ||

If Will Deacon's patch providing generic support for relaxed atomics
made it in, we want:

	  if ((atomic_read_acquire(&pid->count) == 1) ||

Otherwise, we need an explicit barrier.

							Thanx, Paul

>               atomic_dec_and_test(&pid->count)) {
>                  kmem_cache_free(ns->pid_cachep, pid);
>                  put_pid_ns(ns);
>          }
> 
> 
> 
> -- 
> Dmitry Vyukov, Software Engineer, dvyukov@google.com
> Google Germany GmbH, Dienerstrasse 12, 80331, Munchen
> Geschaftsfuhrer: Graham Law, Christine Elizabeth Flores
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg
> Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat
> sind, leiten Sie diese bitte nicht weiter, informieren Sie den
> Absender und loschen Sie die E-Mail und alle Anhange. Vielen Dank.
> This e-mail is confidential. If you are not the right addressee please
> do not forward it, please inform the sender, and please erase this
> e-mail including any attachments. Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

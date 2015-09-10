Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 430C36B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:43:04 -0400 (EDT)
Received: by qgev79 with SMTP id v79so31144939qge.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 03:43:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 87si12730165qkx.83.2015.09.10.03.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 03:43:03 -0700 (PDT)
Date: Thu, 10 Sep 2015 12:42:53 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Message-ID: <20150910124253.6000cc77@redhat.com>
In-Reply-To: <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
	<alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
	<CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
	<alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
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
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: brouer@redhat.com, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, 10 Sep 2015 11:55:35 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:

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
> From this follows that the following code is broken:
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
>               atomic_dec_and_test(&pid->count)) {
>                  kmem_cache_free(ns->pid_cachep, pid);
>                  put_pid_ns(ns);
>          }
> 

This reminds me of some code in the network stack[1] in kfree_skb()
where we have a smp_rmb().  Should we have used smp_load_acquire() ?

 void kfree_skb(struct sk_buff *skb)
 {
	if (unlikely(!skb))
		return;
	if (likely(atomic_read(&skb->users) == 1))
		smp_rmb();
	else if (likely(!atomic_dec_and_test(&skb->users)))
		return;
	trace_kfree_skb(skb, __builtin_return_address(0));
	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(kfree_skb);

[1] https://github.com/torvalds/linux/blob/v4.2-rc8/net/core/skbuff.c#L690

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

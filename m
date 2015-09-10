Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5006E6B0256
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 08:48:02 -0400 (EDT)
Received: by lagj9 with SMTP id j9so27408110lag.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 05:48:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2si19338187wjz.43.2015.09.10.05.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 05:48:00 -0700 (PDT)
Subject: Re: Is it OK to pass non-acquired objects to kfree?
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F17BFE.8080008@suse.cz>
Date: Thu, 10 Sep 2015 14:47:58 +0200
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On 09/10/2015 11:55 AM, Dmitry Vyukov wrote:
> On Thu, Sep 10, 2015 at 1:31 AM, Christoph Lameter <cl@linux.com> wrote:
>> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
>>
>>> Either way, Dmitry's tool got a hit on real code using the slab
>>> allocators.  If that hit is a false positive, then clearly Dmitry
>>> needs to fix his tool, however, I am not (yet) convinced that it is a
>>> false positive.  If it is not a false positive, we might well need to
>>> articulate the rules for use of the slab allocators.
>>
>> Could I get a clear definiton as to what exactly is positive? Was this
>> using SLAB, SLUB or SLOB?
>>
>>> > This would all use per cpu data. As soon as a handoff is required within
>>> > the allocators locks are being used. So I would say no.
>>>
>>> As in "no, it is not necessary for the caller of kfree() to invoke barrier()
>>> in this example", right?
>>
>> Actually SLUB contains a barrier already in kfree(). Has to be there
>> because of the way the per cpu pointer is being handled.
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

[...]

> There are memory allocator implementations that do reads and writes of
> the object, and there are memory allocator implementations that do not
> do any barriers on fast paths. From this follows that objects must be
> passed in quiescent state to kfree.
> Now, kernel memory model says "A load-load control dependency requires
> a full read memory barrier".

But a load-load dependency is something different than writes from
kmem_cache_free() being visible before the atomic_read(), right?

So the problem you are seeing is a different one, that some other cpu's are
still writing to the object after they decrese the count to 1?.

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

Is that enough? Doesn't it need a pairing smp_store_release?

>               atomic_dec_and_test(&pid->count)) {

A prior release from another thread (that sets the counter to 1) would be done
by this atomic_dec_and_test() (this all is put_pid() function).
Does that act as a release? memory-barriers.txt seems to say it does.

So yeah your patch seems to be needed and I don't think it should be the sl*b
providing the necessary barrier here. It should be on the refcounting IMHO. That
has the knowledge of correct ordering depending on the pid->count, sl*b has no
such knowledge.

>                  kmem_cache_free(ns->pid_cachep, pid);
>                  put_pid_ns(ns);
>          }
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

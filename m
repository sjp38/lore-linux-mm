Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id ECA656B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 10:13:47 -0400 (EDT)
Received: by qgev79 with SMTP id v79so83097903qge.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 07:13:47 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id v33si3804918qgv.107.2015.09.08.07.13.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 07:13:46 -0700 (PDT)
Date: Tue, 8 Sep 2015 09:13:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, 8 Sep 2015, Dmitry Vyukov wrote:

> The question arose during work on KernelThreadSanitizer, a kernel data
> race, and in particular caused by the following existing code:
>
> // kernel/pid.c
>          if ((atomic_read(&pid->count) == 1) ||
>               atomic_dec_and_test(&pid->count)) {
>                  kmem_cache_free(ns->pid_cachep, pid);
>                  put_pid_ns(ns);
>          }

It frees when there the refcount is one? Should this not be

	if (atomic_read(&pid->count) === 0) || ...

>
> //drivers/tty/tty_buffer.c
> while ((next = buf->head->next) != NULL) {
>      tty_buffer_free(port, buf->head);
>      buf->head = next;
> }
> // Here another thread can concurrently append to the buffer list, and
> tty_buffer_free eventually calls kfree.
>
> Both these cases don't contain proper memory barrier before handing
> off the object to kfree. In my opinion the code should use
> smp_load_acquire or READ_ONCE_CTRL ("control-dependnecy-acquire").
> Otherwise there can be pending memory accesses to the object in other
> threads that can interfere with slab code or the next usage of the
> object after reuse.

There can be pending reads maybe? But a write would require exclusive
acccess to the cachelines.


> Paul McKenney suggested that:
>
> "
> The maintainers probably want this sort of code to be allowed:
>         p->a++;
>         if (p->b) {
>                 kfree(p);
>                 p = NULL;
>         }
> And the users even more so.


Sure. What would be the problem with the above code? The write to the
object (p->a++) results in exclusive access to a cacheline being obtained.
So one cpu holds that cacheline. Then the object is freed and reused
either

1. On the same cpu -> No problem.

2. On another cpu. This means that a hand off of the pointer to the object
occurs in the slab allocators. The hand off involves a spinlock and thus
implicit barriers. The other processor will acquire exclusive access to
the cacheline when it initializes the object. At that point the cacheline
ownership will transfer between the processors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

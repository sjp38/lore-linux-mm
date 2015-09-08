Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9B25F6B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 11:13:08 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so79463654igb.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:13:08 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id l17si3446866ioe.73.2015.09.08.08.13.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 08:13:07 -0700 (PDT)
Date: Tue, 8 Sep 2015 10:13:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com> <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, 8 Sep 2015, Dmitry Vyukov wrote:

> >>
> >> // kernel/pid.c
> >>          if ((atomic_read(&pid->count) == 1) ||
> >>               atomic_dec_and_test(&pid->count)) {
> >>                  kmem_cache_free(ns->pid_cachep, pid);
> >>                  put_pid_ns(ns);
> >>          }
> >
> > It frees when there the refcount is one? Should this not be
> >
> >         if (atomic_read(&pid->count) === 0) || ...
>
> The code is meant to do decrement of pid->count, but since
> pid->count==1 it figures out that it is the only owner of the object,
> so it just skips the "pid->count--" part and proceeds directly to
> free.

The atomic_dec_and_test will therefore not be executed for count == 1?
Strange code. The atomic_dec_and_test suggests there are concurrency
concerns. The count test with a simple comparison does not share these
concerns it seems.

> >> The maintainers probably want this sort of code to be allowed:
> >>         p->a++;
> >>         if (p->b) {
> >>                 kfree(p);
> >>                 p = NULL;
> >>         }
> >> And the users even more so.
> >
> >
> > Sure. What would be the problem with the above code? The write to the
> > object (p->a++) results in exclusive access to a cacheline being obtained.
> > So one cpu holds that cacheline. Then the object is freed and reused
> > either
>
> I am not sure what cache line states has to do with it...
> Anyway, another thread can do p->c++ after this thread does p->a++,
> then this thread loses its ownership. Or p->c can be located on a
> separate cache line with p->a. And then we still free the object with
> a pending write.

The subsystem must ensure no other references exist before a call to free.
So this cannot occur. If it does then these are cases of an object being
used after free which can be caught by a number of diagnostic tools in the
kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

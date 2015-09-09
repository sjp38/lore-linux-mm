Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFC96B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 13:56:22 -0400 (EDT)
Received: by ioii196 with SMTP id i196so31429554ioi.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 10:56:22 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id j202si7061200ioj.32.2015.09.09.10.56.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 10:56:21 -0700 (PDT)
Date: Wed, 9 Sep 2015 12:56:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com> <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com> <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
 <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com> <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org> <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com> <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org>
 <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com> <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com> <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Wed, 9 Sep 2015, Dmitry Vyukov wrote:

> > Guess this means that cachelines (A) may not have been be written back to
> > memory when the pointer to the object is written to another cacheline(B)
> > and that cacheline B arrives at the other processor first which has
> > outdated cachelines A in its cache? So the other processor uses the
> > contents of B to get to the pointer to A but then accesses outdated
> > information since the object contents cachelines (A) have not arrive there
> > yet?
>
> That's one example.
> Another example will be that kfree reads size from the object _before_
> the object to the pointer is read. That sounds crazy, but it as
> actually possible on Alpha processors.

The size is encoded in the kmem_cache structure which is not changed. How
can that be relevant?

> Another example will be that C compiler lets a store to the object in
> kmalloc sink below the store of the pointer to the object into global.

Well if the pointer is used nakedly to communicate between threads the
barriers need to be used but what does this have to do with slabs?

> > Ok lets say that is the case then any write attempt to A results in an
> > exclusive cacheline state and at that point the cacheline is going to
> > reflect current contents. So if kfree would write to the object then it
> > will have the current information.
>
> No, because store to the object can still be pending on another CPU.

That would violate the cache coherency protocol as far as I can tell?

> So kfree can get the object in E state in cache, but then another CPU
> will finally issue the store and overwrite the slab freelist.

Sounds like a broken processor design to me. AFAICT the MESI protocol does
not allow this.

> > Also what does it matter for kfree since the contents of the object are no
> > longer in use?
>
> I don't understand. First, it is not "not in use" infinitely, it can
> be in use the very next moment. Also, we don't want corruption of slab
> freelist as well. And we don't want spurious failure of debug
> allocator that checks that there no writes after free.

Slab freelists are protected by locks.

A processor that can randomly defer writes to cachelines in the face of
other processors owning cachelines exclusively does not seem sane to me.
In fact its no longer exclusive.

> > Could you please come up with a concrete example where there is
> > brokenness that we need to consider.
>
> Well, both examples in the first email are broken according to all of
> Documentation/memory-barriers.txt, Alpha processor manual and C
> standard (assuming that object passed to kfree must be in "quiescent"
> state).
> If you want a description of an exact scenario of how it can break:
> building of freelist in kfree can be hoisted above check of
> atomic_read(&pid->count) == 1 on Alpha processors, then the freelist
> can become corrupted.

Sounds like the atomic_read needs more barriers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

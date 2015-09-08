Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 619906B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 13:09:09 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so125763898ioi.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 10:09:09 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id f194si3794678ioe.72.2015.09.08.10.09.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 10:09:08 -0700 (PDT)
Date: Tue, 8 Sep 2015 12:09:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com> <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com> <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
 <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com> <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org> <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, 8 Sep 2015, Dmitry Vyukov wrote:

> >> I would expect that this is illegal code. Is my understanding correct?
> >
> > This should work. It could be a problem if thread 1 is touching
> > the object.
>
> What does make it work?

The 2nd thread gets the pointer that the first allocated and frees it.
If there is no more processing then fine.

> There are clearly memory barriers missing when passing the object
> between threads. The typical correct pattern is:

Why? If thread 2 gets the pointer it frees it. Thats ok.

> // thread 1
> smp_store_release(&p, kmalloc(8));
>
> // thread 2
> void *r = smp_load_acquire(&p); // or READ_ONCE_CTRL
> if (r)
>   kfree(r);
>
> Otherwise stores into the object in kmalloc can reach the object when
> it is already freed, which is a use-after-free.

Ok so there is more code executing in thread #1. That changes things.
>
> What does prevent the use-after-free?

There is no access to p in the first thread. If there are such accesses
then they are illegal. A user of slab allocators must ensure that there
are no accesses after freeing the object. And since there is a thread
that  at random checks p and frees it when not NULL then no other thread
would be allowed to touch the object.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

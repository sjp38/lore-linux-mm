Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 293016B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 19:23:14 -0400 (EDT)
Received: by qgez77 with SMTP id z77so22200635qge.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 16:23:13 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id z93si10624560qkg.87.2015.09.09.16.23.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 16:23:13 -0700 (PDT)
Date: Wed, 9 Sep 2015 18:23:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
In-Reply-To: <20150909203642.GO4029@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org>
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com> <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com> <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com> <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, 9 Sep 2015, Paul E. McKenney wrote:

> > > > A processor that can randomly defer writes to cachelines in the face of
> > > > other processors owning cachelines exclusively does not seem sane to me.
> > > > In fact its no longer exclusive.
> > >
> > > Welcome to the wonderful world of store buffers, which are present even
> > > on strongly ordered systems such as x86 and the mainframe.
> >
> > Store buffers hold complete cachelines that have been written to by a
> > processor.
>
> In many cases, partial cachelines.  If the cacheline is not available
> locally, the processor cannot know the contents of the rest of the cache
> line, only the contents of the portion that it recently stored into.

For a partial cacheline it would have to read the rest of the cacheline
before updating. And I would expect the processor to have exclusive access
to the cacheline that is held in a store buffer. If not then there is
trouble afoot.


> >            Hmmm... Guess I need to think more about this. Dont know the
> > detail here on how they interact with cacheline exclusivity and stuff.
>
> A large number of stores to the same variable can happen concurrently,
> and the system can stitch together the order of these stores after
> the fact.

Well thats what I know. The exact way the store buffers interact with
cache coherency is what I do not know.

>
> > > > Sounds like the atomic_read needs more barriers.
> > >
> > > We all know that this won't happen.
> >
> > Well then welcome to the wonderful world of a broken kernel. Still
> > wondering what this has to do with slab allocators.
>
> The concern I have is that the compiler might be able to reorder the
> running CPU's last accesses to an object that is to be kfree()ed with
> kfree()'s accesses.  The issue being that the compiler is within its
> rights to assume pointers to different types don't alias unless one of the
> types is char * (or some such, Dmitry can correct me if I am confused).

Hmmm... Yeah if one assumes that the object is going to be handled by a
different processor then that is a valid concern but if its on the same
processor then the guarantee is that the changes become visible to the
exeucting thread in program order. That is enough.

The transfer to another processor is guarded by locks and I think that
those are enough to ensure that the cachelines become visible in a
controlled fashion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

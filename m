Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id DF0E26B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 20:08:52 -0400 (EDT)
Received: by oiww128 with SMTP id w128so15514659oiw.2
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 17:08:52 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id p189si5943850oif.132.2015.09.09.17.08.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Sep 2015 17:08:52 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 9 Sep 2015 18:08:51 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 8E9981FF0046
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 17:59:58 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8A05pjq45416482
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 17:05:51 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8A08mD2027446
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 18:08:49 -0600
Date: Wed, 9 Sep 2015 17:08:47 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
Message-ID: <20150910000847.GV4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
 <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, Sep 09, 2015 at 06:23:11PM -0500, Christoph Lameter wrote:
> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
> 
> > > > > A processor that can randomly defer writes to cachelines in the face of
> > > > > other processors owning cachelines exclusively does not seem sane to me.
> > > > > In fact its no longer exclusive.
> > > >
> > > > Welcome to the wonderful world of store buffers, which are present even
> > > > on strongly ordered systems such as x86 and the mainframe.
> > >
> > > Store buffers hold complete cachelines that have been written to by a
> > > processor.
> >
> > In many cases, partial cachelines.  If the cacheline is not available
> > locally, the processor cannot know the contents of the rest of the cache
> > line, only the contents of the portion that it recently stored into.
> 
> For a partial cacheline it would have to read the rest of the cacheline
> before updating. And I would expect the processor to have exclusive access
> to the cacheline that is held in a store buffer. If not then there is
> trouble afoot.

Yep.  The store buffer would hold part of the cacheline, gain exclusive
access to that cacheline, then update it.

> > >            Hmmm... Guess I need to think more about this. Dont know the
> > > detail here on how they interact with cacheline exclusivity and stuff.
> >
> > A large number of stores to the same variable can happen concurrently,
> > and the system can stitch together the order of these stores after
> > the fact.
> 
> Well thats what I know. The exact way the store buffers interact with
> cache coherency is what I do not know.

That would vary among systems and be highly optimized.

> > > > > Sounds like the atomic_read needs more barriers.
> > > >
> > > > We all know that this won't happen.
> > >
> > > Well then welcome to the wonderful world of a broken kernel. Still
> > > wondering what this has to do with slab allocators.
> >
> > The concern I have is that the compiler might be able to reorder the
> > running CPU's last accesses to an object that is to be kfree()ed with
> > kfree()'s accesses.  The issue being that the compiler is within its
> > rights to assume pointers to different types don't alias unless one of the
> > types is char * (or some such, Dmitry can correct me if I am confused).
> 
> Hmmm... Yeah if one assumes that the object is going to be handled by a
> different processor then that is a valid concern but if its on the same
> processor then the guarantee is that the changes become visible to the
> exeucting thread in program order. That is enough.

The CPU is indeed constrained in this way, but the compiler is not.
In particular, the CPU must do exact alias analysis, while the compiler
is permitted to do approximate alias analysis in some cases.  However,
in gcc builds of the Linux kernel, I believe that the -fno-strict-aliasing
gcc command-line argument forces exact alias analysis.

Dmitry, anything that I am missing?

> The transfer to another processor is guarded by locks and I think that
> those are enough to ensure that the cachelines become visible in a
> controlled fashion.

For the kfree()-to-kmalloc() path, I do believe that you are correct.
Dmitry's question was leading up to the kfree().

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

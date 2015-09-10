Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id E197A6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 20:21:35 -0400 (EDT)
Received: by ioii196 with SMTP id i196so42164964ioi.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 17:21:35 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id h142si8095937ioh.159.2015.09.09.17.21.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 17:21:35 -0700 (PDT)
Date: Wed, 9 Sep 2015 19:21:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
In-Reply-To: <20150910000847.GV4029@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1509091917560.22381@east.gentwo.org>
References: <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com> <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org> <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com> <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org> <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org> <20150910000847.GV4029@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, 9 Sep 2015, Paul E. McKenney wrote:

> The CPU is indeed constrained in this way, but the compiler is not.
> In particular, the CPU must do exact alias analysis, while the compiler
> is permitted to do approximate alias analysis in some cases.  However,
> in gcc builds of the Linux kernel, I believe that the -fno-strict-aliasing
> gcc command-line argument forces exact alias analysis.
>
> Dmitry, anything that I am missing?
>
> > The transfer to another processor is guarded by locks and I think that
> > those are enough to ensure that the cachelines become visible in a
> > controlled fashion.
>
> For the kfree()-to-kmalloc() path, I do believe that you are correct.
> Dmitry's question was leading up to the kfree().

The kmalloc-to-kfree path has similar bounds that ensure correctness.
First of all it is the availability of the pointer and the transfer of the
contents of the pointer to a remove processor.

Strictly speaking the processor would violate the rule that there cannnot
be a memory access to the object after kfree is called if the compiler
would move a store into kfree().

But then again kfree() contains a barrier() which would block the compiler
from moving anything into the free path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

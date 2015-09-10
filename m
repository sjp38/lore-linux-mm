Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id C0F6C6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 21:10:33 -0400 (EDT)
Received: by oiev17 with SMTP id v17so16129477oie.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 18:10:33 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id 5si6064781oid.50.2015.09.09.18.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Sep 2015 18:10:32 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 9 Sep 2015 19:10:32 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6FB211FF0042
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 19:01:39 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8A19NZt55443572
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 18:09:23 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8A1ATo9004616
	for <linux-mm@kvack.org>; Wed, 9 Sep 2015 19:10:29 -0600
Date: Wed, 9 Sep 2015 18:10:28 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
Message-ID: <20150910011028.GY4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
 <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org>
 <20150910000847.GV4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091917560.22381@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509091917560.22381@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, Sep 09, 2015 at 07:21:34PM -0500, Christoph Lameter wrote:
> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
> 
> > The CPU is indeed constrained in this way, but the compiler is not.
> > In particular, the CPU must do exact alias analysis, while the compiler
> > is permitted to do approximate alias analysis in some cases.  However,
> > in gcc builds of the Linux kernel, I believe that the -fno-strict-aliasing
> > gcc command-line argument forces exact alias analysis.
> >
> > Dmitry, anything that I am missing?
> >
> > > The transfer to another processor is guarded by locks and I think that
> > > those are enough to ensure that the cachelines become visible in a
> > > controlled fashion.
> >
> > For the kfree()-to-kmalloc() path, I do believe that you are correct.
> > Dmitry's question was leading up to the kfree().
> 
> The kmalloc-to-kfree path has similar bounds that ensure correctness.
> First of all it is the availability of the pointer and the transfer of the
> contents of the pointer to a remove processor.
> 
> Strictly speaking the processor would violate the rule that there cannnot
> be a memory access to the object after kfree is called if the compiler
> would move a store into kfree().
> 
> But then again kfree() contains a barrier() which would block the compiler
> from moving anything into the free path.

That barrier() is implicit in the fact that kfree() is an external
function?  Or are my eyes failing me?

But yes, a barrier() seems to me to suffice in this situation.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

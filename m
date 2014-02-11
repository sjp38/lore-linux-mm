Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6F98C6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:01:40 -0500 (EST)
Received: by mail-oa0-f48.google.com with SMTP id l6so9165723oag.7
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 07:01:40 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id tk7si9659419obc.107.2014.02.11.07.01.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 07:01:39 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 11 Feb 2014 08:01:39 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D2A141FF003F
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:01:35 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1BF1Z8I1704238
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:01:35 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s1BF4uK5022213
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:04:57 -0700
Date: Tue, 11 Feb 2014 07:01:13 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Memory allocator semantics
Message-ID: <20140211150113.GS4250@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <52F60699.8010204@iki.fi>
 <alpine.DEB.2.10.1402101304110.17517@nuc>
 <20140211121426.GQ4250@linux.vnet.ibm.com>
 <CAOJsxLET90NRnEKeFjWKWTgZm+otSSwfCkhFga2hGjhV12nz9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLET90NRnEKeFjWKWTgZm+otSSwfCkhFga2hGjhV12nz9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

On Tue, Feb 11, 2014 at 03:20:01PM +0200, Pekka Enberg wrote:
> On Tue, Feb 11, 2014 at 2:14 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > In contrast, from kfree() to a kmalloc() returning some of the kfree()ed
> > memory, I believe the kfree()/kmalloc() implementation must do any needed
> > synchronization and ordering.  But that is a different set of examples,
> > for example, this one:
> >
> >         CPU 0                   CPU 1
> >         p->a = 42;              q = kmalloc(...); /* returning p */
> >         kfree(p);               q->a = 5;
> >                                 BUG_ON(q->a != 5);
> >
> > Unlike the situation with (A), (B), and (C), in this case I believe
> > that it is kfree()'s and kmalloc()'s responsibility to ensure that
> > the BUG_ON() never triggers.
> >
> > Make sense?
> 
> I'm not sure...
> 
> It's the caller's responsibility not to touch "p" after it's handed over to
> kfree() - otherwise that's a "use-after-free" error.  If there's some reordering
> going on here, I'm tempted to blame the caller for lack of locking.

But if the two callers are unrelated, what locking can they possibly use?

>From what I can see, the current implementation prevents the above
BUG_ON() from firing.  If the two CPUs are the same, the CPU will see its
own accesses in order, while if they are different, the implementation
will have had to push the memory through non-CPU-local data structures,
which must have had some heavyweight protection.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

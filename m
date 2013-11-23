Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id 851876B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 23:05:15 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so1664695qeb.6
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 20:05:15 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id a12si25386445qeg.101.2013.11.22.20.05.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 20:05:14 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 22 Nov 2013 21:05:13 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id AEB021FF001A
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 21:04:51 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAN23ALl61931566
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 03:03:10 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAN483kC023762
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 21:08:05 -0700
Date: Fri, 22 Nov 2013 20:05:07 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131123040507.GI4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131122200620.GA4138@linux.vnet.ibm.com>
 <CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
 <20131122203738.GC4138@linux.vnet.ibm.com>
 <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
 <20131122215208.GD4138@linux.vnet.ibm.com>
 <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
 <20131123002542.GF4138@linux.vnet.ibm.com>
 <CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
 <20131123013654.GG4138@linux.vnet.ibm.com>
 <CA+55aFyJRAX4e9H0AFGcPMrBBTmGC6K_iCCS3dc7Mx6ejTmYMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyJRAX4e9H0AFGcPMrBBTmGC6K_iCCS3dc7Mx6ejTmYMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 06:11:52PM -0800, Linus Torvalds wrote:
> On Fri, Nov 22, 2013 at 5:36 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > So there is your example.  It really can and does happen.
> >
> > Again, easy fix.  Just change powerpc's smp_store_release() from lwsync
> > to smp_mb().  That fixes the problem and doesn't hurt anyone but powerpc.
> >
> > OK?
> 
> Hmm. Ok
> 
> Except now I'm worried it can happen on x86 too because my mental
> model was clearly wrong.
> 
> x86 does have that extra "Memory ordering obeys causality (memory
> ordering respects transitive visibility)." rule, and the example in
> the architecture manual (section 8.2.3.6 "Stores Are Transitively
> Visible") seems to very much about this, but your particular example
> is subtly different, so..

Indeed, my example needs CPU 1's -load- from y to be transitively visible,
so I am nervous about this one as well.

> I will have to ruminate on this.

The rules on the left-hand column of page 5 of the below URL apply to
this example more straightforwardly, but I don't know that Intel and
AMD stand behind them:

	http://www.cl.cam.ac.uk/~pes20/weakmemory/cacm.pdf

My guess is that x86 does guarantee this ordering, but at this point I
would have to ask someone from Intel and AMD.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

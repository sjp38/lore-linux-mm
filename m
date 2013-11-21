Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 53B7A6B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 16:53:23 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id l4so287756qcv.18
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 13:53:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id e10si20644896qar.83.2013.11.21.13.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Nov 2013 13:53:22 -0800 (PST)
Date: Thu, 21 Nov 2013 22:52:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <20131121110308.GC10022@twins.programming.kicks-ass.net>
 <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
 <20131121172558.GA27927@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131121172558.GA27927@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 09:25:58AM -0800, Paul E. McKenney wrote:
> I am still thinking not, at least for x86, given Section 8.2.2 of
> "Intel(R) 64 and IA-32 Architectures Developer's Manual: Vol. 3A"
> dated March 2013 from:
>
> http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.html
>
> Also from Sewell et al. "x86-TSO: A Rigorous and Usable Programmer's
> Model for x86 Multiprocessors" in 2010 CACM.

Should be this one:

  http://www.cl.cam.ac.uk/~pes20/weakmemory/cacm.pdf

And the rules referenced below are on page 5; left-hand column.

> Let's apply the Intel manual to the earlier example:
>
>	CPU 0		CPU 1			CPU 2
>	-----		-----			-----
>	x = 1;		r1 = SLA(lock);		y = 1;
>	SSR(lock, 1);	r2 = y;			smp_mb();
>						r3 = x;
>
>	assert(!(r1 == 1 && r2 == 0 && r3 == 0));
>
> Let's try applying this to x86:
>
> o	Stores from a given processor are ordered, so everyone
>	agrees that CPU 0's store to x happens before the store-release
>	to lock.
>
> o	Reads from a given processor are ordered, so everyone agrees
>	that CPU 1's load from lock precedes its load from y.
>
> o	Because r1 == 1, we know that CPU 0's store to lock happened
>	before CPU 1's load from lock.
>
> o	Causality (AKA transitive visibility) means that everyone
>	agrees that CPU 0's store to x happens before CPU 1's load
>	from y.  (This is a crucial point, so it would be good to
>	have confirmation/debunking from someone who understands
>	the x86 architecture better than I do.)
>
> o	CPU 2's memory barrier prohibits CPU 2's store to y from
>	being reordered with its load from x.
>
> o	Because r2 == 0, we know that CPU 1's load from y happened
>	before CPU 2's store to y.
>
> o	At this point, it looks to me that (r1 == 1 && r2 == 0)
>	implies r3 == 1.
>
> Sewell's model plays out as follows:
>
> o	Rule 2 never applies in this example because no processor
>	is reading its own write.
>
> o	Rules 3 and 4 force CPU 0's writes to be seen in order.
>
> o	Rule 1 combined with the ordered-instruction nature of
>	the model force CPU 1's reads to happen in order.
>
> o	Rule 4 means that if r1 == 1, CPU 0's write to x is
>	globally visible before CPU 1 loads from y.
>
> o	The fact that r2 == 0 combined with rules 1, 3, and 4
>	mean that CPU 1's load from y happens before CPU 2 makes
>	its store to y visible.
>
> o	Rule 5 means that CPU 1 cannot execute its load from x
>	until it has made its store to y globally visible.
>
> o	Therefore, when CPU 2 executes its load from x, CPU 0's
>	store to x must be visible, ruling out r3 == 0, and
>	preventing the assertion from firing.
>
> The other three orderings would play out similarly.  (These are read
> before lock release and read after subsequent lock acquisition, read
> before lock release and write after subsequent lock acquisition, and
> read before lock release and read after subsequent lock acquisition.)
>
> But before chasing those down, is the analysis above sound?

I _think_ so.. but its late. I'm also struggling to find where lwsync
goes bad in this story, because as you say lwsync does all except flush
the store buffer, which sounds like TSO.. but clearly is not quite the
same.

For one TSO has multi-copy atomicity, whereas ARM/PPC do not have this.

The explanation of lwsync given in 3.3 of 'A Tutorial Introduction to
the ARM and POWER Relaxed Memory Models'

  http://www.cl.cam.ac.uk/~pes20/ppc-supplemental/test7.pdf

Leaves me slightly puzzled as to the exact differences between the 2 WW
variants.

Anyway, hopefully a little sleep will cure some of my confusion,
otherwise I'll try and confuse you more tomorrow ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

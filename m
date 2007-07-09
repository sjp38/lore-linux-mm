Received: from krystal.dyndns.org ([76.65.100.197])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20070709225817.QCWK13659.tomts13-srv.bellnexxia.net@krystal.dyndns.org>
          for <linux-mm@kvack.org>; Mon, 9 Jul 2007 18:58:17 -0400
Date: Mon, 9 Jul 2007 18:58:17 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality, performance and maintenance
Message-ID: <20070709225817.GA5111@Krystal>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de> <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com> <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com> <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal> <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter (clameter@sgi.com) wrote:
> On Mon, 9 Jul 2007, Mathieu Desnoyers wrote:
> 
> > > >He seems to be comparing spinlock acquire / release vs. cmpxchg. So I 
> > > >guess you got your material from somewhere else?
> > > >
> > 
> > I ran a test specifically for this paper where I got this result
> > comparing the local irq enable/disable to local cmpxchg.
> 
> 
> The numbers are pretty important and suggest that we can obtain 
> a significant speed increase by avoid local irq disable enable in the slab 
> allocator fast paths. Do you some more numbers? Any other publication that 
> mentions these?
> 

The original publication in which I released the idea was my LTTng paper
at OLS 2006. Outside this, I have not found other paper that talks about
this idea.

The test code is basically just disabling interrupts, reading the TSC
at the beginning and end and does 20000 loops of local_cmpxchg. I can
send you the code if you want it.

> 
> > Yep, I volountarily used the variant without lock prefix because the
> > data is per cpu and I disable preemption.
> 
> local_cmpxchg generates this?
> 

Yes.

> > Yes, preempt disabling or, eventually, the new thread migration
> > disabling I just proposed as an RFC on LKML. (that would make -rt people
> > happier)
> 
> Right.
> 
> > Sure, also note that the UP cmpxchg (see asm-$ARCH/local.h in 2.6.22) is
> > faster on architectures like powerpc and MIPS where it is possible to
> > remove some memory barriers.
> 
> UP cmpxchg meaning local_cmpxchg?
> 

Yes.

> > See 2.6.22 Documentation/local_ops.txt for a thorough discussion. Don't
> > hesitate ping me if you have more questions.
> 
> That is pretty thin and does not mention atomic_cmpxchg. You way want to 
> expand on your ideas a bit.

Sure, the idea goes as follow: if you have a per cpu variable that needs
to be concurrently modified in a coherent manner by any context (NMI,
irq, bh, process) running on the given CPU, you only need to use an
operation atomic wrt to the given CPU. You just have to make sure that
only this CPU will modify the variable (therefore, you must disable
preemption around modification) and you have to make sure that the
read-side, which can come from any CPU, is accessing this variable
atomically. Also, you have to be aware that the read-side might see an
older version of the other cpu's value because there is no SMP write
memory barrier involved. The value, however, will always be up to date
if the variable is read from the "local" CPU.

What applies to local_inc, given as example in the local_ops.txt
document, applies integrally to local_cmpxchg. And I would say that
local_cmpxchg is by far the cheapest locking mechanism I have found, and
use today, for my kernel tracer. The idea emerged from my need to trace
every execution context, including NMIs, while still providing good
performances. local_cmpxchg was the perfect fit; that's why I deployed
it in local.h in each and every architecture.

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

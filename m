Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 744216B0023
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 08:59:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c65so1382681pfa.5
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 05:59:48 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0061.outbound.protection.outlook.com. [104.47.36.61])
        by mx.google.com with ESMTPS id 1-v6si3609708plj.275.2018.03.28.05.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 05:59:47 -0700 (PDT)
Date: Wed, 28 Mar 2018 15:59:32 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Message-ID: <20180328125932.dhzwoxhext4h7hgh@yury-thinkpad>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-3-ynorov@caviumnetworks.com>
 <20180326085313.GA4016@andrea>
 <20180326145735.57ba306b@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180326145735.57ba306b@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 26, 2018 at 02:57:35PM -0400, Steven Rostedt wrote:
> On Mon, 26 Mar 2018 10:53:13 +0200
> Andrea Parri <andrea.parri@amarulasolutions.com> wrote:
> 
> > > --- a/kernel/smp.c
> > > +++ b/kernel/smp.c
> > > @@ -724,6 +724,30 @@ void kick_all_cpus_sync(void)
> > >  }
> > >  EXPORT_SYMBOL_GPL(kick_all_cpus_sync);
> > >  
> > > +/**
> > > + * kick_active_cpus_sync - Force CPUs that are not in extended
> > > + * quiescent state (idle or nohz_full userspace) sync by sending
> > > + * IPI. Extended quiescent state CPUs will sync at the exit of
> > > + * that state.
> > > + */
> > > +void kick_active_cpus_sync(void)
> > > +{
> > > +	int cpu;
> > > +	struct cpumask kernel_cpus;
> > > +
> > > +	smp_mb();  
> > 
> > (A general remark only:)
> > 
> > checkpatch.pl should have warned about the fact that this barrier is
> > missing an accompanying comment (which accesses are being "ordered",
> > what is the pairing barrier, etc.).
> 
> He could have simply copied the comment above the smp_mb() for
> kick_all_cpus_sync():
> 
> 	/* Make sure the change is visible before we kick the cpus */
> 
> The kick itself is pretty much a synchronization primitive.
> 
> That is, you make some changes and then you need all CPUs to see it,
> and you call: kick_active_cpus_synch(), which is the barrier to make
> sure you previous changes are seen on all CPUS before you proceed
> further. Note, the matching barrier is implicit in the IPI itself.
>
>  -- Steve

I know that I had to copy the comment from kick_all_cpus_sync(), but I
don't like copy-pasting in general, and as Steven told, this smp_mb() is
already inside synchronization routine, so we may hope that users of
kick_*_cpus_sync() will explain better what for they need it...
 
> 
> > 
> > Moreover if, as your reply above suggested, your patch is relying on
> > "implicit barriers" (something I would not recommend) then even more
> > so you should comment on these requirements.
> > 
> > This could: (a) force you to reason about the memory ordering stuff,
> > (b) easy the task of reviewing and adopting your patch, (c) easy the
> > task of preserving those requirements (as implementations changes).
> > 
> >   Andrea

I need v2 anyway, and I will add comments to address all questions in this
thread.

I also hope that we'll agree that for powerpc it's also safe to delay
synchronization, and if so, we will have no users of kick_all_cpus_sync(),
and can drop it.

(It looks like this, because nohz_full userspace CPU cannot have pending
IPIs, but I'd like to get confirmation from powerpc people.)

Would it make sense to rename kick_all_cpus_sync() to smp_mb_sync(), which
would stand for 'synchronous memory barrier on all online CPUs'?

Yury

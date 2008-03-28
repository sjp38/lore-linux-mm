Date: Fri, 28 Mar 2008 15:24:30 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 8/8] x86_64: Support for new UV apic
Message-ID: <20080328202430.GA13040@sgi.com>
References: <20080328191216.GA16455@sgi.com> <20080328201532.GB26555@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080328201532.GB26555@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 28, 2008 at 09:15:32PM +0100, Ingo Molnar wrote:
> 
> * Jack Steiner <steiner@sgi.com> wrote:
> 
> > Index: linux/arch/x86/kernel/apic_64.c
> > ===================================================================
> > --- linux.orig/arch/x86/kernel/apic_64.c	2008-03-28 13:00:22.000000000 -0500
> > +++ linux/arch/x86/kernel/apic_64.c	2008-03-28 13:06:12.000000000 -0500
> > @@ -738,6 +738,7 @@ void __cpuinit setup_local_APIC(void)
> >  	unsigned int value;
> >  	int i, j;
> >  
> > +	preempt_disable();
> >  	value = apic_read(APIC_LVR);
> >  
> >  	BUILD_BUG_ON((SPURIOUS_APIC_VECTOR & 0x0f) != 0x0f);
> > @@ -831,6 +832,7 @@ void __cpuinit setup_local_APIC(void)
> >  	else
> >  		value = APIC_DM_NMI | APIC_LVT_MASKED;
> >  	apic_write(APIC_LVT1, value);
> > +	preempt_enable();
> >  }
> 
> hm, this looks a bit weird - why are all the preempt-disable/enable 
> calls needed?

The first patch had a preempt disable/enable in the function
that reads apicid (see read_apic_id() in arch/x86/kernel/genapic_64.c).
This seemed necessary since large system generate an apicid by reading
the live id & concatenating it with extra bits.

One of the review comments suggested that I change the preempt to a WARN()
since reading apic_id really should be done with preemtion disabled. The
added code eliminates the warnings.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

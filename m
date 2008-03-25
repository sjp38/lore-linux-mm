Date: Tue, 25 Mar 2008 11:31:03 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080325163103.GA2651@sgi.com>
References: <20080324182122.GA28327@sgi.com> <20080325143059.GB11323@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325143059.GB11323@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 03:30:59PM +0100, Ingo Molnar wrote:
> 
> * Jack Steiner <steiner@sgi.com> wrote:
> 
> > Index: linux/arch/x86/kernel/genapic_64.c
> 
> > @@ -69,7 +73,16 @@ void send_IPI_self(int vector)
> >  
> >  unsigned int get_apic_id(void)
> >  {
> > -	return (apic_read(APIC_ID) >> 24) & 0xFFu;
> > +	unsigned int id;
> > +
> > +	preempt_disable();
> > +	id = apic_read(APIC_ID);
> > +	if (uv_system_type >= UV_X2APIC)
> > +		id  |= __get_cpu_var(x2apic_extra_bits);
> > +	else
> > +		id = (id >> 24) & 0xFFu;;
> > +	preempt_enable();
> > +	return id;
> 
> dont we want to put get_apic_id() into struct genapic instead? We 
> already have ID management there.
> 
> also, we want to unify 32-bit and 64-bit genapic code and just have 
> genapic all across x86.

Long term, I think that makes sense. However, I think that should be a
separate series of patches since there are significant differences between
the 32-bit and 64-bit genapic structs.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

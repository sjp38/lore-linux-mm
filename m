Date: Fri, 4 Jul 2003 11:47:03 -0400 (EDT)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
In-Reply-To: <7910000.1057333295@[10.10.2.4]>
Message-ID: <Pine.LNX.4.53.0307041139150.24383@montezuma.mastecende.com>
References: <20030703023714.55d13934.akpm@osdl.org> <3F054109.2050100@aitel.hist.no>
 <20030704093531.GA26348@holomorphy.com> <20030704095004.GB26348@holomorphy.com>
 <7910000.1057333295@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jul 2003, Martin J. Bligh wrote:

> Is it really necessary to turn half the apic code upside down in order
> to fix this? What's the actual bugfix that's buried in this cleanup?

The way i see it is that you can't use NR_CPUS to determine the upper 
bound on APIC IDs. e.g. my 3way is normally configured with NR_CPUS = 3 
but has APIC IDs of 0, 3 and 4. We need to make a distinction.

> Despite the fact you seem to have gone out of your way to make this
> hard to review, there are a few things I can see that strike me as odd.
> Not necessarily wrong, but requiring more explanation.
> 
> > -			if (i >= 0xf)
> > +			if (i >= APIC_BROADCAST_ID)
> 
> Is that always correct? it's not equivalent.

Well we really want APIC_MAX_ID (or whatever it's called)

> > -	for (bit = 0; kicked < NR_CPUS && bit < 8*sizeof(cpumask_t); bit++) {
> > +	for (bit = 0; kicked < NR_CPUS && bit < MAX_APICS; bit++) {
> 
> Is that the actual one-line bugfix this is all about?

No, the problem is no space for physical ids in cpumask bitmaps, this 
could manifest itself later on unless we fix it now.

> > -#define APIC_BROADCAST_ID     (0x0f)
> > +#define APIC_BROADCAST_ID     (0xff)
> 
> So ... you've tested that change on a bigsmp machine, right? 
> At least, provide some reasoning here. Like this comment further down the
> patch ...

That one is slightly worrying, yes.

> > + * this isn't really broadcast, just a (potentially inaccurate) upper
> > + * bound for valid physical APIC id's
> 
> Which makes the change just look wrong to me. If you're thinking 
> "physical clustered mode" that terminology just utterly confusing crap, 
> and the change is wrong, as far as I can see. 
> 
> > +++ physid-2.5.74-1/include/asm-i386/mach-numaq/mach_apic.h	
> > 2003-07-04 02:45:17.000000000 -0700
> >
> > -static inline cpumask_t apicid_to_cpu_present(int logical_apicid)
> > +static inline physid_mask_t apicid_to_cpu_present(int logical_apicid)
> >  {
> >  	int node = apicid_to_node(logical_apicid);
> >  	int cpu = __ffs(logical_apicid & 0xf);
> >  
> > -	return cpumask_of_cpu(cpu + 4*node);
> > +	return physid_mask_of_physid(cpu + 4*node);
> >  }
> 
> Hmmmm. What are you using physical apicids here for? They seem
> irrelevant to this function. 

Urgh, it's really hard to determine what these functions really want half 
the time. But that change does look wrong.

	Zwane
-- 
function.linuxpower.ca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Tue, 25 Mar 2008 12:56:57 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080325175657.GA6262@sgi.com>
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87abknhzhd.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 11:25:34AM +0100, Andi Kleen wrote:
> Jack Steiner <steiner@sgi.com> writes:
> 
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
> Really caller should have done preempt_disable(), otherwise
> the value can be wrong as soon as you return.
> 
> Better probably to just WARN_ON if preemption is on

Will do (assuming it doesn't ripple thru too much code eliminating
warnings - doesn't look bad at first glance).


> 
> (just be careful it does not trigger in oopses and machine checks)
> 
> > +
> > +DEFINE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
> > +EXPORT_PER_CPU_SYMBOL(__uv_hub_info);
> 
> GPL export too?

Yes.


> 
> > +
> > +struct uv_blade_info *uv_blade_info;
> > +EXPORT_SYMBOL_GPL(uv_blade_info);
> > +
> > +short *uv_node_to_blade;
> > +EXPORT_SYMBOL_GPL(uv_node_to_blade);
> > +
> > +short *uv_cpu_to_blade;
> > +EXPORT_SYMBOL_GPL(uv_cpu_to_blade);
> > +
> > +short uv_possible_blades;
> > +EXPORT_SYMBOL_GPL(uv_possible_blades);
> > +
> > +/* Start with all IRQs pointing to boot CPU.  IRQ balancing will shift them. */
> > +/* Probably incorrect for UV  ZZZ */
> 
> Actually it should be correct. Except for UV you likely really need a
> NUMA aware irqbalanced. I used to have some old very hackish patches
> to implement that in irqbalanced, but never pushed it because the
> systems I was working on didn't really need it.

Deleted comment.

> 
> 
> > +
> > +static void uv_send_IPI_one(int cpu, int vector)
> > +{
> > +	unsigned long val, apicid;
> > +	int nasid;
> > +
> > +	apicid = per_cpu(x86_cpu_to_apicid, cpu); /* ZZZ - cache node-local ? */
> 
> Instead of doing that it might be better to implement __read_mostly per CPU variables
> (should not be very hard) 

Added to list of loose-ends that need addressing.


> 
> > +static void uv_send_IPI_mask(cpumask_t mask, int vector)
> > +{
> > +	unsigned long flags;
> > +	unsigned int cpu;
> > +
> > +	local_irq_save(flags);
> > +	for (cpu = 0; cpu < NR_CPUS; ++cpu)
> > +		if (cpu_isset(cpu, mask))
> > +			uv_send_IPI_one(cpu, vector);
> > +	local_irq_restore(flags);
> 
> This could disable interrupts for a long time could't it?  Really needed?

No, not sure why I did that. Deleted the irq disable...


> 
> 
> > +	bytes = sizeof(struct uv_blade_info) * uv_num_possible_blades();
> > +	uv_blade_info = alloc_bootmem_pages(bytes);
> > +	memset(uv_blade_info, 255, bytes);
> 
> 255?  Strange poison value.

Deleted the memset. Should not be depending on poison values. Was useful
in debugging but it has outlived it's usefulness.


> 
> > ===================================================================
> > --- linux.orig/arch/x86/kernel/Makefile	2008-03-21 15:36:35.000000000 -0500
> > +++ linux/arch/x86/kernel/Makefile	2008-03-21 15:49:38.000000000 -0500
> > @@ -90,7 +90,7 @@ scx200-y			+= scx200_32.o
> >  ###
> >  # 64 bit specific files
> >  ifeq ($(CONFIG_X86_64),y)
> > -        obj-y				+= genapic_64.o genapic_flat_64.o
> > +        obj-y				+= genapic_64.o genapic_flat_64.o genx2apic_uv_x.o
> 
> Definitely should be a CONFIG

Not sure that I understand why. The overhead of UV is minimal & we want UV
enabled in all distro kernels. OTOH, small embedded systems probably want to
eliminate every last bit of unneeded code.

Might make sense to have a config option. Thoughts????


> 
> > @@ -418,6 +419,9 @@ static int __cpuinit wakeup_secondary_vi
> >  	unsigned long send_status, accept_status = 0;
> >  	int maxlvt, num_starts, j;
> >  
> > +	if (get_uv_system_type() == UV_NON_UNIQUE_APIC)
> > +		return uv_wakeup_secondary(phys_apicid, start_rip);
> > +
> 
> This should be probably factored properly (didn't Jeremy have smp_ops 
> for this some time ago) so that even the default case is a call.

By factored, do you means something like:
	is_uv_legacy_system()
	is_us_non_unique_apicid_system()
	...

Or maybe:
	is_uv_system_type(x)   # where x is UV_NON_UNIQUE_APIC, etc


> -Andi

Thanks for the careful review.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

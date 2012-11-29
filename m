Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 95E896B004D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 03:34:28 -0500 (EST)
Date: Thu, 29 Nov 2012 10:34:25 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [RFC][PATCH 2/2] fix kvm's use of __pa() on percpu areas
Message-ID: <20121129083425.GN928@redhat.com>
References: <20121129005355.966BD487@kernel.stglabs.ibm.com>
 <20121129005356.186166B0@kernel.stglabs.ibm.com>
 <20121129074730.GL928@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121129074730.GL928@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Avi Kivity <avi@redhat.com>

On Thu, Nov 29, 2012 at 09:47:30AM +0200, Gleb Natapov wrote:
> On Thu, Nov 29, 2012 at 12:53:56AM +0000, Dave Hansen wrote:
> > 
> > In short, it is illegal to call __pa() on an address holding
> > a percpu variable.  The times when this actually matters are
> > pretty obscure (certain 32-bit NUMA systems), but it _does_
> > happen.  It is important to keep KVM guests working on these
> > systems because the real hardware is getting harder and
> > harder to find.
> > 
> > This bug manifested first by me seeing a plain hang at boot
> > after this message:
> > 
> > 	CPU 0 irqstacks, hard=f3018000 soft=f301a000
> > 
> > or, sometimes, it would actually make it out to the console:
> > 
> > [    0.000000] BUG: unable to handle kernel paging request at ffffffff
> > 
> > I eventually traced it down to the KVM async pagefault code.
> > This can be worked around by disabling that code either at
> > compile-time, or on the kernel command-line.
> > 
> > The kvm async pagefault code was injecting page faults in
> > to the guest which the guest misinterpreted because its
> > "reason" was not being properly sent from the host.
> > 
> > The guest passes a physical address of an per-cpu async page
> > fault structure via an MSR to the host.  Since __pa() is
> > broken on percpu data, the physical address it sent was
> > bascially bogus and the host went scribbling on random data.
> > The guest never saw the real reason for the page fault (it
> > was injected by the host), assumed that the kernel had taken
> > a _real_ page fault, and panic()'d.
> > 
> > Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> > ---
> > 
> >  linux-2.6.git-dave/arch/x86/kernel/kvm.c |    9 +++++----
> >  1 file changed, 5 insertions(+), 4 deletions(-)
> > 
> > diff -puN arch/x86/kernel/kvm.c~fix-kvm-__pa-use-on-percpu-areas arch/x86/kernel/kvm.c
> > --- linux-2.6.git/arch/x86/kernel/kvm.c~fix-kvm-__pa-use-on-percpu-areas	2012-11-29 00:39:59.130213376 +0000
> > +++ linux-2.6.git-dave/arch/x86/kernel/kvm.c	2012-11-29 00:51:55.428091802 +0000
> > @@ -284,9 +284,9 @@ static void kvm_register_steal_time(void
> >  
> >  	memset(st, 0, sizeof(*st));
> >  
> > -	wrmsrl(MSR_KVM_STEAL_TIME, (__pa(st) | KVM_MSR_ENABLED));
> > +	wrmsrl(MSR_KVM_STEAL_TIME, (slow_virt_to_phys(st) | KVM_MSR_ENABLED));
> Where is this slow_virt_to_phys() coming from? I do not find it in
> kvm.git.
> 
Disregard this.  1/2 didn't make it to my mailbox.

> >  	printk(KERN_INFO "kvm-stealtime: cpu %d, msr %lx\n",
> > -		cpu, __pa(st));
> > +		cpu, slow_virt_to_phys(st));
> >  }
> >  
> >  static DEFINE_PER_CPU(unsigned long, kvm_apic_eoi) = KVM_PV_EOI_DISABLED;
> > @@ -311,7 +311,7 @@ void __cpuinit kvm_guest_cpu_init(void)
> >  		return;
> >  
> >  	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF) && kvmapf) {
> > -		u64 pa = __pa(&__get_cpu_var(apf_reason));
> > +		u64 pa = slow_virt_to_phys(&__get_cpu_var(apf_reason));
> >  
> >  #ifdef CONFIG_PREEMPT
> >  		pa |= KVM_ASYNC_PF_SEND_ALWAYS;
> > @@ -327,7 +327,8 @@ void __cpuinit kvm_guest_cpu_init(void)
> >  		/* Size alignment is implied but just to make it explicit. */
> >  		BUILD_BUG_ON(__alignof__(kvm_apic_eoi) < 4);
> >  		__get_cpu_var(kvm_apic_eoi) = 0;
> > -		pa = __pa(&__get_cpu_var(kvm_apic_eoi)) | KVM_MSR_ENABLED;
> > +		pa = slow_virt_to_phys(&__get_cpu_var(kvm_apic_eoi))
> > +			| KVM_MSR_ENABLED;
> >  		wrmsrl(MSR_KVM_PV_EOI_EN, pa);
> >  	}
> >  
> > _
> 
> --
> 			Gleb.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

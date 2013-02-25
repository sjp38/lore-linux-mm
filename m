Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id BA17F6B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 03:30:44 -0500 (EST)
Date: Mon, 25 Feb 2013 10:30:39 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 0/5] [v3] fix illegal use of __pa() in KVM code
Message-ID: <20130225083039.GB21422@redhat.com>
References: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
 <1361741338.21499.38.camel@thor.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361741338.21499.38.camel@thor.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

On Sun, Feb 24, 2013 at 04:28:58PM -0500, Peter Hurley wrote:
> 
> On Tue, 2013-01-22 at 13:24 -0800, Dave Hansen wrote:
> > This series fixes a hard-to-debug early boot hang on 32-bit
> > NUMA systems.  It adds coverage to the debugging code,
> > adds some helpers, and eventually fixes the original bug I
> > was hitting.
> 
> Hi Dave,
> 
> Now that the alloc_remap() has been/is being removed, is most/all of
> this being reverted?
> 
> I ask because I was fixing a different bug in KVM's para-virt clock and
> saw part of this series (from [PATCH 5/5] fix kvm's use of __pa() on
> percpu areas):
> 
> diff -puN arch/x86/kernel/kvmclock.c~fix-kvm-__pa-use-on-percpu-areas arch/x86/kernel/kvmclock.c
> --- linux-2.6.git/arch/x86/kernel/kvmclock.c~fix-kvm-__pa-use-on-percpu-areas   2013-01-22 13:17:16.428317508 -0800
> +++ linux-2.6.git-dave/arch/x86/kernel/kvmclock.c       2013-01-22 13:17:16.432317541 -0800
> @@ -162,8 +162,8 @@ int kvm_register_clock(char *txt)
>         int low, high, ret;
>         struct pvclock_vcpu_time_info *src = &hv_clock[cpu].pvti;
>  
> -       low = (int)__pa(src) | 1;
> -       high = ((u64)__pa(src) >> 32);
> +       low = (int)slow_virt_to_phys(src) | 1;
> +       high = ((u64)slow_virt_to_phys(src) >> 32);
>         ret = native_write_msr_safe(msr_kvm_system_time, low, high);
>         printk(KERN_INFO "kvm-clock: cpu %d, msr %x:%x, %s\n",
>                cpu, high, low, txt);
> 
I think this hunk was converted by mistake since the code does not use
per cpu allocations, but since __pa() and slow_virt_to_phys() should
return the same thing here it does not matter much.

> which confused me because hv_clock is the __va of allocated physical
> memory, not a per-cpu variable.
> 
> 	mem = memblock_alloc(size, PAGE_SIZE);
> 	if (!mem)
> 		return;
> 	hv_clock = __va(mem);
> 
> So in short, my questions are:
> 1) is the slow_virt_to_phys() necessary anymore?
> 2) if yes, does it apply to the code above?
> 3) if yes, would you explain in more detail what the 32-bit NUMA mm is
> doing, esp. wrt. when __va(__pa) is not identical across all cpus?
> 
> Regards,
> Peter Hurley
> 

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

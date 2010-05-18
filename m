Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 81EEA6003C2
	for <linux-mm@kvack.org>; Tue, 18 May 2010 05:11:21 -0400 (EDT)
Date: Tue, 18 May 2010 17:03:00 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [RFC,5/7] NUMA hotplug emulator
Message-ID: <20100518090300.GA26178@shaohui>
References: <20100513121457.GJ2169@shaohui>
 <20100514054928.GC12002@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100514054928.GC12002@linux-sh.org>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 02:49:28PM +0900, Paul Mundt wrote:
> On Thu, May 13, 2010 at 08:14:57PM +0800, Shaohui Zheng wrote:
> > hotplug emulator: support cpu probe/release in x86
> > 
> > Add cpu interface probe/release under sysfs for x86. User can use this
> > interface to emulate the cpu hot-add process, it is for cpu hotplug 
> > test purpose. Add a kernel option CONFIG_ARCH_CPU_PROBE_RELEASE for this
> > feature.
> > 
> > This interface provides a mechanism to emulate cpu hotplug with software
> >  methods, it becomes possible to do cpu hotplug automation and stress
> > testing.
> > 
> At a quick glance, is this really necessary? It seems like you could
> easily replace most of this with a CPU notifier chain that takes care of
> the node handling. See for example how ppc64 manages the CPU hotplug/numa
> emulation case in arch/powerpc/mm/numa.c. arch_register_cpu() just looks
> like some topology hack for ACPI, it would be nice not to perpetuate that
> too much.

Paul,
	When we reivew the possible solutions for the emulator, we already do some researching
for ppc hotplug interface, I did not has ppc background, so it is hard for me to understand
all the details, but we get clues indeed, so you see the emulator today.

	We are *NOT* expecting to find simple way to probe a CPU, we are trying to emulate the
 behavior with software methods, we expect the same result when we do same operation on real
  hardware and emualtor. That is the reason why we did not selelct CPU notifier chain, you can
   see the CPU probe process is almost the same with CPU physical hot-add, the only difference
is that some functions are replaced with a '_emu' suffix, these '_emu' function has the same
 function with the old one, but it does not refer to any acpi_handle data since the hot-add
event is fake.

 for exmaple:
	 register_cpu & register_cpu_emu
	 arch_register_cpu & arch_register_cpu_emu
	 acpi_map_lsapic & acpi_map_lsapic_emu

	the nid and apic_id are parsed from the acpi_handle, but for a fake hot-add, we does not 
has such data, so we delete the parser code and replace them with a parameter.

	I believe you method can success probe a CPU, but it is obvious different with the CPU hot-add
process, it has the different behavior with the real hardware, it is not expect. that is the failure
 of the emulation.

	ppc does not care about the ACPI data, that is the reason why it seems to be simple.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

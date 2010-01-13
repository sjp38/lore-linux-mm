Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 88BBE6B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 21:29:53 -0500 (EST)
Date: Wed, 13 Jan 2010 10:29:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel(v1)
Message-ID: <20100113022948.GD10184@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com> <20100108124851.GB6153@localhost> <DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com> <20100111124303.GA21408@localhost> <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com> <20100112023307.GA16661@localhost> <20100112113903.89163c46.kamezawa.hiroyu@jp.fujitsu.com> <20100112133556.GB7647@localhost> <86802c441001121501v57b61815lc4b4c6d86dc5818d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <86802c441001121501v57b61815lc4b4c6d86dc5818d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yinghai@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 13, 2010 at 07:01:47AM +0800, Yinghai Lu wrote:
> On Tue, Jan 12, 2010 at 5:35 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Tue, Jan 12, 2010 at 10:39:03AM +0800, KAMEZAWA Hiroyuki wrote:
> >> On Tue, 12 Jan 2010 10:33:08 +0800
> >> Wu Fengguang <fengguang.wu@intel.com> wrote:
> >>
> >> > Sure, here it is :)
> >> > ---
> >> > x86: use the generic page_is_ram()
> >> >
> >> > The generic resource based page_is_ram() works better with memory
> >> > hotplug/hotremove. So switch the x86 e820map based code to it.
> >> >
> >> > CC: Andi Kleen <andi@firstfloor.org>
> >> > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> >>
> >> Ack.
> >
> > Thank you.
> >
> >>
> >> > +#ifdef CONFIG_X86
> >> > + A  /*
> >> > + A  A * A special case is the first 4Kb of memory;
> >> > + A  A * This is a BIOS owned area, not kernel ram, but generally
> >> > + A  A * not listed as such in the E820 table.
> >> > + A  A */
> >> > + A  if (pfn == 0)
> >> > + A  A  A  A  A  return 0;
> >> > +
> >> > + A  /*
> >> > + A  A * Second special case: Some BIOSen report the PC BIOS
> >> > + A  A * area (640->1Mb) as ram even though it is not.
> >> > + A  A */
> >> > + A  if (pfn >= (BIOS_BEGIN >> PAGE_SHIFT) &&
> >> > + A  A  A  pfn < A (BIOS_END A  >> PAGE_SHIFT))
> >> > + A  A  A  A  A  return 0;
> >> > +#endif
> >>
> >> I'm glad if this part is sorted out in clean way ;)
> >
> > Two possible solutions are:
> >
> > - to exclude the above two ranges directly in e820 map;
> > - to not add the above two ranges into iomem_resource.
> >
> > Yinghai, do you have any suggestions?
> > We want to get rid of the two explicit tests from page_is_ram().
> 
> please check attached patch.
> 
> YH

Thank you, it works!

Content-Description: remove_bios_begin_end.patch
> [PATCH] x86: remove bios data range from e820
> 
> to prepare move page_is_ram as generic one
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org.

Malformed email address..

> ---
>  arch/x86/kernel/e820.c   |    8 ++++++++
>  arch/x86/kernel/head32.c |    2 --
>  arch/x86/kernel/head64.c |    2 --
>  arch/x86/kernel/setup.c  |   19 ++++++++++++++++++-
>  arch/x86/mm/ioremap.c    |   16 ----------------
>  5 files changed, 26 insertions(+), 21 deletions(-)
> 
> Index: linux-2.6/arch/x86/kernel/setup.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/kernel/setup.c
> +++ linux-2.6/arch/x86/kernel/setup.c
> @@ -657,6 +657,23 @@ static struct dmi_system_id __initdata b
>  	{}
>  };
>  
> +static void __init trim_bios_range(void)

How about e820_trim_bios_range() ?

> +{
> +	/*
> +	 * A special case is the first 4Kb of memory;
> +	 * This is a BIOS owned area, not kernel ram, but generally
> +	 * not listed as such in the E820 table.
> +	 */
> +	e820_update_range(0, PAGE_SIZE, E820_RAM, E820_RESERVED);
> +	/*
> +	 * special case: Some BIOSen report the PC BIOS
> +	 * area (640->1Mb) as ram even though it is not.
> +	 * take them out.
> +	 */
> +	e820_remove_range(BIOS_BEGIN, BIOS_END - BIOS_BEGIN, E820_RAM, 1);
> +	sanitize_e820_map(e820.map, ARRAY_SIZE(e820.map), &e820.nr_map);
> +}
> +


> Index: linux-2.6/arch/x86/kernel/head32.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/kernel/head32.c
> +++ linux-2.6/arch/x86/kernel/head32.c
> @@ -29,8 +29,6 @@ static void __init i386_default_early_se
>  
>  void __init i386_start_kernel(void)
>  {
> -	reserve_early_overlap_ok(0, PAGE_SIZE, "BIOS data page");
> -
>  #ifdef CONFIG_X86_TRAMPOLINE
>  	/*
>  	 * But first pinch a few for the stack/trampoline stuff
> Index: linux-2.6/arch/x86/kernel/head64.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/kernel/head64.c
> +++ linux-2.6/arch/x86/kernel/head64.c
> @@ -98,8 +98,6 @@ void __init x86_64_start_reservations(ch
>  {
>  	copy_bootdata(__va(real_mode_data));
>  
> -	reserve_early_overlap_ok(0, PAGE_SIZE, "BIOS data page");
> -
>  	reserve_early(__pa_symbol(&_text), __pa_symbol(&__bss_stop), "TEXT DATA BSS");
>  
>  #ifdef CONFIG_BLK_DEV_INITRD

The above two trunks don't apply in latest linux-next.
Not a big problem for my test though.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

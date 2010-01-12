Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7CCD66B007B
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 08:36:16 -0500 (EST)
Date: Tue, 12 Jan 2010 21:35:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel(v1)
Message-ID: <20100112133556.GB7647@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com> <20100108124851.GB6153@localhost> <DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com> <20100111124303.GA21408@localhost> <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com> <20100112023307.GA16661@localhost> <20100112113903.89163c46.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100112113903.89163c46.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 10:39:03AM +0800, KAMEZAWA Hiroyuki wrote:
> On Tue, 12 Jan 2010 10:33:08 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Sure, here it is :)
> > ---
> > x86: use the generic page_is_ram()
> > 
> > The generic resource based page_is_ram() works better with memory
> > hotplug/hotremove. So switch the x86 e820map based code to it.
> > 
> > CC: Andi Kleen <andi@firstfloor.org> 
> > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Ack.

Thank you.

> 
> > +#ifdef CONFIG_X86
> > +	/*
> > +	 * A special case is the first 4Kb of memory;
> > +	 * This is a BIOS owned area, not kernel ram, but generally
> > +	 * not listed as such in the E820 table.
> > +	 */
> > +	if (pfn == 0)
> > +		return 0;
> > +
> > +	/*
> > +	 * Second special case: Some BIOSen report the PC BIOS
> > +	 * area (640->1Mb) as ram even though it is not.
> > +	 */
> > +	if (pfn >= (BIOS_BEGIN >> PAGE_SHIFT) &&
> > +	    pfn <  (BIOS_END   >> PAGE_SHIFT))
> > +		return 0;
> > +#endif
> 
> I'm glad if this part is sorted out in clean way ;)

Two possible solutions are:

- to exclude the above two ranges directly in e820 map;
- to not add the above two ranges into iomem_resource. 

Yinghai, do you have any suggestions?
We want to get rid of the two explicit tests from page_is_ram().

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

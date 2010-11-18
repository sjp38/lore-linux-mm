Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 948796B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 05:41:58 -0500 (EST)
Date: Thu, 18 Nov 2010 17:20:52 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [1/8,v3] NUMA Hotplug Emulator: add function to hide memory
 region via e820 table.
Message-ID: <20101118092052.GE2408@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.479272928@intel.com>
 <alpine.DEB.2.00.1011162354390.16875@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011162354390.16875@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 12:16:34AM -0800, David Rientjes wrote:
> On Wed, 17 Nov 2010, shaohui.zheng@intel.com wrote:
> 
> > Index: linux-hpe4/arch/x86/kernel/e820.c
> > ===================================================================
> > --- linux-hpe4.orig/arch/x86/kernel/e820.c	2010-11-15 17:13:02.483461667 +0800
> > +++ linux-hpe4/arch/x86/kernel/e820.c	2010-11-15 17:13:07.083461581 +0800
> > @@ -971,6 +971,7 @@
> >  }
> >  
> >  static int userdef __initdata;
> > +static u64 max_mem_size __initdata = ULLONG_MAX;
> >  
> >  /* "mem=nopentium" disables the 4MB page tables. */
> >  static int __init parse_memopt(char *p)
> > @@ -989,12 +990,28 @@
> >  
> >  	userdef = 1;
> >  	mem_size = memparse(p, &p);
> > -	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
> > +	e820_remove_range(mem_size, max_mem_size - mem_size, E820_RAM, 1);
> > +	max_mem_size = mem_size;
> >  
> >  	return 0;
> >  }
> 
> This needs memmap= support as well, right?
we did not do the testing after combine both memmap and numa=hide paramter, 
I think that the result should similar with mem=XX, they both remove a memory
region from the e820 table.

> 
> >  early_param("mem", parse_memopt);
> >  
> > +#ifdef CONFIG_NODE_HOTPLUG_EMU
> > +u64 __init e820_hide_mem(u64 mem_size)
> > +{
> > +	u64 start, end_pfn;
> > +
> > +	userdef = 1;
> > +	end_pfn = e820_end_of_ram_pfn();
> > +	start = (end_pfn << PAGE_SHIFT) - mem_size;
> > +	e820_remove_range(start, max_mem_size - start, E820_RAM, 1);
> > +	max_mem_size = start;
> > +
> > +	return start;
> > +}
> > +#endif
> 
> This doesn't have any sanity checking for whether e820_remove_range() will 
> leave any significant amount of memory behind so the kernel will even boot 
> (probably should have a guaranteed FAKE_NODE_MIN_SIZE left behind?).

it should not be checked here, it should be checked by the function who call
 e820_hide_mem, and truncate the mem_size with FAKE_NODE_MIN_SIZE.

> 
> > +
> >  static int __init parse_memmap_opt(char *p)
> >  {
> >  	char *oldp;

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

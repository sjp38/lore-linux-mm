Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F98B6B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 20:33:23 -0500 (EST)
Date: Fri, 19 Nov 2010 08:12:18 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [1/8,v3] NUMA Hotplug Emulator: add function to hide memory
 region via e820 table.
Message-ID: <20101119001218.GA3327@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.479272928@intel.com>
 <alpine.DEB.2.00.1011162354390.16875@chino.kir.corp.google.com>
 <20101118092052.GE2408@shaohui>
 <alpine.DEB.2.00.1011181313140.26680@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011181313140.26680@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 01:16:07PM -0800, David Rientjes wrote:
> On Thu, 18 Nov 2010, Shaohui Zheng wrote:
> 
> > > > Index: linux-hpe4/arch/x86/kernel/e820.c
> > > > ===================================================================
> > > > --- linux-hpe4.orig/arch/x86/kernel/e820.c	2010-11-15 17:13:02.483461667 +0800
> > > > +++ linux-hpe4/arch/x86/kernel/e820.c	2010-11-15 17:13:07.083461581 +0800
> > > > @@ -971,6 +971,7 @@
> > > >  }
> > > >  
> > > >  static int userdef __initdata;
> > > > +static u64 max_mem_size __initdata = ULLONG_MAX;
> > > >  
> > > >  /* "mem=nopentium" disables the 4MB page tables. */
> > > >  static int __init parse_memopt(char *p)
> > > > @@ -989,12 +990,28 @@
> > > >  
> > > >  	userdef = 1;
> > > >  	mem_size = memparse(p, &p);
> > > > -	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
> > > > +	e820_remove_range(mem_size, max_mem_size - mem_size, E820_RAM, 1);
> > > > +	max_mem_size = mem_size;
> > > >  
> > > >  	return 0;
> > > >  }
> > > 
> > > This needs memmap= support as well, right?
> > we did not do the testing after combine both memmap and numa=hide paramter, 
> > I think that the result should similar with mem=XX, they both remove a memory
> > region from the e820 table.
> > 
> 
> You've modified the parser for mem= but not memmap= so the change needs 
> additional support for the latter.
> 

the parser for mem= is not modified, the changed parser is numa=, I add a addtional
option numa=hide=.

>From current discussion, numa=hide= interface should be removed, we will use mem=
to hide memory.

> > > >  early_param("mem", parse_memopt);
> > > >  
> > > > +#ifdef CONFIG_NODE_HOTPLUG_EMU
> > > > +u64 __init e820_hide_mem(u64 mem_size)
> > > > +{
> > > > +	u64 start, end_pfn;
> > > > +
> > > > +	userdef = 1;
> > > > +	end_pfn = e820_end_of_ram_pfn();
> > > > +	start = (end_pfn << PAGE_SHIFT) - mem_size;
> > > > +	e820_remove_range(start, max_mem_size - start, E820_RAM, 1);
> > > > +	max_mem_size = start;
> > > > +
> > > > +	return start;
> > > > +}
> > > > +#endif
> > > 
> > > This doesn't have any sanity checking for whether e820_remove_range() will 
> > > leave any significant amount of memory behind so the kernel will even boot 
> > > (probably should have a guaranteed FAKE_NODE_MIN_SIZE left behind?).
> > 
> > it should not be checked here, it should be checked by the function who call
> >  e820_hide_mem, and truncate the mem_size with FAKE_NODE_MIN_SIZE.
> > 
> 
> Your patchset doesn't do that, I'm talking specifically about the amount 
> of memory left behind so that the kernel at least still boots.  That seems 
> to be a function of e820_hide_mem() to do some sanity checking so we 
> actually still get a kernel rather than the responsibility of the 
> command-line parser.

How much memory is enough to make sure the kernel can still boot, it is very 
hard to measure. it is almost impossible to get the exact data. I try to leave very 
few memory to kernel(hide most memory with numa=hide), it cause a panic directly.

I have no idea about it, do you have any suggestions?

Another example,  
I try to add paramter "mem=1M", it compains "Select item can not fit into memory", 
and I did not find where the error message comes from, I guess that it should 
be printed by grub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

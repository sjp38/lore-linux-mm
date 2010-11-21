Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5A10B6B0071
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 19:45:20 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id oAL0jGeE028910
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 16:45:16 -0800
Received: from gwj23 (gwj23.prod.google.com [10.200.10.23])
	by wpaz29.hot.corp.google.com with ESMTP id oAL0jDHc006190
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 16:45:15 -0800
Received: by gwj23 with SMTP id 23so579255gwj.31
        for <linux-mm@kvack.org>; Sat, 20 Nov 2010 16:45:13 -0800 (PST)
Date: Sat, 20 Nov 2010 16:45:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [1/8,v3] NUMA Hotplug Emulator: add function to hide memory
 region via e820 table.
In-Reply-To: <20101119001218.GA3327@shaohui>
Message-ID: <alpine.DEB.2.00.1011201642200.10618@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.479272928@intel.com> <alpine.DEB.2.00.1011162354390.16875@chino.kir.corp.google.com> <20101118092052.GE2408@shaohui> <alpine.DEB.2.00.1011181313140.26680@chino.kir.corp.google.com>
 <20101119001218.GA3327@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2010, Shaohui Zheng wrote:

> > > > > Index: linux-hpe4/arch/x86/kernel/e820.c
> > > > > ===================================================================
> > > > > --- linux-hpe4.orig/arch/x86/kernel/e820.c	2010-11-15 17:13:02.483461667 +0800
> > > > > +++ linux-hpe4/arch/x86/kernel/e820.c	2010-11-15 17:13:07.083461581 +0800
> > > > > @@ -971,6 +971,7 @@
> > > > >  }
> > > > >  
> > > > >  static int userdef __initdata;
> > > > > +static u64 max_mem_size __initdata = ULLONG_MAX;
> > > > >  
> > > > >  /* "mem=nopentium" disables the 4MB page tables. */
> > > > >  static int __init parse_memopt(char *p)
> > > > > @@ -989,12 +990,28 @@
> > > > >  
> > > > >  	userdef = 1;
> > > > >  	mem_size = memparse(p, &p);
> > > > > -	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
> > > > > +	e820_remove_range(mem_size, max_mem_size - mem_size, E820_RAM, 1);
> > > > > +	max_mem_size = mem_size;
> > > > >  
> > > > >  	return 0;
> > > > >  }
> > > > 
> > > > This needs memmap= support as well, right?
> > > we did not do the testing after combine both memmap and numa=hide paramter, 
> > > I think that the result should similar with mem=XX, they both remove a memory
> > > region from the e820 table.
> > > 
> > 
> > You've modified the parser for mem= but not memmap= so the change needs 
> > additional support for the latter.
> > 
> 
> the parser for mem= is not modified, the changed parser is numa=, I add a addtional
> option numa=hide=.
> 

The above hunk is modifying the x86 parser for the mem= parameter.

> > Your patchset doesn't do that, I'm talking specifically about the amount 
> > of memory left behind so that the kernel at least still boots.  That seems 
> > to be a function of e820_hide_mem() to do some sanity checking so we 
> > actually still get a kernel rather than the responsibility of the 
> > command-line parser.
> 
> How much memory is enough to make sure the kernel can still boot, it is very 
> hard to measure. it is almost impossible to get the exact data. I try to leave very 
> few memory to kernel(hide most memory with numa=hide), it cause a panic directly.
> 
> I have no idea about it, do you have any suggestions?
> 

Yes, I think we should use FAKE_NODE_MIN_SIZE to represent the smallest 
node that may be added and so the appropriate behavior or e820_hide_mem() 
would be to leave at least this quantity behind for the kernel to be 
loaded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

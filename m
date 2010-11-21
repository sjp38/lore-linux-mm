Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 182B26B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 08:57:49 -0500 (EST)
Received: by pvc30 with SMTP id 30so1603159pvc.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 05:57:48 -0800 (PST)
Date: Sun, 21 Nov 2010 22:00:57 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [1/8,v3] NUMA Hotplug Emulator: add function to hide memory
	region via e820 table.
Message-ID: <20101121140057.GH9099@hack>
References: <20101117020759.016741414@intel.com> <20101117021000.479272928@intel.com> <alpine.DEB.2.00.1011162354390.16875@chino.kir.corp.google.com> <20101118092052.GE2408@shaohui> <alpine.DEB.2.00.1011181313140.26680@chino.kir.corp.google.com> <20101119001218.GA3327@shaohui> <alpine.DEB.2.00.1011201642200.10618@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011201642200.10618@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Shaohui Zheng <shaohui.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 20, 2010 at 04:45:06PM -0800, David Rientjes wrote:
>On Fri, 19 Nov 2010, Shaohui Zheng wrote:
>
>> > > > > Index: linux-hpe4/arch/x86/kernel/e820.c
>> > > > > ===================================================================
>> > > > > --- linux-hpe4.orig/arch/x86/kernel/e820.c	2010-11-15 17:13:02.483461667 +0800
>> > > > > +++ linux-hpe4/arch/x86/kernel/e820.c	2010-11-15 17:13:07.083461581 +0800
>> > > > > @@ -971,6 +971,7 @@
>> > > > >  }
>> > > > >  
>> > > > >  static int userdef __initdata;
>> > > > > +static u64 max_mem_size __initdata = ULLONG_MAX;
>> > > > >  
>> > > > >  /* "mem=nopentium" disables the 4MB page tables. */
>> > > > >  static int __init parse_memopt(char *p)
>> > > > > @@ -989,12 +990,28 @@
>> > > > >  
>> > > > >  	userdef = 1;
>> > > > >  	mem_size = memparse(p, &p);
>> > > > > -	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
>> > > > > +	e820_remove_range(mem_size, max_mem_size - mem_size, E820_RAM, 1);
>> > > > > +	max_mem_size = mem_size;
>> > > > >  
>> > > > >  	return 0;
>> > > > >  }
>> > > > 
>> > > > This needs memmap= support as well, right?
>> > > we did not do the testing after combine both memmap and numa=hide paramter, 
>> > > I think that the result should similar with mem=XX, they both remove a memory
>> > > region from the e820 table.
>> > > 
>> > 
>> > You've modified the parser for mem= but not memmap= so the change needs 
>> > additional support for the latter.
>> > 
>> 
>> the parser for mem= is not modified, the changed parser is numa=, I add a addtional
>> option numa=hide=.
>> 
>
>The above hunk is modifying the x86 parser for the mem= parameter.
>

That is fine as long as "mem=" is parsed before "numa=".

I think "mem=" should always be parsed before "numa=" no matter what
order they are specified in cmdline, since we need know how much total
memory we have at first.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

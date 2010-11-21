Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 050236B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 16:33:54 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oALLXoOE012950
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:33:50 -0800
Received: from gye5 (gye5.prod.google.com [10.243.50.5])
	by wpaz1.hot.corp.google.com with ESMTP id oALLXkL7021892
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:33:48 -0800
Received: by gye5 with SMTP id 5so1856159gye.18
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:33:46 -0800 (PST)
Date: Sun, 21 Nov 2010 13:33:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [1/8,v3] NUMA Hotplug Emulator: add function to hide memory
 region via e820 table.
In-Reply-To: <20101121140057.GH9099@hack>
Message-ID: <alpine.DEB.2.00.1011211331220.26304@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.479272928@intel.com> <alpine.DEB.2.00.1011162354390.16875@chino.kir.corp.google.com> <20101118092052.GE2408@shaohui> <alpine.DEB.2.00.1011181313140.26680@chino.kir.corp.google.com>
 <20101119001218.GA3327@shaohui> <alpine.DEB.2.00.1011201642200.10618@chino.kir.corp.google.com> <20101121140057.GH9099@hack>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531368966-2015248532-1290375225=:26304"
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: Shaohui Zheng <shaohui.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-2015248532-1290375225=:26304
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sun, 21 Nov 2010, AmA(C)rico Wang wrote:

> >> > > > > Index: linux-hpe4/arch/x86/kernel/e820.c
> >> > > > > ===================================================================
> >> > > > > --- linux-hpe4.orig/arch/x86/kernel/e820.c	2010-11-15 17:13:02.483461667 +0800
> >> > > > > +++ linux-hpe4/arch/x86/kernel/e820.c	2010-11-15 17:13:07.083461581 +0800
> >> > > > > @@ -971,6 +971,7 @@
> >> > > > >  }
> >> > > > >  
> >> > > > >  static int userdef __initdata;
> >> > > > > +static u64 max_mem_size __initdata = ULLONG_MAX;
> >> > > > >  
> >> > > > >  /* "mem=nopentium" disables the 4MB page tables. */
> >> > > > >  static int __init parse_memopt(char *p)
> >> > > > > @@ -989,12 +990,28 @@
> >> > > > >  
> >> > > > >  	userdef = 1;
> >> > > > >  	mem_size = memparse(p, &p);
> >> > > > > -	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
> >> > > > > +	e820_remove_range(mem_size, max_mem_size - mem_size, E820_RAM, 1);
> >> > > > > +	max_mem_size = mem_size;
> >> > > > >  
> >> > > > >  	return 0;
> >> > > > >  }
> >> > > > 
> >> > > > This needs memmap= support as well, right?
> >> > > we did not do the testing after combine both memmap and numa=hide paramter, 
> >> > > I think that the result should similar with mem=XX, they both remove a memory
> >> > > region from the e820 table.
> >> > > 
> >> > 
> >> > You've modified the parser for mem= but not memmap= so the change needs 
> >> > additional support for the latter.
> >> > 
> >> 
> >> the parser for mem= is not modified, the changed parser is numa=, I add a addtional
> >> option numa=hide=.
> >> 
> >
> >The above hunk is modifying the x86 parser for the mem= parameter.
> >
> 
> That is fine as long as "mem=" is parsed before "numa=".
> 

If you'll read the discussion, I had no problem with modifying the mem 
parser.  I merely suggested that Shaohui modify the memmap parser in the 
same way to save max_mem_size so users can use it as well for the hidden 
nodes, that are now obsolete.  Apparently that was misunderstood by both 
of you although it looks pretty clear above, I dunno.
--531368966-2015248532-1290375225=:26304--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

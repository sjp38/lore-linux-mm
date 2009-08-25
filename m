Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8006B00BD
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:49:36 -0400 (EDT)
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090825133516.GE21335@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
	 <20090824192902.10317.94512.sendpatchset@localhost.localdomain>
	 <20090825133516.GE21335@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 25 Aug 2009 16:49:40 -0400
Message-Id: <1251233380.16229.3.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-08-25 at 14:35 +0100, Mel Gorman wrote:
> On Mon, Aug 24, 2009 at 03:29:02PM -0400, Lee Schermerhorn wrote:
> > <SNIP>
> >
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/node.h	2009-08-24 12:12:44.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h	2009-08-24 12:12:56.000000000 -0400
> > @@ -21,9 +21,12 @@
> >  
> >  #include <linux/sysdev.h>
> >  #include <linux/cpumask.h>
> > +#include <linux/hugetlb.h>
> >  
> 
> Is this header inclusion necessary? It does not appear to be required by
> the structure modification (which is iffy in itself as discussed in the
> earlier mail) and it breaks build on x86-64.

Hi, Mel:

I recall that it is necessary to build.  You can try w/o it.

> 
>  CC      arch/x86/kernel/setup_percpu.o
> In file included from include/linux/pagemap.h:10,
>                  from include/linux/mempolicy.h:62,
>                  from include/linux/hugetlb.h:8,
>                  from include/linux/node.h:24,
>                  from include/linux/cpu.h:23,
>                  from /usr/local/autobench/var/tmp/build/arch/x86/include/asm/cpu.h:5,
>                  from arch/x86/kernel/setup_percpu.c:19:
> include/linux/highmem.h:53: error: static declaration of kmap follows non-static declaration
> /usr/local/autobench/var/tmp/build/arch/x86/include/asm/highmem.h:60: error: previous declaration of kmap was here
> include/linux/highmem.h:59: error: static declaration of kunmap follows non-static declaration
> /usr/local/autobench/var/tmp/build/arch/x86/include/asm/highmem.h:61: error: previous declaration of kunmap was here
> include/linux/highmem.h:63: error: static declaration of kmap_atomic follows non-static declaration
> /usr/local/autobench/var/tmp/build/arch/x86/include/asm/highmem.h:63: error: previous declaration of kmap_atomic was here
> make[2]: *** [arch/x86/kernel/setup_percpu.o] Error 1
> make[1]: *** [arch/x86/kernel] Error 2


I saw this.  I've been testing on x86_64.  I *thought* that it only
started showing up in a recent mmotm from changes in the linux-next
patch--e.g., a failure to set ARCH_HAS_KMAP or to handle appropriately
!ARCH_HAS_KMAP in highmem.h  But maybe that was coincidental with my
adding the include.


Lee

> 
> 
> 
> >  struct node {
> >  	struct sys_device	sysdev;
> > +	struct kobject		*hugepages_kobj;
> > +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> >  };
> >  
> >  struct memory_block;
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

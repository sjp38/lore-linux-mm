Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3AAD46B0087
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 15:43:00 -0500 (EST)
Subject: Re: [PATCH/RFC 3/8] numa:  x86_64:  use generic percpu var for
 numa_node_id() implementation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.1003041245280.21776@router.home>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
	 <20100304170716.10606.24477.sendpatchset@localhost.localdomain>
	 <alpine.DEB.2.00.1003041245280.21776@router.home>
Content-Type: text/plain
Date: Thu, 04 Mar 2010 15:42:48 -0500
Message-Id: <1267735368.29020.104.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-03-04 at 12:47 -0600, Christoph Lameter wrote: 
> On Thu, 4 Mar 2010, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/percpu.h
> > ===================================================================
> > --- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/include/asm/percpu.h
> > +++ linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/percpu.h
> > @@ -208,10 +208,12 @@ do {									\
> >  #define percpu_or(var, val)		percpu_to_op("or", var, val)
> >  #define percpu_xor(var, val)		percpu_to_op("xor", var, val)
> >
> > +#define __this_cpu_read(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
> >  #define __this_cpu_read_1(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
> >  #define __this_cpu_read_2(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
> >  #define __this_cpu_read_4(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
> >
> > +#define __this_cpu_write(pcp, val)	percpu_to_op("mov", (pcp), val)
> >  #define __this_cpu_write_1(pcp, val)	percpu_to_op("mov", (pcp), val)
> >  #define __this_cpu_write_2(pcp, val)	percpu_to_op("mov", (pcp), val)
> >  #define __this_cpu_write_4(pcp, val)	percpu_to_op("mov", (pcp), val)
> 
> 
> The functions added are already defined in linux/percpu.h and their
> definition here is wrong since the u64 case is not handled (percpu.h does
> that correctly).

Well, in linux/percpu-defs.h after the first patch in this series, but
x86 is overriding it with the percpu_to_op() implementation.  You're
saying that the x86 percpu_to_op() macro doesn't handle 8-byte 'pcp'
operands?  It appears to handle sizes 1, 2, 4 and 8.

But, I just tried the series with the above two definitions removed and
the kernel builds and boots.  And runs the hackbench test even faster.

2.6.33-mmotm-100302-1838 on 8x6 AMD x86_64 -- hackbench 400 process 200
[avg of 10 runs]:
no add'l patches:		3.332
my V3 series:			3.148
V3 + generic __this_cpu_xxx():  3.083  [removed x86 defs of
__this_cpu_xxx()]


So, I'll remove those definitions in V4.

Do we want to retain the x86 definitions of __this_cpu_xxx_[124]() or
remove those and let the generic definitions handle them? 

Lee





  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

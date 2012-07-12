Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 0C5846B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 21:01:01 -0400 (EDT)
Date: Thu, 12 Jul 2012 10:01:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] zsmalloc improvements
Message-ID: <20120712010105.GA5503@bbox>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <4FFD2524.2050300@kernel.org>
 <4FFD86FE.1090307@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FFD86FE.1090307@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Wed, Jul 11, 2012 at 09:00:30AM -0500, Seth Jennings wrote:
> On 07/11/2012 02:03 AM, Minchan Kim wrote:
> > On 07/03/2012 06:15 AM, Seth Jennings wrote:
> >> zsmapbench measures the copy-based mapping at ~560 cycles for a
> >> map/unmap operation on spanned object for both KVM guest and bare-metal,
> >> while the page table mapping was ~1500 cycles on a VM and ~760 cycles
> >> bare-metal.  The cycles for the copy method will vary with
> >> allocation size, however, it is still faster even for the largest
> >> allocation that zsmalloc supports.
> >>
> >> The result is convenient though, as mempcy is very portable :)
> > 
> > Today, I tested zsmapbench in my embedded board(ARM).
> > tlb-flush is 30% faster than copy-based so it's always not win.
> > I think it depends on CPU speed/cache size.
> > 
> > zram is already very popular on embedded systems so I want to use
> > it continuously without 30% big demage so I want to keep our old approach
> > which supporting local tlb flush. 
> > 
> > Of course, in case of KVM guest, copy-based would be always bin win.
> > So shouldn't we support both approach? It could make code very ugly
> > but I think it has enough value.
> > 
> > Any thought?
> 
> Thanks for testing on ARM.
> 
> I can add the pgtable assisted method back in, no problem.
> The question is by which criteria are we going to choose
> which method to use? By arch (i.e. ARM -> pgtable assist,
> x86 -> copy, other archs -> ?)?

I prefer your previous version __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE.
If you didn't implement that function for x86, it simply uses memcpy
version while ARM can use tlb flush version if we add the definary.

Of course, it would be better to select best choice by testing
benchmark for all of architecture but that architecture would be
changed in future, too so we need further testing periodically.
And we will have no time then, too.
For reducing the burden, we can detect it automatically while module
is loading or booting but it tackles with booting time. :(
So, let's put it aside as further works.
At the moment, let's think simply two arch(x86, ARM) until other arch
user doesn't raise a hand for volunteering.

Yes. it could be a problem in future if other arch which support
local flush want to use memcpy but IMHO, it's very hard to kill
two bird(portability and performance) with one stone. :(

> 
> Also, what changes did you make to zsmapbench to measure
> elapsed time/cycles on ARM?  Afaik, rdtscll() is not
> supported on ARM.

I used local_clock instead of arch dependent code and makes longer test time
from 1 sec to 10 sec.

> 
> Thanks,
> Seth
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

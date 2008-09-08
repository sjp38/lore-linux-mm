From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Date: Mon, 8 Sep 2008 21:19:32 +1000
References: <20080905215452.GF11692@us.ibm.com> <200809081946.31521.nickpiggin@yahoo.com.au> <20080908103015.GE26079@one.firstfloor.org>
In-Reply-To: <20080908103015.GE26079@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809082119.32725.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Monday 08 September 2008 20:30, Andi Kleen wrote:
> On Mon, Sep 08, 2008 at 07:46:30PM +1000, Nick Piggin wrote:
> > On Monday 08 September 2008 19:36, Andi Kleen wrote:
> > > > You use non-linear mappings for the kernel, so that kernel data is
> > > > not tied to a specific physical address. AFAIK, that is the only way
> > > > to really do it completely (like the fragmentation problem).
> > >
> > > Even with that there are lots of issues, like keeping track of
> > > DMAs or handling executing kernel code.
> >
> > Right, but the "high level" software solution is to have nonlinear
> > kernel mappings. Executing kernel code should not be so hard because
> > it could be handled just like executing user code (ie. the CPU that
> > is executing will subsequently fault and be blocked until the
> > relocation is complete).
>
> First blocking arbitary code is hard. There is some code parts
> which are not allowed to block arbitarily. Machine check or NMI
> handlers come to mind, but there are likely more.

Sorry, by "block", I really mean spin I guess. I mean that the CPU will
be forced to stop executing due to the page fault during this sequence:

for prot RO:
alloc new page
memcpy(new, old)
ptep_clear_flush(ptep)         <--- from here
set_pte(ptep, newpte)          <--- until here

for prot RW, the window also would include the memcpy, however if that
adds too much latency for execute/reads, then it can be mapped RO first,
then memcpy, then flushed and switched.
 

> Then that would be essentially a hypervisor or micro kernel approach.

What would be? Blocking in interrupts? Or non-linear kernel mapping in
general? Nonlinear kernel mapping I don't think anyone disputes is the
only way to defragment (for unplug or large allocations) arbitrary
physical memory with any sort of guarantee. In the future if TLB costs
grow very much larger, I think this might be worth considering.

But until that becomes inevitable, I really don't want to hack the VM
with crap like transparent variable order mappings etc. but rather
"encourage" CPU manufacturers to have big fast TLBs :)


> e.g. Xen does that already kind of, but even there it would
> be quite hard to do fully in a general way. And for hardware hotplug
> only the fully generally way is actually useful unfortunately.

Yeah I don't really get the hardware hotplug thing. For reliability or
anything it should all be done in hardware (eg. warm/hot spare memory
module). For power I guess there is some argument, but I would prefer
to wait the trends out longer before committing to something big: non
volatile ram replacement for dram for example might be achieved in
future.

But if anybody disagrees, they are sure free to implement non-linear
kernel mappings and physical defragmentation and shut me up with
real numbers!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Date: Mon, 8 Sep 2008 19:46:30 +1000
References: <20080905215452.GF11692@us.ibm.com> <200809081552.50126.nickpiggin@yahoo.com.au> <20080908093619.GC26079@one.firstfloor.org>
In-Reply-To: <20080908093619.GC26079@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809081946.31521.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Monday 08 September 2008 19:36, Andi Kleen wrote:
> > You use non-linear mappings for the kernel, so that kernel data is
> > not tied to a specific physical address. AFAIK, that is the only way
> > to really do it completely (like the fragmentation problem).
>
> Even with that there are lots of issues, like keeping track of
> DMAs or handling executing kernel code.

Right, but the "high level" software solution is to have nonlinear
kernel mappings. Executing kernel code should not be so hard because
it could be handled just like executing user code (ie. the CPU that
is executing will subsequently fault and be blocked until the
relocation is complete).

DMAs aren't trivial at all, but I guess there could be say, a method
to submit and revoke areas of memory for DMA, and the submit would
block if the memory is currently being relocated underneath it (then
it would be able to find the new address).

Anwyay, whatever the case, yeah I'm not trying to say it is trivial
at all. Even without thinking about DMA it would be costly.


> > Of course, I don't think that would be a good idea to do that in the
> > forseeable future.
>
> Agreed.

Same as the "anti-frag" patches. We must not proceed with this kind of
thing on the justification that "in future we'll be able to unplug any
bit of memory". Because it is not just a matter of logical steps to
reach that point, but basically a fundamental rethink of how the kernel
memory mapping should work.

Other realistic justifications are OK, but if someone wants to unplug
everything, then please put effort into *first* making the kernel
mapping nonlinear, and then we can look at the complexity and
performance costs of that fundamental step.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

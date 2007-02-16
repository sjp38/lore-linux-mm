Message-ID: <45D55DC2.3070703@yahoo.com.au>
Date: Fri, 16 Feb 2007 18:31:14 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 11/21] Xen-paravirt: Add apply_to_page_range() which applies
 a function to a pte range.
References: <20070216022449.739760547@goop.org>	<20070216022531.344125142@goop.org> <20070215223727.6819f962.akpm@linux-foundation.org>
In-Reply-To: <20070215223727.6819f962.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@muc.de>, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, xen-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>, Zachary Amsden <zach@vmware.com>, Ian Pratt <ian.pratt@xensource.com>, Christian Limpach <Christian.Limpach@cl.cam.ac.uk>, Christoph Lameter <clameter@sgi.com>, Linux Memory Management <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 15 Feb 2007 18:25:00 -0800 Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> 
> 
>>Add a new mm function apply_to_page_range() which applies a given
>>function to every pte in a given virtual address range in a given mm
>>structure. This is a generic alternative to cut-and-pasting the Linux
>>idiomatic pagetable walking code in every place that a sequence of
>>PTEs must be accessed.
>>
>>Although this interface is intended to be useful in a wide range of
>>situations, it is currently used specifically by several Xen
>>subsystems, for example: to ensure that pagetables have been allocated
>>for a virtual address range, and to construct batched special
>>pagetable update requests to map I/O memory (in ioremap()).
> 
> 
> There was some discussion about this sort of thing last week.  The
> consensus was that it's better to run the callback against a whole pmd's
> worth of ptes, mainly to amortise the callback's cost (a lot).
> 
> It was implemented in
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.20/2.6.20-mm1/broken-out/smaps-extract-pmd-walker-from-smaps-code.patch


Speaking of that patch, I missed the discussion, but I'd hope it doesn't
go upstream in its current form.

We now have one way of walking range of ptes. The code may be duplicated a
few times, but it is simple, we know how it works, and it is easy to get
right because everyone does the same thing.

We used to have about a dozen slightly different ways of doing this until
Hugh spent the effort to standardise it all. Isn't it nice?

If we want an ever-so-slightly lower performing interface for those paths
that don't care to count every cycle -- which I think is a fine idea BTW
-- it should be implemented in mm/memory.c and it should use our standard
form of pagetable walking.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

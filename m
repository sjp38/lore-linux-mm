Date: Fri, 29 Feb 2008 11:55:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080229131302.GT8091@v2.random>
Message-ID: <Pine.LNX.4.64.0802291149290.11292@schroedinger.engr.sgi.com>
References: <200802201008.49933.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
 <20080228001104.GB8091@v2.random> <Pine.LNX.4.64.0802271613080.15791@schroedinger.engr.sgi.com>
 <20080228005249.GF8091@v2.random> <Pine.LNX.4.64.0802271702490.16510@schroedinger.engr.sgi.com>
 <20080228011020.GG8091@v2.random> <Pine.LNX.4.64.0802281043430.29191@schroedinger.engr.sgi.com>
 <20080229005530.GO8091@v2.random> <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com>
 <20080229131302.GT8091@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Andrea Arcangeli wrote:

> On Thu, Feb 28, 2008 at 04:59:59PM -0800, Christoph Lameter wrote:
> > And thus the device driver may stop receiving data on a UP system? It will 
> > never get the ack.
> 
> Not sure to follow, sorry.
> 
> My idea was:
> 
>    post the invalidate in the mmio region of the device
>    smp_call_function()
>    while (mmio device wait-bitflag is on);

So the device driver on UP can only operate through interrupts? If you are 
hogging the only cpu then driver operations may not be possible.

> > invalidate_page_before/end could be realized as an 
> > invalidate_range_begin/end on a page sized range?
> 
> If we go this route, once you add support to xpmem, you'll have to
> make the anon_vma lock a mutex too, that would be fine with me
> though. The main reason invalidate_page exists, is to allow you to
> leave it as non-sleep-capable even after you make invalidate_range
> sleep capable, and to implement the mmu_rmap_notifiers sleep capable
> in all the paths that invalidate_page would be called. That was the
> strategy you had in your patch. I'll try to drop invalidate_page. I
> wonder if then you won't need the mmu_rmap_notifiers anymore.

I am mainly concerned with making the mmu notifier a generally useful 
feature for multiple users. Xpmem is one example of a different user. It 
should be considered as one example of a different type of callback user. 
It is not the gold standard that you make it to be. RDMA is another and 
there are likely scores of others (DMA engines etc) once it becomes clear 
that such a feature is available. In general the mmu notifier will allows 
us to fix the problems caused by memory pinning and mlock by various 
devices and other mechanisms that need to directly access memory. 

And yes I would like to get rid of the mmu_rmap_notifiers altogether. It 
would be much cleaner with just one mmu_notifier that can sleep in all 
functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

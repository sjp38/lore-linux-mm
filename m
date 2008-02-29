Date: Fri, 29 Feb 2008 14:13:02 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080229131302.GT8091@v2.random>
References: <200802201008.49933.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com> <20080228001104.GB8091@v2.random> <Pine.LNX.4.64.0802271613080.15791@schroedinger.engr.sgi.com> <20080228005249.GF8091@v2.random> <Pine.LNX.4.64.0802271702490.16510@schroedinger.engr.sgi.com> <20080228011020.GG8091@v2.random> <Pine.LNX.4.64.0802281043430.29191@schroedinger.engr.sgi.com> <20080229005530.GO8091@v2.random> <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2008 at 04:59:59PM -0800, Christoph Lameter wrote:
> And thus the device driver may stop receiving data on a UP system? It will 
> never get the ack.

Not sure to follow, sorry.

My idea was:

   post the invalidate in the mmio region of the device
   smp_call_function()
   while (mmio device wait-bitflag is on);

Instead of the current:

   smp_call_function()
   post the invalidate in the mmio region of the device
   while (mmio device wait-bitflag is on);

To decrease the wait loop time.

> invalidate_page_before/end could be realized as an 
> invalidate_range_begin/end on a page sized range?

If we go this route, once you add support to xpmem, you'll have to
make the anon_vma lock a mutex too, that would be fine with me
though. The main reason invalidate_page exists, is to allow you to
leave it as non-sleep-capable even after you make invalidate_range
sleep capable, and to implement the mmu_rmap_notifiers sleep capable
in all the paths that invalidate_page would be called. That was the
strategy you had in your patch. I'll try to drop invalidate_page. I
wonder if then you won't need the mmu_rmap_notifiers anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

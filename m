Date: Fri, 29 Feb 2008 21:17:44 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080229201744.GB8091@v2.random>
References: <20080228001104.GB8091@v2.random> <Pine.LNX.4.64.0802271613080.15791@schroedinger.engr.sgi.com> <20080228005249.GF8091@v2.random> <Pine.LNX.4.64.0802271702490.16510@schroedinger.engr.sgi.com> <20080228011020.GG8091@v2.random> <Pine.LNX.4.64.0802281043430.29191@schroedinger.engr.sgi.com> <20080229005530.GO8091@v2.random> <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com> <20080229131302.GT8091@v2.random> <Pine.LNX.4.64.0802291149290.11292@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802291149290.11292@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 29, 2008 at 11:55:17AM -0800, Christoph Lameter wrote:
> >    post the invalidate in the mmio region of the device
> >    smp_call_function()
> >    while (mmio device wait-bitflag is on);
> 
> So the device driver on UP can only operate through interrupts? If you are 
> hogging the only cpu then driver operations may not be possible.

There was no irq involved in the above pseudocode, the irq if
something would run in the remote system. Still irqs can run fine
during the while loop like they run fine on top of
smp_call_function. The send-irq and the following spin-on-a-bitflag
works exactly as smp_call_function except this isn't a numa-CPU to
invalidate.

> And yes I would like to get rid of the mmu_rmap_notifiers altogether. It 
> would be much cleaner with just one mmu_notifier that can sleep in all 
> functions.

Agreed. I just thought xpmem needed an invalidate-by-page, but
I'm glad if xpmem can go in sync with the KVM/GRU/DRI model in this
regard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

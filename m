Date: Tue, 19 Feb 2008 08:27:25 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch] my mmu notifiers
Message-ID: <20080219142725.GA23200@sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219135851.GI7128@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Feb 19, 2008 at 02:58:51PM +0100, Andrea Arcangeli wrote:
> > understand the need for invalidate_begin/invalidate_end pairs at all.
> 
> The need of the pairs is crystal clear to me: range_begin is needed
> for GRU _but_only_if_ range_end is called after releasing the
> reference that the VM holds on the page. _begin will flush the GRU tlb
> and at the same time it will take a mutex that will block further GRU
> tlb-miss-interrupts (no idea how they manange those nightmare locking,
> I didn't even try to add more locking to KVM and I get away with the
> fact KVM takes the pin on the page itself).

As it turns out, no actual mutex is required. _begin_ simply increments a
count of active range invalidates, _end_ decrements the count. New TLB
dropins are deferred while range callouts are active.

This would appear to be racy but the GRU has special hardware that
simplifies locking. When the GRU sees a TLB invalidate, all outstanding
misses & potentially inflight TLB dropins are marked by the GRU with a
"kill" bit. When the dropin finally occurs, the dropin is ignored & the
instruction is simply restarted. The instruction will fault again & the TLB
dropin will be repeated.  This is optimized for the case where invalidates
are rare - true for users of the GRU.


In general, though, I agree. Most users of mmu_notifiers would likely
required a mutex or something equivalent.


--- jack



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

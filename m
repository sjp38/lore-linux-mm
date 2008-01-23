Date: Wed, 23 Jan 2008 13:04:46 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123120446.GF15848@v2.random>
References: <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com> <479716AD.5070708@qumranet.com> <20080123105246.GG26420@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080123105246.GG26420@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Avi Kivity <avi@qumranet.com>, Christoph Lameter <clameter@sgi.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2008 at 04:52:47AM -0600, Robin Holt wrote:
> But 100 callouts holding spinlocks will not work for our implementation
> and even if the callouts are made with spinlocks released, we would very
> strongly prefer a single callout which messages the range to the other
> side.

But you take the physical address and turn into mm+va with your rmap...

> > Also, our rmap key for finding the spte is keyed on (mm, va).  I imagine
> > most RDMA cards are similar.
> 
> For our RDMA rmap, it is based upon physical address.

so why do you turn it into mm+va?

> >> There is only the need to walk twice for pages that are marked Exported.
> >> And the double walk is only necessary if the exporter does not have its
> >> own rmap. The cross partition thing that we are doing has such an rmap and
> >> its a matter of walking the exporters rmap to clear out the external
> >> references and then we walk the local rmaps. All once.
> >>
> >
> > The problem is that external mmus need a reverse mapping structure to
> > locate their ptes.  We can't expand struct page so we need to base it on mm
> > + va.
> 
> Our rmap takes a physical address and turns it into mm+va.

Why don't you stick to mm+va and use get_user_pages and let the VM do
the swapins etc...?

> > Can they wait on that bit?
> 
> PageLocked(page) should work, right?  We already have a backoff
> mechanism so we expect to be able to adapt it to include a
> PageLocked(page) check.

It's not PageLocked but wait_on_page___not___exported() called on the
master node. Plus nothing in the VM of the master node calls
SetPageExported... good luck to make it work (KVM swapping OTOH works
like a charm already w/o the backwards secondary-TLB-flushing order).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

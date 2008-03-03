Date: Mon, 3 Mar 2008 09:18:59 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080303151859.GA19374@sgi.com>
References: <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303032934.GA3301@wotan.suse.de> <20080303125152.GS8091@v2.random> <20080303131017.GC13138@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080303131017.GC13138@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 03, 2008 at 02:10:17PM +0100, Nick Piggin wrote:
> On Mon, Mar 03, 2008 at 01:51:53PM +0100, Andrea Arcangeli wrote:
> > On Mon, Mar 03, 2008 at 04:29:34AM +0100, Nick Piggin wrote:
> > > to something I prefer. Others may not, but I'll post them for debate
> > > anyway.
> > 
> > Sure, thanks!
> > 
> > > > I didn't drop invalidate_page, because invalidate_range_begin/end
> > > > would be slower for usages like KVM/GRU (we don't need a begin/end
> > > > there because where invalidate_page is called, the VM holds a
> > > > reference on the page). do_wp_page should also use invalidate_page
> > > > since it can free the page after dropping the PT lock without losing
> > > > any performance (that's not true for the places where invalidate_range
> > > > is called).
> > > 
> > > I'm still not completely happy with this. I had a very quick look
> > > at the GRU driver, but I don't see why it can't be implemented
> > > more like the regular TLB model, and have TLB insertions depend on
> > > the linux pte, and do invalidates _after_ restricting permissions
> > > to the pte.
> > > 
> > > Ie. I'd still like to get rid of invalidate_range_begin, and get
> > > rid of invalidate calls from places where permissions are relaxed.
> > 
> > _begin exists because by the time _end is called, the VM already
> > dropped the reference on the page. This way we can do a single
> > invalidate no matter how large the range is. I don't see ways to
> > remove _begin while still invoking _end a single time for the whole
> > range.
> 
> Is this just a GRU problem? Can't we just require them to take a ref
> on the page (IIRC Jack said GRU could be changed to more like a TLB
> model).

Maintaining a long-term reference on a page is a problem. The GRU does not
currently maintain tables to track the pages for which dropins have been done.

The GRU has a large internal TLB and is designed to reference up to 8PB of
memory. The size of the tables to track this many referenced pages would be
a problem (at best).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 17 Apr 2008 06:14:04 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
	operation to happen
Message-ID: <20080417111404.GL22493@sgi.com>
References: <patchbomb.1207669443@duo.random> <ec6d8f91b299cf26cce5.1207669444@duo.random> <20080416163337.GJ22493@sgi.com> <Pine.LNX.4.64.0804161134360.12296@schroedinger.engr.sgi.com> <20080416190213.GK22493@sgi.com> <Pine.LNX.4.64.0804161214170.14657@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804161214170.14657@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 16, 2008 at 12:15:08PM -0700, Christoph Lameter wrote:
> On Wed, 16 Apr 2008, Robin Holt wrote:
> 
> > On Wed, Apr 16, 2008 at 11:35:38AM -0700, Christoph Lameter wrote:
> > > On Wed, 16 Apr 2008, Robin Holt wrote:
> > > 
> > > > I don't think this lock mechanism is completely working.  I have
> > > > gotten a few failures trying to dereference 0x100100 which appears to
> > > > be LIST_POISON1.
> > > 
> > > How does xpmem unregistering of notifiers work?
> > 
> > For the tests I have been running, we are waiting for the release
> > callout as part of exit.
> 
> Some more details on the failure may be useful. AFAICT list_del[_rcu] is 
> the culprit here and that is only used on release or unregister.

I think I have this understood now.  It happens quite quickly (within
10 minutes) on a 128 rank job of small data set in a loop.

In these failing jobs, all the ranks are nearly symmetric.  There is
a certain part of each ranks address space that has access granted.
All the ranks have included all the other ranks including themselves in
exactly the same layout at exactly the same virtual address.

Rank 3 has hit _release and is beginning to clean up, but has not deleted
the notifier from its list.

Rank 9 calls the xpmem_invalidate_page() callout.  That page was attached
by rank 3 so we call zap_page_range on rank 3 which then calls back into
xpmem's invalidate_range_start callout.

The rank 3 _release callout begins and deletes its notifier from the list.

Rank 9's call to rank 3's zap_page_range notifier returns and dereferences
LIST_POISON1.

I often confuse myself while trying to explain these so please kick me
where the holes in the flow appear.  The console output from the simple
debugging stuff I put in is a bit overwhelming.


I am trying to figure out now which locks we hold as part of the zap
callout that should have prevented the _release callout.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

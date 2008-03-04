Date: Tue, 4 Mar 2008 10:58:41 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <200803040650.11942.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0803041054210.13957@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <200803031611.10275.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0803031124001.7275@schroedinger.engr.sgi.com>
 <200803040650.11942.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Nick Piggin wrote:

> > Then put it into the arch code for TLB invalidation. Paravirt ops gives
> > good examples on how to do that.
> 
> Put what into arch code?

The mmu notifier code.

> > > What about a completely different approach... XPmem runs over NUMAlink,
> > > right? Why not provide some non-sleeping way to basically IPI remote
> > > nodes over the NUMAlink where they can process the invalidation? If you
> > > intra-node cache coherency has to run over this link anyway, then
> > > presumably it is capable.
> >
> > There is another Linux instance at the remote end that first has to
> > remove its own ptes.
> 
> Yeah, what's the problem?

The remote end has to invalidate the page which involves locking etc.

> > Also would not work for Inifiniband and other 
> > solutions.
> 
> infiniband doesn't want it. Other solutions is just handwaving,
> because if we don't know what the other soloutions are, then we can't
> make any sort of informed choices.

We need a solution in general to avoid the pinning problems. Infiniband 
has those too.

> > All the approaches that require evictions in an atomic context 
> > are limiting the approach and do not allow the generic functionality that
> > we want in order to not add alternate APIs for this.
> 
> The only generic way to do this that I have seen (and the only proposed
> way that doesn't add alternate APIs for that matter) is turning VM locks
> into sleeping locks. In which case, Andrea's notifiers will work just
> fine (except for relatively minor details like rcu list scanning).

No they wont. As you pointed out the callback need RCU locking.

> > The good enough solution right now is to pin pages by elevating
> > refcounts.
> 
> Which kind of leads to the question of why do you need any further
> kernel patches if that is good enough?

Well its good enough with severe problems during reclaim, livelocks etc. 
One could improve on that scheme through Rik's work trying to add a new 
page flag that mark pinned pages and then keep them off the LRUs and 
limiting their number. Having pinned page would limit the ability to 
reclaim by the VM and make page migration, memory unplug etc impossible. 
It is better to have notifier scheme that allows to tell a device driver 
to free up the memory it has mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

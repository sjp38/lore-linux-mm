From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
Date: Tue, 4 Mar 2008 06:50:10 +1100
References: <20080215064859.384203497@sgi.com> <200803031611.10275.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0803031124001.7275@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803031124001.7275@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803040650.11942.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tuesday 04 March 2008 06:28, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> > Your skeleton is just registering notifiers and saying
> >
> > /* you fill the hard part in */
> >
> > If somebody needs a skeleton in order just to register the notifiers,
> > then almost by definition they are unqualified to write the hard
> > part ;)
>
> Its also providing a locking scheme.

Not the full locking scheme. If you have a look at the real code
required to do it, it is non trivial.


> > OK, there are ways to solve it or hack around it. But this is exactly
> > why I think the implementations should be kept seperate. Andrea's
> > notifiers are coherent, work on all types of mappings, and will
> > hopefully match closely the regular TLB invalidation sequence in the
> > Linux VM (at the moment it is quite close, but I hope to make it a
> > bit closer) so that it requires almost no changes to the mm.
>
> Then put it into the arch code for TLB invalidation. Paravirt ops gives
> good examples on how to do that.

Put what into arch code?


> > What about a completely different approach... XPmem runs over NUMAlink,
> > right? Why not provide some non-sleeping way to basically IPI remote
> > nodes over the NUMAlink where they can process the invalidation? If you
> > intra-node cache coherency has to run over this link anyway, then
> > presumably it is capable.
>
> There is another Linux instance at the remote end that first has to
> remove its own ptes.

Yeah, what's the problem?


> Also would not work for Inifiniband and other 
> solutions.

infiniband doesn't want it. Other solutions is just handwaving,
because if we don't know what the other soloutions are, then we can't
make any sort of informed choices.


> All the approaches that require evictions in an atomic context 
> are limiting the approach and do not allow the generic functionality that
> we want in order to not add alternate APIs for this.

The only generic way to do this that I have seen (and the only proposed
way that doesn't add alternate APIs for that matter) is turning VM locks
into sleeping locks. In which case, Andrea's notifiers will work just
fine (except for relatively minor details like rcu list scanning).

So I don't see what you're arguing for. There is no requirement that we
support sleeping notifiers in the same patch as non-sleeping ones.
Considering the simplicity of the non-sleeping notifiers and the
problems with sleeping ones, I think it is pretty clear that they are
different beasts (unless VM locking is changed).


> > Or another idea, why don't you LD_PRELOAD in the MPT library to also
> > intercept munmap, mprotect, mremap etc as well as just fork()? That
> > would give you similarly "good enough" coherency as the mmu notifier
> > patches except that you can't swap (which Robin said was not a big
> > problem).
>
> The good enough solution right now is to pin pages by elevating
> refcounts.

Which kind of leads to the question of why do you need any further
kernel patches if that is good enough?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 1 of 8] Core of mmu notifiers
Date: Thu, 3 Apr 2008 02:42:46 +0200
Message-ID: <20080403004246.GA16633@duo.random>
References: <a406c0cc686d0ca94a4d.1207171802@duo.random>
	<Pine.LNX.4.64.0804021527370.31603@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021527370.31603@schroedinger.engr.sgi.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, akpm@linux-foundation.org
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2008 at 03:34:01PM -0700, Christoph Lameter wrote:
> Still two methods ...

Yes, the invalidate_page is called with the core VM holding a
reference on the page _after_ the tlb flush. The invalidate_end is
called after the page has been freed already and after the tlb
flush. They've different semantics and with invalidate_page there's no
need to block the kvm fault handler. But invalidate_page is only
the most efficient for operations that aren't creating holes in the
vma, for the rest invalidate_range_start/end provides the best
performance by reducing the number of tlb flushes.

> seqlock just taken for checking if everything is ok?

Exactly.

> The critical section could be run multiple times for one callback which 
> could result in multiple callbacks to clear the young bit. Guess not that 
> big of an issue?

Yes, that's ok.

> Ok. Retry would try to invalidate the page a second time which is not a 
> problem unless you would drop the refcount or make other state changes 
> that require correspondence with mapping. I guess this is the reason 
> that you stopped adding a refcount?

The current patch using mmu notifiers is already robust against
multiple invalidates. The refcounting represent a spte mapping, if we
already invalidated it, the spte will be nonpresent and there's no
page to unpin. The removal of the refcount is only a
microoptimization.

> Multiple invalidate_range_starts on the same range? This means the driver 
> needs to be able to deal with the situation and ignore the repeated 
> call?

The driver would need to store current->pid in a list and remove it in
range_stop. And range_stop would need to do nothing at all, if the pid
isn't found in the list.

But thinking more I'm not convinced the driver is safe by ignoring if
range_end runs before range_begin (pid not found in the list). And I
don't see a clear way to fix it not internally to the device driver
nor externally. So the repeated call is easy to handle for the
driver. What is not trivial is to block the secondary page faults when
mmu_notifier_register happens in the middle of range_start/end
critical section. sptes can be established in between range_start/_end
and that shouldn't happen. So the core problem returns to be how to
handle mmu_notifier_register happening in the middle of
_range_start/_end, dismissing it as a job for the driver seems not
feasible (you have the same problem with EMM of course).

> Retry can lead to multiple invalidate_range callbacks with the same 
> parameters? Driver needs to ignore if the range is already clear?

Mostly covered above.


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace

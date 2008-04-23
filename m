Date: Wed, 23 Apr 2008 18:37:13 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423163713.GC24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423002848.GA32618@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423002848.GA32618@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 07:28:49PM -0500, Jack Steiner wrote:
> The GRU driver unregisters the notifier when all GRU mappings
> are unmapped. I could make it work either way - either with or without
> an unregister function. However, unregister is the most logical
> action to take when all mappings have been destroyed.

This is true for KVM as well, unregister would be the most logical
action to take when the kvm device is closed and the vm
destroyed. However we can't implement mm_lock in O(N*log(N)) without
triggering RAM allocations. And the size of those ram allocations are
unknown at the time unregister runs (they also depend on the
max_nr_vmas sysctl). So on a second thought not even passing the array
from register to unregister would solve it (unless we allocate
max_nr_vmas and we block the sysctl to alter max_nr_vmas if not all
unregister run yet).That's clearly unacceptable.

The only way to avoid failing because of vmalloc space shortage or
oom, would be to provide a O(N*N) fallback. But one that can't be
interrupted by sigkill! sigkill interruption was ok in #v12 because we
didn't rely on mmu_notifier_unregister to succeed. So it avoided any
DoS but it still can't provide any reliable unregister.

So in the end unregistering with kill -9 leading to ->release in O(1)
sounds safer solution for the long term. You can't loop if unregister
fails and pretend your module not to have deadlocks.

Yes, waiting ->release add up a bit of complexity but I think it worth
it, and there weren't genial ideas on how to avoid O(N*N) complexity
and allocations too in mmu_notifier_unregister yet. Until that genius
idea will materialize we'll stick with ->release in O(1) as the only
safe unregister so we guarantee the admin will be in control of his
hardware in O(1) with kill -9 no matter if /dev/kvm and /dev/gru are
owned by sillyuser.

I'm afraid if you don't want to worst-case unregister with ->release
you need to have a better idea than my mm_lock and personally I can't
see any other way than mm_lock to ensure not to miss range_begin...

All the above is in 2.6.27 context (for 2.6.26 ->release is the way,
even if the genius idea would materialize).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

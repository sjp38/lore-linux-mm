Date: Wed, 30 Jan 2008 09:53:06 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-ID: <20080130155306.GA13746@sgi.com>
References: <20080130022909.677301714@sgi.com> <20080130022944.236370194@sgi.com> <20080130153749.GN7233@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130153749.GN7233@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 04:37:49PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 29, 2008 at 06:29:10PM -0800, Christoph Lameter wrote:
> > +void mmu_notifier_release(struct mm_struct *mm)
> > +{
> > +	struct mmu_notifier *mn;
> > +	struct hlist_node *n, *t;
> > +
> > +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> > +		rcu_read_lock();
> > +		hlist_for_each_entry_safe_rcu(mn, n, t,
> > +					  &mm->mmu_notifier.head, hlist) {
> > +			hlist_del_rcu(&mn->hlist);
> 
> This will race and kernel crash against mmu_notifier_register in
> SMP. You should resurrect the per-mmu_notifier_head lock in my last
> patch (except it can be converted from a rwlock_t to a regular
> spinlock_t) and drop the mmap_sem from
> mmu_notifier_register/unregister.

Agree.

That will also resolve the problem we discussed yesterday. 
I want to unregister my mmu_notifier when a GRU segment is
unmapped. This would not necessarily be at task termination.

However, the mmap_sem is already held for write by the core
VM at the point I would call the unregister function.
Currently, there is no __mmu_notifier_unregister() defined.

Moving to a different lock solves the problem.


-- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

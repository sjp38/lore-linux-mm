Subject: Re: [patch 1/6] mmu_notifier: Core code
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080130153749.GN7233@v2.random>
References: <20080130022909.677301714@sgi.com>
	 <20080130022944.236370194@sgi.com>  <20080130153749.GN7233@v2.random>
Content-Type: text/plain
Date: Wed, 30 Jan 2008 18:10:32 +0100
Message-Id: <1201713032.28547.234.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-30 at 16:37 +0100, Andrea Arcangeli wrote:
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

Agreed, sorry for this oversight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

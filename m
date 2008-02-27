Date: Wed, 27 Feb 2008 14:35:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <200802201008.49933.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com>
 <200802201008.49933.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, Nick Piggin wrote:

> On Friday 15 February 2008 17:49, Christoph Lameter wrote:
> > The invalidation of address ranges in a mm_struct needs to be
> > performed when pages are removed or permissions etc change.
> >
> > If invalidate_range_begin() is called with locks held then we
> > pass a flag into invalidate_range() to indicate that no sleeping is
> > possible. Locks are only held for truncate and huge pages.
> 
> You can't sleep inside rcu_read_lock()!

Could you be specific? This refers to page migration? Hmmm... Guess we 
would need to inc the refcount there instead?

> I must say that for a patch that is up to v8 or whatever and is
> posted twice a week to such a big cc list, it is kind of slack to
> not even test it and expect other people to review it.

It was tested with the GRU and XPmem. Andrea also reported success.
 
> Also, what we are going to need here are not skeleton drivers
> that just do all the *easy* bits (of registering their callbacks),
> but actual fully working examples that do everything that any
> real driver will need to do. If not for the sanity of the driver
> writer, then for the sanity of the VM developers (I don't want
> to have to understand xpmem or infiniband in order to understand
> how the VM works).

There are 3 different drivers that can already use it but the code is 
complex and not easy to review. Skeletons are easy to allow people to get 
started with it.

> >  	lru_add_drain();
> >  	tlb = tlb_gather_mmu(mm, 0);
> >  	update_hiwater_rss(mm);
> > +	mmu_notifier(invalidate_range_begin, mm, address, end, atomic);
> >  	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
> >  	if (tlb)
> >  		tlb_finish_mmu(tlb, address, end);
> > +	mmu_notifier(invalidate_range_end, mm, address, end, atomic);
> >  	return end;
> >  }
> >
> 
> Where do you invalidate for munmap()?

zap_page_range() called from unmap_vmas().

> Also, how to you resolve the case where you are not allowed to sleep?
> I would have thought either you have to handle it, in which case nobody
> needs to sleep; or you can't handle it, in which case the code is
> broken.

That can be done in a variety of ways:

1. Change VM locking

2. Not handle file backed mappings (XPmem could work mostly in such a 
config)

3. Keep the refcount elevated until pages are freed in another execution 
context.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

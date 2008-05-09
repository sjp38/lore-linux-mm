Date: Fri, 9 May 2008 20:55:53 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080509185553.GF7710@duo.random>
References: <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com> <20080508025652.GW8276@duo.random> <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com> <20080508034133.GY8276@duo.random> <alpine.LFD.1.10.0805072109430.3024@woody.linux-foundation.org> <20080508052019.GA8276@duo.random> <alpine.LFD.1.10.0805080759430.3024@woody.linux-foundation.org> <alpine.LFD.1.10.0805080907420.3024@woody.linux-foundation.org> <1210358249.13978.275.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1210358249.13978.275.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2008 at 08:37:29PM +0200, Peter Zijlstra wrote:
> Another possibility, would something like this work?
> 
>  
>  /*
>   * null out the begin function, no new begin calls can be made
>   */
>  rcu_assing_pointer(my_notifier.invalidate_start_begin, NULL); 
> 
>  /*
>   * lock/unlock all rmap locks in any order - this ensures that any
>   * pending start() will have its end() function called.
>   */
>  mm_barrier(mm);
> 
>  /*
>   * now that no new start() call can be made and all start()/end() pairs
>   * are complete we can remove the notifier.
>   */
>  mmu_notifier_remove(mm, my_notifier);
> 
> 
> This requires a mmu_notifier instance per attached mm and that
> __mmu_notifier_invalidate_range_start() uses rcu_dereference() to obtain
> the function.
> 
> But I think its enough to ensure that:
> 
>   for each start an end will be called

We don't need that, it's perfectly ok if start is called but end is
not, it's ok to unregister in the middle as I guarantee ->release is
called before mmu_notifier_unregister returns (if ->release is needed
at all, not the case for KVM/GRU).

Unregister is already solved with srcu/rcu without any additional
complication as we don't need the guarantee that for each start an end
will be called.

> It can however happen that end is called without start - but we could
> handle that I think.

The only reason mm_lock() was introduced is to solve "register", to
guarantee that for each end there was a start. We can't handle end
called without start in the driver.

The reason the driver must be prevented to register in the middle of
start/end, if that if it ever happens the driver has no way to know it
must stop the secondary mmu page faults to call get_user_pages and
instantiate sptes/secondarytlbs on pages that will be freed as soon as
zap_page_range starts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

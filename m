Date: Tue, 29 Apr 2008 17:30:52 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080429153052.GE8315@duo.random>
References: <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random> <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random> <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com> <20080427122727.GO9514@duo.random> <Pine.LNX.4.64.0804281332030.31163@schroedinger.engr.sgi.com> <20080429001052.GA8315@duo.random> <Pine.LNX.4.64.0804281819020.2502@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804281819020.2502@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 28, 2008 at 06:28:06PM -0700, Christoph Lameter wrote:
> On Tue, 29 Apr 2008, Andrea Arcangeli wrote:
> 
> > Frankly I've absolutely no idea why rcu is needed in all rmap code
> > when walking the page->mapping. Definitely the PG_locked is taken so
> > there's no way page->mapping could possibly go away under the rmap
> > code, hence the anon_vma can't go away as it's queued in the vma, and
> > the vma has to go away before the page is zapped out of the pte.
> 
> zap_pte_range can race with the rmap code and it does not take the page 
> lock. The page may not go away since a refcount was taken but the mapping 
> can go away. Without RCU you have no guarantee that the anon_vma is 
> existing when you take the lock. 

There's some room for improvement, like using down_read_trylock, if
that succeeds we don't need to increase the refcount and we can keep
the rcu_read_lock held instead.

Secondly we don't need to increase the refcount in fork() when we
queue the vma-copy in the anon_vma. You should init the refcount to 1
when the anon_vma is allocated, remove the atomic_inc from all code
(except when down_read_trylock fails) and then change anon_vma_unlink
to:

        up_write(&anon_vma->sem);
	if (empty)
		put_anon_vma(anon_vma);

While the down_read_trylock surely won't help in AIM, the second
change will reduce a bit the overhead in the VM core fast paths by
avoiding all refcounting changes by checking the list_empty the same
way the current code does. I really like how I designed the garbage
collection through list_empty and that's efficient and I'd like to
keep it.

I however doubt this will bring us back to the same performance of the
current spinlock version, as the real overhead should come out of
overscheduling in down_write ai anon_vma_link. Here an initially
spinning lock would help but that's gray area, it greatly depends on
timings, and on very large systems where a cacheline wait with many
cpus forking at the same time takes more than scheduling a semaphore
may not slowdown performance that much. So I think the only way is a
configuration option to switch the locking at compile time, then XPMEM
will depend on that option to be on, I don't see a big deal and this
guarantees embedded isn't screwed up by totally unnecessary locks on UP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

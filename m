Date: Thu, 13 Nov 2008 03:31:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
	one page into another
Message-ID: <20081113023135.GD10818@random.random>
References: <20081111221753.GK10818@random.random> <Pine.LNX.4.64.0811111626520.29222@quilx.com> <20081111231722.GR10818@random.random> <Pine.LNX.4.64.0811111823030.31625@quilx.com> <20081112022701.GT10818@random.random> <Pine.LNX.4.64.0811112109390.10501@quilx.com> <20081112173258.GX10818@random.random> <Pine.LNX.4.64.0811121412130.31606@quilx.com> <1226527744.7560.93.camel@lts-notebook> <20081113020059.GC10818@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081113020059.GC10818@random.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Thu, Nov 13, 2008 at 03:00:59AM +0100, Andrea Arcangeli wrote:
> CPU0 migrate.c			CPU1 filemap.c
> -------				----------
> 				find_get_page
> 				radix_tree_lookup_slot returns the oldpage
> page_count still = expected_count
> freeze_ref (oldpage->count = 0)
> radix_tree_replace (too late, other side already got the oldpage)
> unfreeze_ref (oldpage->count = 2)
> 				page_cache_get_speculative(old_page)
> 				set count to 3 and succeeds

After reading more of this lockless radix tree code, I realized this
below check is the one that was intended to restart find_get_page and
prevent it to return the oldpage:

				    if (unlikely(page != *pagep)) {

But there's no barrier there, atomic_add_unless would need to provide
an atomic smp_mb() _after_ atomic_add_unless executed. In the old days
the atomic_* routines had no implied memory barriers, you had to use
smp_mb__after_atomic_add_unless if you wanted to avoid the race. I
don't see much in the ppc implementation of atomic_add_unless that
would provide an implicit smb_mb after the page_cache_get_speculative
returns, so I can't see why the pagep can't be by find_get_page read
before the other cpu executes radix_tree_replace in the above
timeline.

I guess you intended to put an smp_mb() in between the
page_cache_get_speculative and the *pagep to make the code safe on ppc
too, but there isn't, and I think it must be fixed, either that or I
don't understand ppc assembly right. The other side has a smp_wmb
implicit inside radix_tree_replace_slot so it should be ok already to
ensure we see the refcount going to 0 before we see the pagep changed
(the fact the other side has a memory barrier, further confirms this
side needs it too).

BTW, the radix_tree_deref_slot might miss a rcu_barrier_depends()
after radix_tree_deref_slot returns but I'm not entirely sure and only
alpha would be affected in the worst case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

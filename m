Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E5B0B6B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 16:21:50 -0400 (EDT)
Date: Thu, 12 Jul 2012 22:21:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 40/40] autonuma: shrink the per-page page_autonuma struct
 size
Message-ID: <20120712202122.GS20382@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-41-git-send-email-aarcange@redhat.com>
 <4FF14B56.9090906@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF14B56.9090906@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Mon, Jul 02, 2012 at 03:18:46AM -0400, Rik van Riel wrote:
> On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> >  From 32 to 12 bytes, so the AutoNUMA memory footprint is reduced to
> > 0.29% of RAM.
> 
> Still not ideal, however once we get native THP migration working
> it could be practical to switch to a "have a bucket with N
> page_autonuma structures for every N*M pages" approach.
> 
> For example, we could have 4 struct page_autonuma pages, for 32
> memory pages. That would necessitate reintroducing the page pointer
> into struct page_autonuma, but it would reduce memory use by roughly
> a factor 8.
> 
> To get from a struct page to a struct page_autonuma, we would have
> to look at the bucket and check whether one of the page_autonuma
> structs points at us. If none do, we have to claim an available one.
> On migration, we would have to free our page_autonuma struct, which
> would make it available for other pages to use.
> 
> This would complicate the code somewhat, and potentially slow down
> the migration of 4kB pages, but with 2MB pages things could continue
> exactly the way they work today.
> 
> Does this seem reasonably in any way?

Reducing the max lru size loses info too. The thing I dislike is that
knuma_migrated may not migrate the page until a few knuma_scand passed
on large systems (giving a chance to last_nid_set to notice if there's
false sharing and cancel the migration). I conceptually like the
unlimited sized LRU migration list.

The other cons is that it'll increase the complexity even more by
having to deal with dynamic objects instead of an extension of the
struct page.

And the 2bytes for the last_nid information would need to be retained
for every page, unless we drop the last_nid logic which I doubt would
be good.

And the alternative without an hash is not feasible: one could reduce
it to 8bytes per-page (for the pointer to the page_autonuma structure)
plus 2 bytes for last_nid, so 10 bytes per page plus the actual array,
instead of the current 12 bytes per page.

> I also wonder if it would make sense to have this available as a
> generic list type, not autonuma specific but an "item number list"
> include file with corresponding macros.
> 
> It might be useful to have lists with item numbers, instead of
> prev & next pointers, in other places in the kernel.
> 
> Besides, introducing this list type separately could make things
> easier to review.

Macros bypassing type checking usually aren't recommended and
certainly it's more readable as it is now. But this can always be done
later if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

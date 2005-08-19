Date: Thu, 18 Aug 2005 18:33:14 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0508181822520.2740@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, piggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Aug 2005, Hugh Dickins wrote:

> There's a lot about atomic pte ops in this thread, but it's a pte
> cmpxchg which do_anonymous_page has to do - if I remember PaulMcK's
> bogroll rightly, cmpxchgs are extra bad news.

Same badness as spin_lock yes but they serialize for extremely small time 
periods. So they are better than spinlock.

> Christoph and Nick are keen to go further, deeper into the atomics
> and cmpxchgs, away from the page table lock.  Is that sensible when
> we have batch operations like zap_pte_range and copy_pte_range?

I did a batch faulting scheme last year too. See 
http://marc.theaimsgroup.com/?l=linux-kernel&m=110488578521535&w=2

> How many architectures have been converted to ATOMIC_TABLE_OPS
> (could we call that ATOMIC_PAGE_TABLE_OPS?): just ia64, x86_64
> and i386.  i386 being a joke, since it's only the non-PAE case
> which is converted, yet surely anyone getting into a serious
> number of cpus on i386 will be using PAE?

Right. This is just a start. If it would be in the kernel then other 
people will do the work as I have heard repeatedly. Chicken-Egg.

> I may well be to blame for this.  Perhaps my hostility has
> discouraged others from doing the work to add to what's there.
> Certainly it was me who advised Christoph to drop the i386 PAE
> support he originally had, since it was too ugly and buggy.

PAE support can be added within the framework provided by these 
patches.

> And it was probably my resistance to the per-task rss patch which
> has led him to hold that back for now.  I think wisely, that is a
> separate issue.  But from what Linus says, it does rather look like
> we can't sensibly go forward with anonymous pte cmpxchging, without
> a matching rss solution.

I am working on getting the bit rot out of my old patches. This is going 
to take a few days.

> matter.  (There were three places in rmap.c which avoided rss 0 mms,
> but that was a historic necessity: I've deleted those checks from the
> rmap.c waiting in -mm.)  Can't we just let them be racy?

Its great that these are gone. I just tried to find them and was happy to 
discover they were already gone.

> With the page table lock moved inward, we can then easily choose to
> use a per-pagetable lock, to handle the page fault scalability issue
> without departing far from our existing locking conventions.  Indeed,
> I have a working prototype for that, but I don't have equipment to test
> scalability on SGI's scale, and on my 2*HT*Xeons the best results are
> coming from just narrowing the page table lock, not from splitting it.

I have tried that last year too. I thought you helped me see the light on 
the futility of that approach?

> I find proceeding in this way easier to understand, and would myself
> prefer Christoph's patches removed from -mm, so we can build the
> narrower page_table_lock solution there, then see what works best
> as a scalability solution on top - per-pagetable locking, or pte
> cmpxchging.  But we all find our own ways easier to understand.

Oh no. We have been there before and I fear that if this gets removed then there 
will be no progress for a long time like before. Please at least leave the 
first patch in which provides an infrastructure for atomic pte operations 
that may then be deployed in a variety of ways and be useful for 
approaches that Hugh or Nick may come up with.

> You might like me to post my patch for testing (not for merging into
> any tree at this stage): please give me a couple of days to jiggle
> around with it first.

I'd be interested to see if you can really come up with anything that we 
have not tried yet.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

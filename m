Subject: "Noreclaim Infrastructure"  [was Re: [PATCH 01 of 16] remove
	nr_scan_inactive/active]
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070629141254.GA23310@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	 <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random>
	 <46814829.8090808@redhat.com>
	 <20070626105541.cd82c940.akpm@linux-foundation.org>
	 <468439E8.4040606@redhat.com> <1183124309.5037.31.camel@localhost>
	 <20070629141254.GA23310@v2.random>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 18:39:01 -0400
Message-Id: <1183156742.7012.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-29 at 16:12 +0200, Andrea Arcangeli wrote:
> On Fri, Jun 29, 2007 at 09:38:29AM -0400, Lee Schermerhorn wrote:
<snip>
> 
> > Here's a fairly recent version of the patch if you want to try it on
> > your workload.  We've seen mixed results on somewhat larger systems,
> > with and without your split LRU patch.  I've started writing up those
> > results.  I'll try to get back to finishing up the writeup after OLS and
> > vacation.
> 
> This looks a very good idea indeed.
> 
> Overall the O(log(N)) change I doubt would help, being able to give an
> efficient answer to "give me only the vmas that maps this anon page"
> won't be helpful here since the answer will be the same as the current
> question "give me any vma that may be mapping this anon page". Only
> for the filebacked mappings it matters.
> 
> Also I'm stunned this is being compared to a java workload, java is a
> threaded beast (unless you're capable of understanding async-io in
> which case it's still threaded but with tons less threads, but anyway
> you code it won't create any anonymous related overhead). What we deal
> with isn't really an issue with anon-vma but just with the fact the
> system is trying to unmap pages that are mapped in 4000-5000 pte, so
> no matter how you code it, there will be still 4000-5000 ptes to check
> for each page that we want to know if it's referenced and it will take
> system time, this is an hardware issue not a software one. And the
> other suspect thing is to do all that pte-mangling work without doing
> any I/O at all.

Andrea:

Yes, the patch is not a panacea.  At best, it allows different kswapd's
to attempt to unmap different pages associated with the same VMA.  But,
as you say, you still have to unmap X000 ptes.  On one of the smaller
ia64 systems we've been testing, we hit this state in the 15000-20000
range of AIM jobs.  This patch, along with Rik's split LRU patch allowed
us to make forward progress at saturation, and we were actually
swapping, instead of just spinning around in page_referenced() and
try_to_unmap().  [Actually, I don't think we get past page_referenced()
much w/o this patch--have to check.]

I have experimented with another "noreclaim" infrastructure, based on
some patches by Larry Woodman at Red Hat, to keep non-reclaimable pages
off the active/inactive list.  I envisioned this as a general
infrastructure to handle this case--pages whose anon_vmas have
excessively long vma lists, swap-backed pages for which no swap space is
available and mlock()ed pages [a la Nick Piggin's patch].  

I will include the patch overview here and send along the 2
infrastructure patches and one "client" patch--the excessively
referenced anon_vma case.  I'm not proposing that these be considered
for inclusion.  Just another take on this issue.

The patches are against 2.6.21-rc6.  I have been distracted by other
issues lately, so they have languished, and even the overview is a bit
out of date relative to on-going activity in this area.  I did integrate
this series with Rik's split LRU patch at one time, and it all "worked"
for some definition thereof. 

One final note before the "noreclaim overview":  I have seen similar
behavior on the i_mmap_lock for file back pages running a [too] heavy
Oracle/TPC-C workload--on a larger ia64 system with ~8TB of storage.
System hung/unresponsive, spitting out "Soft lockup" messages.  Stack
traces showed cpus in spinlock contention called from
page_referenced_file.  So, it's not limited to anon pages.

Lee
-----------------


This series of patches introduces support for mananaging "non-reclaimable"
pages off the LRU active and inactive list.   In this rather long-winded 
overview, I attempt to provide the motivation for this work, describe how
it relates to other recent patches that address different aspects of the
"problem", and give an overview of the mechanism.  I'll try not to repeat
too much of this in the patch descriptions.


We have seen instances of large linux servers [10s/100s of GB of memory =>
millions of pages] apparently hanging for extended periods [10s or minutes
or more] while all processors attempt to reclaim memory.  For various
reasons many of the pages on the LRU lists become difficult or impossible
to reclaim.  The system spends a lot time trying to reclaim [unmap] the
difficult pages and/or shuffling through the impossible ones.

Some of the conditions that make pages difficult or impossible to reclaim:
  1) page is anon or shmem, but no swap space available
  2) page is mlocked into memory
  3) page is anon with an excessive number of related vmas [on the
     anon_vma list].  More on this below.

The basic noreclaim mechanism, described below, is based
on a patch developed by Larry Woodman of Red Hat for RHEL4 [2.6.9+ based
kernel] to address the first condition above--an x86_64 non-NUMA system 
with 64G-128G memory [16M-32M 4k pages] with very little swap space--
~2GB.  The majority of the memory on the system was consumed by large
database shared memory areas.  A file IO intensive operation, such as
backup, causes remaining free memory to be consumed by the page cache,
initiating reclaim.

vmscan then spends a great deal of time shuffling non-swappable anon
and shmem pages between the active to the inactive lists, only to find
that it can't move them to the swap cache.  The pages get reactivated
and round and round it goes.  Because pages cannot be easily reclaimed,
eventually other processors need to allocate pages and enter direct
reclaim, only to compete for the zone lru lock.  The single [normal]
zone on the non-numa platform exacerbates this problem, but it can 
also arise, per zone, on numa platforms.

Larry's patch alleviates this problem by maintaining anon and shmem
pages for which no swap space exists on a per zone noreclaim list.
Once the pages have been parked there, vmscan deals only with page
cache pages, and anon/shmem pages to which space space has already
been assigned.  Pages move from the noreclaim list back to the LRU
when swap space becomes available.

Upstream developers have been addressing some of these issues in other
ways:

Christoph Lameter posted a patch to keep anon pages off the LRU when SWAP
support not configured into the kernel.  With Christoph's patch, these
pages are left out "in limbo"--not on any list.  Because of this,
Christoph's patch does not address the more common situation of kernels
with SWAP configured in, but insufficient or no swap added.  I think this
is a more common situation because most distros will ship kernels with
the SWAP support configured in--at least for "enterprise" use.  Maintaining
these pages on a noreclaim list, will make it possible to restore these
pages to the [in]active lists when/if swap is added.

Nick Piggin's patch to keep mlock'ed pages [condition 2 above] off the
LRU list also lets the mlocked/non-reclaimable pages float, not on any
list.  While Nick's patch does allow these pages to become reclaimable
when all memory locks are removed, there is another reason to keep pages
on a separate list.

We want to be able to migrate anon pages that have no swap space backing
them, and those that are mlocked.  Indeed, the migration infrastructure
supports this.  However, the LRU lists, via the zone lru locks, arbitrate
between tasks attempting to migrate the same pages simultaneously.  To
migrate a page, we must isolate it from the LRU.  If the page cannot be
isolated, migration gives up and moves on to another page.  Which ever
task is successful in isolating the page proceeds with the migration.
Keeping the nonreclaimable pages on a separate list, protected by the
zone lru lock, would preserve this arbitration function.  isolate_page_lru(),
used by both migration and Nick's mlock patch, can be enhanced to find
pages on the noreclaim list, as well as on the [in]active lists.

What's the probability that tasks will race on migrating the same page?
Fairly high if auto-migration ever makes it into the kernel, but non-zero
in any case.

Rik van Reil's patch to split the active and inactive lists can address
the non-swappable page problem by throttling the scan of the anon LRU
lists, that contain both anon and shmem pages.  However, if the system
supports any swap space at all, one still needs to scan the anon lists
to free up memory consumed by pages already in the swap cache.  On
large memory systems, the anon lists can still be millions of pages 
long and contain a large per centage of non-swappable and mlocked
pages.

This series attempts to unify this work into a general mechanism for
managing non-reclaimable pages.  The basic objective is to make vmscan
as productive as possible on very large memory systems, by eliminating
non-productive page shuffling.

Like Larry's patch, the noreclaim infrastructure maintains "non-reclaimable"
pages on a separate per-zone list.  This noreclaim list is, conceptually,
another LRU list--a sibling of the active and inactive lists.  A page on
the noreclaim list will have the PG_lru and PG_noreclaim flags set.  The
PG_noreclaim flag is analogous to, and mutually exclusive with, the
PG_active flag--it specifies which LRU list the page resides on.  The
noreclaim list supports a pagevec cache, like the active and inactive
lists to reduce contention on the zone lru lock in vmscan and in the
fault path.

Pages on the noreclaim list are "hidden" from page reclaim scanning.  Thus,
reclaim will not spend time attempting to reclaim the pages, only to find
that they can't be unmapped, have no swap space available, are locked into
memory, ...  However, vmscan may find pages on the [in]active lists that
have become non-reclaimable since they were put on the list.  It will
move them to the noreclaim list at that time.

This series of patches includes the basic noreclaim list support and one
patch, as a proof of concept, to address the 3rd condition listed above:
the excessively long anon_vma list of related vmas.  This seemed to be
the easiest of the 3 conditions to address, and I have a test case
handy [AIM7--see below].  Additional patches to handle anon pages for
which no swap exists and to layer Nick Piggin's patch to keep "mlock
pages off the LRU" will be forthcoming, if feedback indicates that
this approach is worth pursuing.


Now, about those anon pages with really long "related vma" lists:
We have only seen this in AIM7 benchmarks on largish servers.  The situation
occurs when a single task fork()s many [10s of] thousands of children, and
the the system needs to reclaim memory.  We've seen all processors on a
system spinning on the anon_vma lock attempting to unmap pages mapped
by these thousands of children--for 10s of minutes or until we give up
and reboot.

I discussed this issue at LCA'07 in a kernel miniconf presentation.
Linus questioned whether this was a problem that really needs solving.
After all, AIM7 is only a synthetic benchmark.  Does any real application 
behave this way?   After the presentation, someone came up to me and told
me that Apache also fork()s for each incoming connection and can fork
thousands of children.  However, I have not witnessed this, nor do I
know how long lived these children are.

I have included another patch that makes the anon_vma lock a reader/write
lock.  This allows different cpus to attempt to reclaim, in parallel,
different pages that point to the same anon_vma.  However, this doesn't
solve the problem of trying to unmap pages that are [potentially] mapped
into thousands of vmas.

The last patch in this series counts the number of related vmas on an 
anon_vma's list and, when it exceeds a tunable threshold, pages that 
reference that anon_vma are declared nonreclaimable.  We detect these
non-reclaimable pages either on fault [COW or new anon page in a vma with
an excessively shared anon_vma] or when vmscan encounters such a page on
the LRU list.  

The patch/series does not [yet] support moving such a page back to the
[in]active lists when it's anon_vma sharing drops below the threshold.
This usually occurs when a task exits or explicitly unmapps the area.
Any COWed private pages will be freed at this time, but anon pages that
are still shared will remain nonreclaimable even though the related vma
count is below the no-reclaim limit.  Again, I will address this if the
overall approach is deemed worth pursuing.

Additional considerations:

If the noreclaim list contains mlocked pages, they can be directly deleted
from the noreclaim list without scanning when the become unlocked.  But,
note that we can't use one of the lru link fields to contain the mlocked
vma count in this case.

If the noreclaim list contains anon/shmem pages for which no swap space
exists, it will be necessary to scan the list when swap space becomes
available, either because it has been freed from other pages, or because
additional swap has been added.  The latter case should not occur 
frequently enough to be a problem.  We should be able to defer the
scanning when swap space is freed from other pages until a sufficient
number become available or system is under severe pressure.

If the list contains pages that are merely difficult to reclaim because
of the excessive anon_vma sharing, and if we want to make them reclaimable
again when the anon_vma related vma count drops to an acceptable value,
one would have to scan the list at some point.  Again, this could be 
deferred until there are a sufficient number of such pages to make it
worth while or until the system is under severe memory pressure.

The above considerations suggest that one consider separate lists for
non-reclaimable [no swap, mlocked] and difficult to reclaim.   Or,
maybe not...

Interaction of noreclaim list and LRU lists:  My current patch moves
pages to the noreclaim list as soon as they are detected, either on the
active or inactive list.  I could change this such that non-reclaimable
pages found on the active list go to the inactive list first, and 
take a ride there before being declared non-reclaimable.  However, 
we still have the issue of where to place the pages when then come off
the no reclaim list:  back to the active list?  the inactive list?
head or tail thereof?  My current mechanism, with the PG_active and
PG_noreclaim flags being mutually exclusive, does not track activeness
of pages on the noreclaim list.  To do so would require additional
scanning of the list, I think, sort of defeating the purpose of the
list.  But, maybe acceptable if we scan just to test/modify the active
flags.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

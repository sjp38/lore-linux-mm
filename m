Date: Tue, 5 Dec 2006 13:39:54 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: la la la la ... swappiness
Message-Id: <20061205133954.92082982.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612051254110.19561@schroedinger.engr.sgi.com>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
	<Pine.LNX.4.64.0612050754020.3542@woody.osdl.org>
	<20061205085914.b8f7f48d.akpm@osdl.org>
	<f353cb6c194d4.194d4f353cb6c@texas.rr.com>
	<Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
	<Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
	<20061205120256.b1db9887.akpm@osdl.org>
	<Pine.LNX.4.64.0612051207240.18863@schroedinger.engr.sgi.com>
	<20061205124859.333d980d.akpm@osdl.org>
	<Pine.LNX.4.64.0612051254110.19561@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Aucoin <aucoin@houston.rr.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006 12:59:14 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 5 Dec 2006, Andrew Morton wrote:
> 
> > > This is the same scenario as mlocked memory.
> > 
> > Not quite - mlocked pages are on the page LRU and hence contribute to the
> > arithmetic in there.   The hugetlb pages are simply gone.
> 
> They cannot be swapped out and AFAICT the ratio calculations are assuming 
> that pages can be evicted.

Some calculations assume that.  But a lot (most) of the reclaim code is
paced by number-of-pages-scanned.  mlocked pages on the LRU will be noted
by the scanner and will cause priority elevation, throttling, etc.  Pages
which have been gobbled by hugetlb will not.

> > > So if a 
> > > cpuset is just 1/10th of the whole machine then we will never be able to 
> > > reach the dirty limits, all the nodes of a cpuset may be filled up with 
> > > dirty pages. A simple cp of a large file will bring the machine into a 
> > > continual reclaim on all nodes.
> > 
> > It shouldn't be continual and it shouldn't be on all nodes.  What _should_
> 
> I meant all nodes of the cpuset.
> 
> > happen in this situation is that the dirty pages in those zones are written
> > back off the LRU by the vm scanner.
> 
> Right in the best case that occurs.

We want it to work in all cases.

> However, since we do not recognize 
> that we are in a dirty overload situation we may not do synchrononous 
> writes but return without having reclaimed any memory

Return from what?  try_to_free_pages() or balance_dirty_pages()?

The behaviour of page reclaim is independent of the level of dirty memory
and of the dirty-memory thresholds, as far as I recall...

> (a particular 
> problem exists here in connections with NFS well known memory 
> problems). If memory gets completely clogged then we OOM.

NFS causes problems because it needs to allocate memory (skbs) to be able
to write back dirty memory.  There have been fixes and things have
improved, but I wouldn't be surprised if there are still problems.

> > That's less efficient from an IO scheduling POV than writing them back via
> > the inodes, but it should work OK and it shouldn't affect other zones.
> 
> Could we get to the inode from the reclaim path and just start writing out 
> all dirty pages of the indoe?

Yeah, maybe.  But of course the pages on the inode can be from any zone at
all so the problem is that in some scenarios, we could write out tremendous
numbers of pages from zones which don't need that writeout.

> > If the activity is really "continual" and "on all nodes" then we have some
> > bugs to fix.
> 
> Its continual on the nodes of the cpuset. Reclaim is constantly running 
> and becomes very inefficient.

I think what you're saying is that we're not throttling in
balance_dirty_pages().  So a large write() which is performed by a process
inside your one-tenth-of-memory cpuset will just go and dirty all of the
pages in that cpuset's nodes and things get all gummed up.

That can certainly happen, and I suppose we can make changes to
balance_dirty_pages() to fix it (although it will have the
we-wrote-lots-of-pages-we-didnt-need-to failure mode).

But right now in 2.6.19 the machine should _not_ declare oom in this
situation.  If it does, then we should fix that.  If it's only happening
with NFS then yeah, OK, mumble, NFS still needs work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

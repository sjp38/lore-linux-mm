Date: Tue, 5 Dec 2006 15:20:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: la la la la ... swappiness
In-Reply-To: <20061205133954.92082982.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0612051507000.20570@schroedinger.engr.sgi.com>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
 <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org> <20061205085914.b8f7f48d.akpm@osdl.org>
 <f353cb6c194d4.194d4f353cb6c@texas.rr.com> <Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
 <Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
 <20061205120256.b1db9887.akpm@osdl.org> <Pine.LNX.4.64.0612051207240.18863@schroedinger.engr.sgi.com>
 <20061205124859.333d980d.akpm@osdl.org> <Pine.LNX.4.64.0612051254110.19561@schroedinger.engr.sgi.com>
 <20061205133954.92082982.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Aucoin <aucoin@houston.rr.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006, Andrew Morton wrote:

> > However, since we do not recognize 
> > that we are in a dirty overload situation we may not do synchrononous 
> > writes but return without having reclaimed any memory
> 
> Return from what?  try_to_free_pages() or balance_dirty_pages()?

If we do not reach the dirty_ratio then we will not block but simply 
trigger writeouts.

try_to_free_pages() will trigger pdflush and we may wait 1/10th of a 
second in congestaion_wait() and in throttle_vm_writeout() (well not 
really since we check global limits) but we will not block. I think what 
happens is that try_to_free_pages() (given sufficient slowless of the 
writeout) at some point will start to return 0 and thus 
we OOM.

> The behaviour of page reclaim is independent of the level of dirty memory
> and of the dirty-memory thresholds, as far as I recall...

You cannot easily free a dirty page. We can only trigger writeout.

> > Could we get to the inode from the reclaim path and just start writing out 
> > all dirty pages of the indoe?
> 
> Yeah, maybe.  But of course the pages on the inode can be from any zone at
> all so the problem is that in some scenarios, we could write out tremendous
> numbers of pages from zones which don't need that writeout.

But we know that at least one page was in the correct zone. Writeout will 
be much faster if we can write a seris of block in sequence via the inode.

> > Its continual on the nodes of the cpuset. Reclaim is constantly running 
> > and becomes very inefficient.
> 
> I think what you're saying is that we're not throttling in
> balance_dirty_pages().  So a large write() which is performed by a process
> inside your one-tenth-of-memory cpuset will just go and dirty all of the
> pages in that cpuset's nodes and things get all gummed up.

Correct.
 
> That can certainly happen, and I suppose we can make changes to
> balance_dirty_pages() to fix it (although it will have the
> we-wrote-lots-of-pages-we-didnt-need-to failure mode).

Right. In addition to checking the limits of the nodes in the current 
cpuset (requires looping over all nodes and adding up the counters we 
need) I made some modification to pass a set of nodes in the 
writeback_control structure. We can then check if there are sufficient 
pages of the inode within the nodes of the cpuset. But I am a bit 
concerned about performance.

> But right now in 2.6.19 the machine should _not_ declare oom in this
> situation.  If it does, then we should fix that.  If it's only happening
> with NFS then yeah, OK, mumble, NFS still needs work.

We OOM only in some rare cases. Mostly it seems that the
machines just becomes extremely slow and the LRU locks become hot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

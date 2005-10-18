Subject: Re: [Lhms-devel] Re: [PATCH 0/2] Page migration via Swap V2:
	Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <4354696D.4050101@jp.fujitsu.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
	 <4354696D.4050101@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 18 Oct 2005 10:27:34 -0400
Message-Id: <1129645654.5146.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, lhms-devel@lists.sourceforge.net, "Avelino F. Zorzo" <zorzo@inf.pucrs.br>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-10-18 at 12:18 +0900, KAMEZAWA Hiroyuki wrote:
> Hi,
> 
> Christoph Lameter wrote:
> 
> > The disadvantage over direct page migration are:
> > 
> > A. Performance: Having to go through swap is slower.
> > 
> > B. The need for swap space: The area to be migrated must fit into swap.
> > 
> I think migration cache will work well for A & B :)
> migraction cache is virtual swap, just unmap a page and modifies it as a swap cache.

I submitted a "reworked" migration cache patch back on 20sep:

http://marc.theaimsgroup.com/?l=lhms-devel&m=112724852823727&w=4

The "rework", based on a conversation with Marcello, attempts to hide
most of the migration cache behind the swap interface.  Of course, the
decision to add a page to the swap cache vs the migration cache must be
explicit, but once added to either cache a page can be manipulated
almost entirely via [slightly modified] swap APIs to limit propagation
of changes to other parts of vm.

I have used this version of the migration cache successfully with Ray
Bryant's manual page migration [based on a 2.6.13-rc3-git7-mhp2 tree]
and with a prototype "lazy page migration" patch [work in progress] that
works similar to Christoph's current patch under discussion.

> 
> > C. Placement of pages at swapin is done under the memory policy in
> >    effect at that time. This may destroy nodeset relative positioning.
> > 
> How about this ?
> ==
> 1. do_mbind()
> 2. unmap and moves to migraction cache
> 3. touch all pages

Touching all pages could be optional [an additional flag to mbind()].
Then a process only migrates pages as they are used.  Maybe not all of
the pages marked for migration will actually be used by the process
before one decides to migrate it again.  However, then we'd need a way
to find pages in the migration cache and move them to the swap cache for
page out under memory pressure.  Marcello mentioned this way back when
he first proposed the migration cache.  I'm thinking that shrink_list()
could probably do this when it finds an anon page in the "swap cache"--
i.e., check if it's really in the migration cache and if may_swap, move
it to the swap cache.

> ==
> For 3., 2. should gather all present virtual address list...
> 
> D. We need another page-cache migration functions for moving page-cache :(
>     Moving just anon is not for memory-hotplug.
>     (BTW, how should pages in page cache be affected by memory location control ??
>      I think some people discussed about that...)

If when scanning a range of virtual addresses [from mbind()], one
encounters non-anon pages and unmaps them [e.g., via page_migratable()-
>try_to_unmap()], they can be refaulted from the cache or backing store
on next touch.  Of course, they won't have been migrated yet.  We'd need
to mark the pages to be tested for migration in the fault path.  I've
used a "PageCheckPolicy" flag [yet another page flag :-(] to indicate
that the page location must be checked against the policy at fault time.
This is less expensive than querying the policy for the 'correct'
location on each fault.  Note that pages in the migration must also be
so marked because they aren't swapped out.  Similar for pages in the
swap cache if they aren't actually swapped out.  We'd need to clear this
flag when the pages are freed if they haven't been migrated yet [flag is
tested/cleared in fault path].


Regards,
Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 26 Apr 2000 07:33:55 -0700
Message-Id: <200004261433.HAA13894@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0004261041420.16202-100000@duckman.conectiva>
	(message from Rik van Riel on Wed, 26 Apr 2000 10:46:03 -0300 (BRST))
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <Pine.LNX.4.21.0004261041420.16202-100000@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: sct@redhat.com, sim@stormix.com, jgarzik@mandrakesoft.com, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   > I am of the opinion that vmscan.c:swap_out() is one of our
   > biggest problems, because it kills us in the case where a few
   > processes have a pagecache page mapped, haven't accessed it in a
   > long time, and swap_out doesn't unmap those pages in time for
   > the LRU shrink_mmap code to fully toss it.

   Please take a look at the patch I sent to the list a few
   minutes ago. The "anti-hog" code, using swap_out() as a
   primary mechanism for achieving its goal, seems to bring
   some amazing results ... for one, memory hogs no longer
   have a big performance impact on small processes.

It's a nice change considering we are so close to 2.4.x
but long term I still contend that swap_out is a hack that
should die soon.

   I believe that it will be pretty much impossible to achieve
   "fair" balancing with any VM code which weighs all pages the
   same. And before you start crying that all pages should be
   weighed the same to protect the performance of that important
   memory hogging server process, the fact that it'll be the only
   process waiting for disk and that its pages are aged better
   often make the memory hog run faster as well! ;)

Let's start at square one.  I have never suggested that we weigh
all pages the same.  Global aging of all pages, on the other hand,
is something completely different.  It doesn't treat all pages the
same, it treats them all differently based upon how people are using
the page.

Inactive pages are inactive pages are inactive pages, regardless of
who has used them or what they are being used specifically for.  Let
me give a rough outline of what kind of paging algorithm I am
suggesting:

check_page_references(page)
{
	if (TestAndClearReferenced(page) ||
	    (page->mapping->i_mmap &&
	     test_and_clear_pgtable_references(page)))
		return 1;
	return 0;
}

populate_inactive_list(long goal_pages)
{
	for each active lru page {
		if (! check_page_references(page)) {
			add_to_inactive_lru(page)
			if (--goal_pages <= 0)
				break;
		}
		add page back to head of active lru
	}
}

free_inactive_pages(long goal_pages)
{
	for each inactive lru page {
		if (check_page_references(page)) {
			add page back to active lru
		} else if (page_dirty_somewhere(page)) {
			add page to head of dirty lru
		} else {
			if (page->buffers) {
				... deal with them just like current code ...
			}
			mapping = page->mapping;
			if (! mapping->a_ops->try_to_free_page(page)) {
				add page to head of inactive lru
			} else {
				if (--goal_pages <= 0)
					break;
			}
		}
	}
}

swap_out_dirty_pages(long goal_pages)
{
	for each dirty lru page {
		try to swap it out, you get the idea
	}
}

Some salient points about what is missing in this suggested
infrastructure:

1) There is no metric mentioned for handling pages that reactivate
   themselves often (ie. get referenced while they are on the
   inactive list), one is certainly needed.

   A simple scheme would be a counter in the page struct which we
   increment (up to some MAX value) when the page gets moved back
   to the active list from the inactive list.  Then the inactive list
   population decrements this counter when it finds the page
   unreferenced, and only if the counter comes down to zero does it
   actually move the page to the inactive list.

   Some more heuristics could be added to this simple scheme, such
   as adding to this counter in the number of references seen at a
   reactivation event.

2) There are no methods mentioned to control when we actually do
   the page table walks, if and when to delete the user mappings
   for an inactive page to get the counts down to just the mapping
   owning it, etc.  These sorts of heuristics would be needed to
   for a well tuned implementation.

Next, let's assume we have the above and the general try_to_free_pages
toplevel code does something like:

try_to_free_pages()
{
	goal = number_of_freepages_we_would_like_to_have -
		nr_free_pages;

	free_inactive_pages(goal);
	populate_inactive_list(sysctl_inactive_list_goal /* or whatever */);
	if (nr_free_pages >= goal)
		break;

	goal = number_of_freepages_we_would_like_to_have -
		nr_free_pages;
	swap_out_dirty_pages(goal);
}

[ AMAZING, astute readers will notice that all of this looks
  suspiciously familiar to sys/vm/vm_paging.c in the freebsd
  sources, and this is not by accident.

  Sometimes I wonder if I am the only person who went and checked
  out what they were doing when the accusations went flying around
  that our paging sucks.  ]

You get the idea, and next we have kswapd wake up periodically to
just do populate_inactive_list() runs to keep the inactive lru
list ready to go at the onset of future paging.  Of course, kswapd
does forces try_to_free_pages runs when memory starts to run low, just
like it does now.

Now what will such a scheme like the above (remember, swap and
anonymous pages are in these LRU queues too) do in the memory hog
case you mentioned?

The big problem I have with the memory hog hacks is that it needs to
classify _processes_ to work effectively in some set of cases.  When
what we really are concerned about is classification of _pages_, and
the system just does this naturally by setting dirty/referenced state
on the page->flags and the ptes which map those pages.

See?  The global LRU scheme dynamically figures out what page usage is
like, it doesn't need to classify processes in a certain way, because
the per-page reference and dirty state will drive the page liberation
to just do the right thing.

Also, the anon layer I posted earlier today also allows us to provide
the strict swap reservation people cry for from time to time, since we
track all anonymous pages, we can do a "nr_swap_pages--" check and
fail if it would hit zero.  The only hard part about this would be
adding a way to specify the boot time swap device before the first
process is executed, or just ignore this issue and only worry about
swap space reservation when the swap is actually enabled during the
init scripts.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

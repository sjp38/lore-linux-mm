Date: Sun, 7 Jan 2001 22:42:11 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <200101080602.WAA02132@pizda.ninka.net>
Message-ID: <Pine.LNX.4.10.10101072223160.29065-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ MM people Cc'd, because while I have a plan, I don't have enough time to
  actually put that plan in action. And mayb esomebody can shoot down my
  brilliant plan. ]

On Sun, 7 Jan 2001, David S. Miller wrote:
> 
> BTW, this reminds me.  Now that you keep track of the "all mm's" list
> thingy, you can also keep track of "nr_mms" in the system and do that
> little:
> 
> 	for (i = 0; i < (nr_mms >> priority); i++)
> 		pagetable_scan();
> 
> thing you were talking about last week.

This is the whole reason for making that list in the first place. 

Even more subtle: see the comment in kernel/fork.c about keeping the list
of mm's in order. What I _really_ want to do is something like

void swap_out(void)
{
	for (i = 0; i < (nr_mms >> priority); i++) {
		struct list_head *p;
		struct mm_struct *mm;

		spin_lock(&mmlist_lock);
		p = initmm.mmlist.next;
		if (p != &initmm.mmlist) {
			struct mm_struct *mm = list_entry(p, struct mm_struct, mmlist);

			/* Move it to the back of the queue */
			list_del(p);
			__list_add(p, initmm.mmlist.prev, &initmm.mmlist);
			atomic_inc(&mm->mm_users);
			spin_unlock(&mmlist_lock);

			swap_out_mm(mm);
			continue;
		}
		/* empty mm-list - shouldn't really happen except during bootup */ 
		spin_unlock(&mmlist_lock);
		break;
	}
}

and just get rid of all the logic to try to "find the best mm". It's bogus
anyway: we should get perfectly fair access patterns by just doing
everything in round-robin, and each "swap_out_mm(mm)" would just try to
walk some fixed percentage of the RSS size (say, something like

	count = (mm->rss >> 4)

and be done with it.

Then, with something like the above, we just try to make sure that we scan
the whole virtual memory space every once in a while. Make the "every once
in a while" be some simple heuristic like "try to keep the active list to
less than 50% of all memory". So "try_to_free_memory()" would just start
off with something like

	/*
	 * Too many active pages? That implies that we don't have enough
	 * of a working set for page_launder() to do a good job. Start by
	 * walking the VM space..
	 */
	if ((nr_active_pages >> 1) > total_pages)
		swap_out();

	/*
	 * This is where we actually free memory
	 */
	page_launder(..);

and we'd be all done. (And that "max 50% of all pages should be active"
number was taken out of my ass. AND the above will work really badly if
there is no swap-space, so it needs tweaking - think of it not as a hard
algorithm, but more as a "this is where I think we need to go").

Advantage: it automatically does the right thing: if the reason for the
memory pressure is that we have lots of pages mapped, it will scan the VM
lists. If the reason is that we just have tons of pages cached, it won't
even bother to age the page tables.

Right now we have this cockamamy scheme to try to balance off the lists
against each other, and then at fairly random points we'll get to
"swap_out()" if we haven't found anything nice on the other lists. That's
just not the way to get nice MM behaviour.

I'll bet you $5 USD that the above approach will (a) work fairly and
(b) give much smoother behavior with a much more understandable swap-out
policy.

Of course, I've been wrong before. But I'd like somebody to take a look.

Anybody?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

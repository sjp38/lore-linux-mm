Date: Fri, 17 Mar 2000 14:07:09 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: More VM balancing issues..
In-Reply-To: <38D2A2E3.A2CEA602@av.com>
Message-ID: <Pine.LNX.4.10.10003171330050.987-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Ben LaHaise <bcrl@redhat.com>, Christopher Zimmerman <zim@av.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

[ background: Christopher Zimmerman has had a number of problems with the
  CONFIG_HIGHMEM stuff: there was one rather serious NFS client bug where
  it used free_page() on the virtual address of a high-mem page etc. That
  fixed it seems to be much more stable, but seems to have serious VM
  balancing issues. See my correspondence, and my theory. Comments, anyone?

  Christopher has a 2GB dual CPU machine - nice high-end box, nothing
  outrageous. Big fast disks and gigabit ethernet. ]

On Fri, 17 Mar 2000, Christopher Zimmerman wrote:
> Linus Torvalds wrote: 
> > On Fri, 17 Mar 2000, Christopher Zimmerman wrote:
> > >
> > > kswapd seems to be using %30 of the total CPU time whenever I push a box
> > > hard.  On some machines I get "VM: killing process webindexer" when I
> > > attempt to index some pages.  In some cases the machine just freezes
> > > without an oops.
> >
> > Can you check whether this still happens without CONFIG_HIGHMEM. I realize
> > that that will cause you to run with less effective memory, but I suspect
> > that the current VM balancing just gets the high page region totally
> > wrong.
> >
> >                 Linus
> 
> I take that back.  kswapd is now maxing a %30 cpu usage but averaging %15.

Ok. 15% may just be normal, considering that you're dirtying a LOT of
pages. I have a hard time judging what the load really is, but I assume
it's under fairly high load at that point and the disks are just spinning
all the time..

My personal suspicion is that it's the cumulative thing. I still don't
think that's the right thing to do, because it "penalizes" the higher
zones. So it tries to keep more free memory available in the higher zones
because it looks at the cumulative sizes of the zones up to that point to
determine how many free pages to aim for.  Which is wrong, because
especially the highmem zone is NOT a zone that we are all that interested
in keeping free pages in. If anything, we want to make sure that the
_lower_ zones have the free pages. 

Christopher, with CONFIG_HIGHMEM enabled, what happens if you apply this
patch?

		Linus

-----
--- v2.3.99-pre1/linux/mm/page_alloc.c	Tue Mar 14 19:10:40 2000
+++ linux/mm/page_alloc.c	Fri Mar 17 14:05:50 2000
@@ -277,7 +277,8 @@
 
 				if (z->low_on_memory)
 					goto balance;
-			}
+			} else
+				z->low_on_memory = 0;
 		}
 		/*
 		 * This is an optimization for the 'higher order zone
@@ -549,7 +550,7 @@
 
 		zone->offset = offset;
 		cumulative += size;
-		mask = (cumulative / zone_balance_ratio[j]);
+		mask = (size / zone_balance_ratio[j]);
 		if (mask < zone_balance_min[j])
 			mask = zone_balance_min[j];
 		else if (mask > zone_balance_max[j])

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

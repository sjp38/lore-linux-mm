Received: from baltimore.wwaves.com (knight@travelwave.dios.net [204.246.250.10] (may be forged))
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA01658
	for <linux-mm@kvack.org>; Wed, 12 May 1999 11:42:51 -0400
Date: Wed, 12 May 1999 11:42:13 -0400 (EDT)
From: Joseph Pranevich <knight@baltimore.wwaves.com>
Subject: [PATCH] Re: Swap Questions (includes possible bug) - swapfile.c /
 swap.c
In-Reply-To: <Pine.LNX.4.03.9905112321550.226-100000@mirkwood.nl.linux.org>
Message-ID: <Pine.LNX.4.03.9905121136300.30039-100000@baltimore.wwaves.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

Based on what was said below, does this make sense? In addition, I added
the case where we have >32 megs of RAM and we may want to change
page_cluster to 5 (which, if I understand your message, is the highest
that we could reasonably want it.)

We could, in theroy, do this better and have it working on the fly based
on the swap out page cluster size as a maximum, but there doesn't appear
to be a benefit at this point. If however (and I haven't checked) the
maximum is architechture-dependant, it would definately be advantagous to
generalize this further.

(I do have most of the code written to do that for my own personal
justification. But I don't yet check for an upper bound.)

Joe

--- swap.c.old	Tue May 11 17:42:02 1999
+++ swap.c	Wed May 12 09:29:49 1999
@@ -11,6 +11,7 @@
  * Started 18.12.91
  * Swap aging added 23.2.95, Stephen Tweedie.
  * Buffermem limits added 12.3.98, Rik van Riel.
+ * Additional documentation/code added 5.11.99, Joseph Pranevich
  */
 
 #include <linux/mm.h>
@@ -70,11 +71,31 @@
 
 void __init swap_setup(void)
 {
-	/* Use a smaller cluster for memory <16MB or <32MB */
+	/* The number for page_cluster can be aproximately determined
+	   using the formula:
+
+		floor ( log2(M / 4) )
+
+	   Where M is the size of memory in megabytes.
+	
+	   However, the maximum page_cluster value for swapping out
+	   is 5, so it does not make sense to have a higher value here
+	   unless that is changed. We also do not ever want to have
+	   page_cluster be less than 2.
+
+	   With those constraints in mind, we have chosen to implement
+	   this like a switch and not calculate the value in code. This
+	   should hopefully make this more readable. However, if the 
+	   maximum cluster value for swapping out is increased, it may
+	   make sense to generalize this code then.
+	*/
+
 	if (num_physpages < ((16 * 1024 * 1024) >> PAGE_SHIFT))
 		page_cluster = 2;
 	else if (num_physpages < ((32 * 1024 * 1024) >> PAGE_SHIFT))
 		page_cluster = 3;
-	else
+	else if (num_physpages < ((64 * 1024 * 1024) >> PAGE_SHIFT))
 		page_cluster = 4;
+	else 
+		page_cluster = 5;
 }



On Tue, 11 May 1999, Rik van Riel wrote:

> On Tue, 11 May 1999, Joseph Pranevich wrote:
> 
> > I've been gradually sifting my way through the kernel source and I
> > have a few minor questions about memory management.
> 
> linux-mm@kvack.org	(majordomo-managed)
> http://www.linux.eu.org/Linux-MM/
> 
> > 1) swap.c : page clustering?
> 
> > 	else
> > 		page_cluster = 4;
> > 
> > This is fine, but wouldn't it make sense to generalize this, or is
> > the benifit not as great with larger amounts of ram?
> 
> The swapOUT clustering is only done to a maximum of 32 (2^5)
> pages, so it doesn't make much sense to read in more pages
> (which are probably unrelated to the current process).
> 
> For mmap() reading we might want to switch to a smarter
> algorithm though. Not with reading in more pages, but with
> reading in the _next_ area while the program is still busy
> processing this one. The idea is to have all data in memory
> just before the process needs it :)
> 
> 
> > 2) swapfile.c : sys_swapon() question 1
> > 
> > I'm unable to figure out exactly what this code is supposed to be
> > doing. Can someone help me out here? I don't understand why we set
> > the blocksize twice or what the funniness is with "filp"
> > 
> > 		p->swap_device = swap_dentry->d_inode->i_rdev;
> > 		set_blocksize(p->swap_device, PAGE_SIZE);
> 
> We do I/O on this device in chunks of PAGE_SIZE.
> 
> > 		filp.f_dentry = swap_dentry;
> > 		filp.f_mode = 3; /* read write */
> 
> Of course, we want to have our swap device read-write and we
> mark it with a magic number so no harm will come to it...
> 
> > 		set_blocksize(p->swap_device, PAGE_SIZE);
> 
> Hmm, haven't we seen this one before? Stephen?
> 
> 
> > I do apologise for the many questions, I'm just trying to get a
> > feel for the swapping subsystem. I apologise if this is already
> > documented someplace.
> 
> AFAIK it's not yet documented. I'd really appreciate it
> if you could do that and send me the docs for inclusion
> on the Linux-MM site...
> 
> cheers,
> 
> Rik -- Open Source: you deserve to be in control of your data.
> +-------------------------------------------------------------------+
> | Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
> | Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
> | Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
> +-------------------------------------------------------------------+
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

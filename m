Date: Thu, 20 Jun 2002 05:08:37 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: [PATCH] Updated rmap VM for 2.5.23 (SMP, preempt fixes)
In-Reply-To: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu>
Message-ID: <Pine.LNX.4.44.0206200451590.4448-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Fixed patches have been uploaded that fix significant bugs in the rmap 
implementations uploaded yesterday.  Please use the NEW patches (with "-2" 
appended to the filename) instead.  ;)

In particular, neither patch was preempt-safe; thanks go to William Irwin 
for catching it.  A spinlocking bug that kept SMP-builds from booting was 
tripped across by Steven Cole; it affects the big rmap13b patch but not 
the minimal one.  That should be fixed now too.  If it breaks for you, I 
want to know about it! :)


Here's the changelog:

	2.5.23-rmap-2:  rmap on top of the 2.5.23 VM

		- Make pte_chain_lock() and pte_chain_unlock() 
		  preempt-safe  (thanks to wli for pointing this out)


	2.5.23-rmap13b-2:  Rik's full rmap patch, applied to 2.5.23

		- Make pte_chain_lock() and pte_chain_unlock()         
                  preempt-safe	(thanks to wli for pointing this out)

		- Allow an SMP-enabled kernel to boot!  Change bogus
		  spin_lock(&mapping->page_lock) invocations to either
		  read_lock() or write_lock().  This alters drop_behind()
		  in readahead.c, and reclaim_page() in vmscan.c. 

		- Keep page_launder_zone from blocking on recently written 
		  data by putting clustered writeback pages back at the 
		  beginning of the inactive dirty list.  This touches 
		  mm/page-writeback.c and fs/mpage.c.  Thanks go to Andrew 
		  Morton for clearing this issue up for me.

		- Back out Andrew's read-latency2 changes at his 
		  suggestion; it's distracting to the issue of evaluating 
		  rmap.  Thusly, we are now using the unmodified 2.5.23 
		  IO scheduler.  


FYI, these are the patches that I will benchmark in the next email.

-Craig 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

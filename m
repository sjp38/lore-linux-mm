Message-ID: <392AF5E8.3AF4B653@ucla.edu>
Date: Tue, 23 May 2000 14:19:36 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: VM performance on 64Mb in pre9-4/5
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: quintela@fi.udc.es
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi Juan,
	Thanks for all the tuning!  pre9-4 definately performs better.  It is
almost as good as pre7-4 at swapping, and probably better at other
things.  Very usable :)

	I think pre7-6 broke (compared to pre7-4) because swap_cnt==RSS, or
RSS==0.  This means that swap pages are ONLY taken from processes with
large RSS.  Pre9-4 is fixed because it decrements swap_cnt even if
pte_young(pte) is true.  More on this later.

Hard data:
	Yes, xfs-xtt, and other damons are swapped out.  They EVENTUALLY reach
an RSS of 4k, but it takes a long time (e.g. 4 hours of use) before they
reach this level, and other processes like netscape are swapped out in
the meantime.  However, netscape, X, emacs are also partially swapped
out.  I must admit though, that many of the pages swapped out of these
processes stay out. 

	Also, this kernel does a much better job at swapping ENOUGH pages out:
telomere:~> free
             total       used       free     shared    buffers    
cached
Mem:         62740      53424       9316          0        412     
25348
-/+ buffers/cache:      27664      35076
Swap:       128484      36400      92084

	OK, back to swap_cnt. I finally read the code and looked at the
swap-out algorithm.  2 things struck me (which I should have known):
	1) in pre-8, swap-out is called on PROCESSES, not PAGES.  swap_cnt is
used to guess which processes have lots of freeable pages.  However, in
pre-8, swap_cnt == RSS or swap_cnt==0.  This means that many processes
will rarely have swap_out_mm called on them.
	2) try_to_swap_out does important things besides actually swapping out,
so if it is not working we have problems even on machines that don't use
swap.  For example, with pre9-3, I had almost 60MB of used memory
running only gnome and X!  That is crazy.  But it is not surprising if
swap_out_mm is never called on small processes.

	If swap_cnt==RSS, then swap_cnt is fundamentally broken.  In that case,
we don't need this line in swap_out_pmd:
		if (!mm->swap_cnt)
			return 0;
	But in pre9-4, swap_cnt is decreased when pages are scanned, even if
but nothing is swapped out.  This means that if a large process, like
netscape, has no unused pages, other process can still have a turn in
the swap_out code, because netscape's swap_cnt will go down even if its
RSS is high.
	In fact I wonder what would happen if you tried this...

	if (pte_young(pte)) {
	   if (mm->swap_cnt)
	     mm->swap_cnt--;
	   ...
	}
	if (PageReferenced(page))
		mm->swap_cnt--;

	This will encourage the VM subsystem not to spend all its time scanning
processes that should really be in memory.  I'm not really sure that it
would be a good idea, but what is certain is that a better algorithm for
swap_cnt is desperately needed.  Right now there is (I think) no
mechanism to ensure that all process get turns in swap_out_mm.

OK, I hope this is helpful!
-BenRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

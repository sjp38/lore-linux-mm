Received: from ucla.edu (pool0011-max1.ucla-ca-us.dialup.earthlink.net [207.217.13.11])
	by caracal.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id OAA29866
	for <linux-mm@kvack.org>; Fri, 8 Sep 2000 14:27:30 -0700 (PDT)
Message-ID: <39B95B5D.F8BD7B51@ucla.edu>
Date: Fri, 08 Sep 2000 14:34:21 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Multiqueue VM Patch OK?  Does page-aging really work?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi guys - 
	I just want to remind people that dbench, bonnie, mmap2, and stuff are
only one type of way to measure the "performance" or the multiqueue
patch.  Even if these give good numbers (which they apparently don't
always), we still have major problems with the multiqueue patch, that I
think prevent it from being a candidate for 2.4.0 in its current state. 
Simply fixing the crashes is not good enough:

	Problem #1: 
	Simply untarring a large file (e.g. linux-2.4.0-test7.tar) evicts most
of the working set.  Example: I was running a few programs, including
netscape, with little swap in use.  Then I untarred a linux source tree,
and lo and behold, look at this!  44Mb swap!
telomere:~> cat free_after_untar 
             total       used       free     shared    buffers    
cached
Mem:         62872      61432       1440          0       1588     
41800
-/+ buffers/cache:      18044      44828
Swap:       128484      44044      84440

Now I have __44Mb__ of swap??  Interestingly there is about 41Mb cached.
One question I guess that needs to be asked is: is this cached data
"dirty data" in the newly created "linux/" tree , or is it "clean data"
from "linux.tar"?

Maybe the problem is that dirty data is given preference over other
data, and tyrannically takes over the cache. (But that couldn't be the
whole problem, see rest of this e-mail)

Anyway, for comparison, here is test8 after untarring a similar file
telomere:/usr/src/temp> free
             total       used       free     shared    buffers    
cached
Mem:         62944      60980       1964          0        752     
30900
-/+ buffers/cache:      29328      33616
Swap:       128484      13724     114760


	Problem #2:
	Programs that are basically unused, like (for example) an apache server
that I am running on my home computer, no longer have their RSS go down
to 4K.  Simply put, unused processes are not evicted, while data from
used processes IS evicted.

	Conclusion:
	1. Aren't BOTH these problems supposed to be solved by page aging?
Then, shouldn't the multiqueue-patched kernel do BETTER than test8? 
Apparently page-aging is not quite doing its job.  Why?
	2. With the drop_behind stuff, I'm sure the kernel will perform better,
at least with problem #1, to some extent.  However, even if the
drop_behind stuff is moved to the VMA level, I still think this is a
"special case hack".  I am not trying to be overly negative or critical
- it is just that the NEED for drop_behind this indicates that page
aging (the general solution) is not working.  Or am I missing something?

	In any case, what I am not missing is the fact that the multi-queue
patch is failing to reform the VM system in some of its most important
aspects.  I don't see how it could go into 2.4.0 in its current state.

keep up the good work!
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

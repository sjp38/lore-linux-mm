Date: Wed, 7 Jun 2000 18:07:37 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: VM callbacks and VM design
Message-ID: <20000607180737.A5943@acs.ucalgary.ca>
References: <yttem69ccax.fsf@serpe.mitica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yttem69ccax.fsf@serpe.mitica>; from quintela@fi.udc.es on Thu, Jun 08, 2000 at 01:16:06AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu, lkml <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 08, 2000 at 01:16:06AM +0200, Juan J. Quintela wrote:
> After I have been chatting with Ben LaHaise, he has suggested, instead
> of using especial code for NFS pages and block pages to change/add a
> new function to address_operations to do the swapout in
> try_to_swap_pages  and the writepage in shrink_mmap.

I believe that is exactly what David's anon patch does.  The
function is called try_to_free_page.  Personally, I think it is a
great idea.  

IMHO, the long term goal should be to futher unify the Linux VM
system.  Here is my (possibly misinformed) take on the issue:

The resource being managed the the VM system is physical pages.
When this resource becomes scarce, pressure must be placed on the
users of these pages.  Pages which well not be needed in the near
future should be the ones to be freed.

In order to decide which pages are good candidates for freeing
the temporal locality heuristic should be used (ie. pages needed
recently will also be needed in the near future).  Note that this
is different that "most often used".  I think Rik's latest aging
patch is slightly wrong in this regard.

The users who have lots of physical pages in memory will feel the
most pressure.  If they are actively using these pages the
pressure will be reduced.  LRU (or some variant to eliminate
pathological worst case behavior) should be the unified heuristic
to determine which pages should be freed.  This will provide good
performance and balance to the system.

Creating a bunch of distinct caches and trying to balance them is
the wrong solution.  

Unfortunately with the current design we do not have a relation
from physical pages to users of those pages (at least not for all
types of pages).  David's anon patch fixes this for anonymous
pages.  With this change the memory management code becomes much
simpler.  A similar approach should be taken with the SHM code.

Unfortunately these kinds of changes are too radical to make
during the so called code freeze so we will have to wait until
2.5.  I look forward to getting my hands dirty and providing some
help in this effort.

Thanks for the patch Juan.

    Neil

-- 
"Everyone can be taught to sculpt: Michelangelo would have had to
be taught how not to. So it is with the great programmers" -- Alan Perlis
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

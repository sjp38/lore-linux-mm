Date: Thu, 31 Jul 2003 11:35:49 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: do_wp_page 
In-Reply-To: <Pine.GSO.4.51.0307301514240.8932@aria.ncl.cs.columbia.edu>
Message-ID: <Pine.LNX.4.53.0307311131040.5476@skynet>
References: <Pine.GSO.4.51.0307301514240.8932@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2003, Raghu R. Arur wrote:

>   In do_wp_page of 2.4.19 why is the rss value of  address space
> incremented only when the old_page ( the page on which the process faults
> due to write protection) is a reserved page.

The page been faulted is a copy-on-write page so it's shared between more
than one process. If the process had 10 pages present before the fault,
it'll still will have 10 pages after the fault so the rss is not updated.

If the PageReserved() is true, it's the system wide ZERO_PAGE (PG_reserved
is set at boot time) and as far as I know, the system wide zero page is
the only one that can be mapped into a process with that bit set. If you
look at do_no_page(), you'll see that the zero page is not accounted for
in the RSS. If a COW takes place on the zero page, the process will be
using one more page than it was previously so rss++.

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

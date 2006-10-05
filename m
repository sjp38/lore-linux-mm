Subject: NOPAGE_RETRY and 2.6.19
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Fri, 06 Oct 2006 08:40:50 +1000
Message-Id: <1160088050.22232.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew !

Any chance that can be merged in 2.6.19 ?

The problem I have with signal and spufs is an actual bug affecting apps
and I don't see other ways of fixing it. 

In addition, we are having issues with infiniband and 64k pages (related
to the way the hypervisor deals with some HV cards) that will require us
to muck around with the MMU from within the IB driver's no_page() (it's
a pSeries specific driver) and return to the caller the same way using
NOPAGE_RETRY. 

And to add to this, the graphics folks have been following a new
approach of memory management that involves transparently swapping
objects between video ram and main meory. To do that, they need
installing PTEs from a no_page() handler as well and that also requires
returning with NOPAGE_RETRY.

(For the later, they are currently using io_remap_pfn_range to install
one PTE from no_page() which is a bit racy, we need to add a check for
the PTE having already been installed afer taking the lock, but that's
ok, they are only at the proof-of-concept stage. I'll send a patch
adding a "clean" function to do that, we can use that from spufs too and
get rid of the sparsemem hacks we do to create struct page for SPEs.
Basically, that provides a generic solution for being able to have
no_page() map hardware devices, which is something that I think sound
driver folks have been asking for some time too).

All of these things depend on having the NOPAGE_RETRY exit path from
no_page() handlers. Thus I was wondering if it was possible to have it
in 2.6.19 since just adding the interface shouldn't affect anything
badly.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

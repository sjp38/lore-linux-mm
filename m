Date: Mon, 30 Jul 2007 13:23:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
In-Reply-To: <20070727232753.GA10311@localdomain>
References: <20070727232753.GA10311@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007 16:27:53 -0700
Ravikiran G Thirumalai <kiran@scalex86.org> wrote:

> Don't go into zone_reclaim if there are no reclaimable pages.
> 
> While using RAMFS as scratch space for some tests, we found one of the
> processes got into zone reclaim, and got stuck trying to reclaim pages
> from a zone.

Would like to see an expanded definition of "stuck", please ;)

ie: let's see the bug report before we see the fix?

>  On examination of the code, we found that the VM was fooled
> into believing that the zone had reclaimable pages, when it actually had
> RAMFS backed pages, which could not be written back to the disk.
> 
> Fix this by adding a zvc "NR_PSEUDO_FS_PAGES" for file pages with no
> backing store, and using this counter to determine if reclaim is possible.
> 
> Patch tested,on 2.6.22.  Fixes the above mentioned problem.

The (cheesy) way in which reclaim currently handles this sort of thing is
to scan like mad, then to eventually set zone->all_unreclaimable.  Once
that has been set, the kernel will reduce the amount of scanning effort it
puts into that zone by a very large amount.  If the zone later comes back
to life, all_unreclaimable gets cleared and things proceed as normal.

All a bit nasty, but it has the advantage of covering _all_ these
scenarios, while a more precise fix such as the one you propose covers only
one of them.

So...  perhaps zone_reclaim() is failing to honour the all_unreclaimable
thing in some fashion?

> Comments?

It is a numa-specific change which adds overhead to non-NUMA builds :(


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

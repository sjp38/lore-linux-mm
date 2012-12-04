Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 8E72F6B0068
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 18:21:23 -0500 (EST)
Date: Tue, 4 Dec 2012 15:21:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory
 changes
Message-Id: <20121204152121.e5c33938.akpm@linux-foundation.org>
In-Reply-To: <50BD86DE.6050700@parallels.com>
References: <50B8F2F4.6000508@parallels.com>
	<20121203144310.7ccdbeb4.akpm@linux-foundation.org>
	<50BD86DE.6050700@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Matt Mackall <mpm@selenic.com>, Wu Fengguang <fengguang.wu@intel.com>

On Tue, 04 Dec 2012 09:15:10 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> 
> > Two alternatives come to mind:
> > 
> > 1)  Use /proc/pid/pagemap (Documentation/vm/pagemap.txt) in some
> >     fashion to determine which pages have been touched.
> 
> I thought about this. Unfortunately there's no free bits left in the pagemap
> entry. What can we do about it (other than introducing the pagemap2 file)?

urgh, we were pretty careless in laying out the /proc/pid/pagemap
entries.

Probably the 55 bits for pfn/swap were excessive.

The page shift didn't need six bits!  Simply predividing the page shift
by 1k would have saved a few bits, and permitting expansion to a 1^63
byte page size is nuts.

Sigh.  I wonder how traumatic it would be to put the pagemap record on
a diet and make up some free space.


Anyway, do you actually need to add another bit?  /proc/pid/pagemap
gives you the pfn which can then be used to look up the page's flags in
/proc/pageflags.  You can add a "touched" flag to /proc/kpageflags? 
But that would require grabbing another bit in struct page.flags, I
assume.

And it would be very expensive.  An in-kernel loop which searches the
MM spitting out a string of touched-pages would be faster, but still
slow.

hm.

> > 2)  At pagefault time, don't send an event: just mark the vma as
> >     "touched".  Then add a userspace interface to sweep the vma tree
> >     testing, clearing and reporting the touched flags.
> 
> Per-vma granularity is not enough. In OpenVZ we've observed Oracle touching
> several pages in a hundred-megs anon mapping. Marking _part_ of the vma with
> the "node write-faults" bit would help, but there's currently no APIs that
> modifies vma and report some info back at the same time. Can you propose how
> it could look like?

I don't see a need to report the info back at the same time?  You want
to *record* that information but only report it when someone does a
query?

Dunno.  One could add a radix-tree to the vma and store 32 or 64
per-page bits in each slots[] entry.  Worst case that would consume
approx one bit of kernel memory for each 4k of instantiated user pages
- an increase of 1/32768.  Not too bad.  Use the tagged-lookup facility
to efficiently query that bitmap at query-time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

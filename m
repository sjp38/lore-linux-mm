Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC] Avoiding fragmentation through different allocator
Date: Wed, 12 Jan 2005 14:45:44 -0800
Message-ID: <D36CE1FCEFD3524B81CA12C6FE5BCAB008C77C45@fmsmsx406.amr.corp.intel.com>
From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Mel!

>Instead of having one global MAX_ORDER-sized array of free 
>lists, there are
>three, one for each type of allocation. Finally, there is a 
>list of pages of
>size 2^MAX_ORDER which is a global pool of the largest pages 
>the kernel deals with.

I've got a patch that I've been testing recently for memory
hotplug that does nearly the exact same thing - break up the 
management of page allocations based on type - after having
had a number of conversations with Dave Hansen on this topic.  
I've also prototyped this to use as an alternative to adding
duplicate zones for delineating between memory that may be
removed and memory that is not likely to ever be removable.  I've
only tested in the context of memory hotplug, but it does
greatly simplify memory removal within individual zones.   Your
distinction between areas is pretty cool considering I've only 
distinguished at the coarser granularity of user vs. kernel 
to date.  It would be interesting to throw KernelNonReclaimable 
into the mix as well although I haven't gotten there yet...  ;-)

>Once a 2^MAX_ORDER block of pages it split for a type of 
>allocation, it is
>added to the free-lists for that type, in effect reserving it. 
>Hence, over
>time, pages of the related types can be clustered together. This means
>that if we wanted 2^MAX_ORDER number of pages, we could linearly scan a
>block of pages allocated for UserReclaimable and page each of them out.

Interesting.  I took a slightly different approach due to some
known delineations between areas that are defined to be non-
removable vs. areas that may be removed at some point.  Thus I'm
only managing two distinct free_area lists currently.  I'm curious
as to the motivation for having a global MAX_ORDER size list that
is allocation agnostic initially...is it so that the pages can
evolve according to system demands (assuming MAX_ORDER sized 
chunks are eventually available again)?

It looks like you left the per_cpu_pages as-is.  Did you
consider separating those as well to reflect kernel vs. user
pools?

>-	struct free_area	free_area[MAX_ORDER];
>+	struct free_area	free_area_lists[ALLOC_TYPES][MAX_ORDER];
>+	struct free_area	free_area_global;
>+
>+	/*
>+	 * This map tracks what each 2^MAX_ORDER sized block 
>has been used for.
>+	 * When a page is freed, it's index within this bitmap 
>is calculated
>+	 * using (address >> MAX_ORDER) * 2 . This means that pages will
>+	 * always be freed into the correct list in free_area_lists
>+	 */
>+	unsigned long		*free_area_usemap;

So, the current user/kernelreclaim/kernelnonreclaim determination
is based on this bitmap.  Couldn't this be managed in individual
struct pages instead, kind of like the buddy bitmap patches?  

I'm trying to figure out one last bug when I remove memory (via
nonlinear sections) that has been dedicated to user allocations.  
After which perhaps I'll post it as well, although it is *very*
similar.  However it does demonstrate the utility of this approach
for memory hotplug - specifically memory removal - without the 
complexity of adding more zones.  

matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

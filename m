From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] hibernation should work ok with memory hotplug
Date: Tue, 4 Nov 2008 01:29:34 +0100
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz> <200811040005.12418.rjw@sisk.pl> <1225753819.12673.518.camel@nimitz>
In-Reply-To: <1225753819.12673.518.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811040129.35335.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, pavel@suse.cz, linux-kernel@vger.kernel.org, linux-pm@lists.osdl.org, Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tuesday, 4 of November 2008, Dave Hansen wrote:
> On Tue, 2008-11-04 at 00:05 +0100, Rafael J. Wysocki wrote:
> > On Monday, 3 of November 2008, Dave Hansen wrote:
> > > But, as I think about it, there is another issue that we need to
> > > address, CONFIG_NODES_SPAN_OTHER_NODES.
> > > 
> > > A node might have a node_start_pfn=0 and a node_end_pfn=100 (and it may
> > > have only one zone).  But, there may be another node with
> > > node_start_pfn=10 and a node_end_pfn=20.  This loop:
> > > 
> > >         for_each_zone(zone) {
> > > 		...
> > >                 for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
> > >                         if (page_is_saveable(zone, pfn))
> > >                                 memory_bm_set_bit(orig_bm, pfn);
> > >         }
> > > 
> > > will walk over the smaller node's pfn range multiple times.  Is this OK?
> > 
> > Hm, well, I'm not really sure at the moment.
> > 
> > Does it mean that, in your example, the pfns 10 to 20 from the first node
> > refer to the same page frames that are referred to by the pfns from the
> > second node?
> 
> Maybe using pfns didn't make for a good example.  I could have used
> physical addresses as well.
> 
> All that I'm saying is that nodes (and zones) can span other nodes (and
> zones).  This means that the address ranges making up that node can
> overlap with the address ranges of another node.  This doesn't mean that
> *each* node has those address ranges.  Each individual address can only
> be in one node.
> 
> Since zone *ranges* overlap, you can't tell to which zone a page belongs
> simply from its address.  You need to ask the 'struct page'.

Understood.

This means that some zones may contain some ranges of pfns that correspond
to struct pages in another zone, correct?

> > > I think all you have to do to fix it is check page_zone(page) == zone
> > > and skip out if they don't match.
> > 
> > Well, probably.  I need to know exactly what's the relationship between pfns,
> > pages and physical page frames in that case.
> 
> 1 pfn == 1 'struct page' == 1 physical page
> 
> The only exception to that is that we may have more 'struct pages' than
> we have actual physical memory due to rounding and so forth.

OK, I think that the appended patch will do the trick (compiled, untested).

Thanks,
Rafael


Not-yet-signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 kernel/power/snapshot.c |   23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c
+++ linux-2.6/kernel/power/snapshot.c
@@ -817,8 +817,7 @@ static unsigned int count_free_highmem_p
  *	We should save the page if it isn't Nosave or NosaveFree, or Reserved,
  *	and it isn't a part of a free chunk of pages.
  */
-
-static struct page *saveable_highmem_page(unsigned long pfn)
+static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
 {
 	struct page *page;
 
@@ -826,6 +825,8 @@ static struct page *saveable_highmem_pag
 		return NULL;
 
 	page = pfn_to_page(pfn);
+	if (page_zone(page) != zone)
+		return NULL;
 
 	BUG_ON(!PageHighMem(page));
 
@@ -855,13 +856,16 @@ unsigned int count_highmem_pages(void)
 		mark_free_pages(zone);
 		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
-			if (saveable_highmem_page(pfn))
+			if (saveable_highmem_page(zone, pfn))
 				n++;
 	}
 	return n;
 }
 #else
-static inline void *saveable_highmem_page(unsigned long pfn) { return NULL; }
+static inline void *saveable_highmem_page(struct zone *z, unsigned long p)
+{
+	return NULL;
+}
 #endif /* CONFIG_HIGHMEM */
 
 /**
@@ -872,8 +876,7 @@ static inline void *saveable_highmem_pag
  *	of pages statically defined as 'unsaveable', and it isn't a part of
  *	a free chunk of pages.
  */
-
-static struct page *saveable_page(unsigned long pfn)
+static struct page *saveable_page(struct zone *zone, unsigned long pfn)
 {
 	struct page *page;
 
@@ -881,6 +884,8 @@ static struct page *saveable_page(unsign
 		return NULL;
 
 	page = pfn_to_page(pfn);
+	if (page_zone(page) != zone)
+		return NULL;
 
 	BUG_ON(PageHighMem(page));
 
@@ -912,7 +917,7 @@ unsigned int count_data_pages(void)
 		mark_free_pages(zone);
 		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
-			if(saveable_page(pfn))
+			if(saveable_page(zone, pfn))
 				n++;
 	}
 	return n;
@@ -953,7 +958,7 @@ static inline struct page *
 page_is_saveable(struct zone *zone, unsigned long pfn)
 {
 	return is_highmem(zone) ?
-			saveable_highmem_page(pfn) : saveable_page(pfn);
+		saveable_highmem_page(zone, pfn) : saveable_page(zone, pfn);
 }
 
 static void copy_data_page(unsigned long dst_pfn, unsigned long src_pfn)
@@ -984,7 +989,7 @@ static void copy_data_page(unsigned long
 	}
 }
 #else
-#define page_is_saveable(zone, pfn)	saveable_page(pfn)
+#define page_is_saveable(zone, pfn)	saveable_page(zone, pfn)
 
 static inline void copy_data_page(unsigned long dst_pfn, unsigned long src_pfn)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

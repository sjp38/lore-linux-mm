Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DEEE96B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 21:45:04 -0400 (EDT)
Date: Wed, 1 Jul 2009 09:46:27 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: + memory-hotplug-update-zone-pcp-at-memory-online.patch added
	to -mm tree
Message-ID: <20090701014627.GA23264@sli10-desk.sh.intel.com>
References: <200906291949.n5TJno8X028680@imap1.linux-foundation.org> <alpine.DEB.1.10.0906291814150.21956@gentwo.org> <20090630005828.GC21254@sli10-desk.sh.intel.com> <alpine.DEB.1.10.0906301020420.6124@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906301020420.6124@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Zhao, Yakui" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 10:21:34PM +0800, Christoph Lameter wrote:
> On Tue, 30 Jun 2009, Shaohua Li wrote:
> 
> > > foreach possible cpu?
> > Just follows zone_pcp_init(), do you think we should change that too?
> 
> I plan to change that but for now this would be okay.
> 
> > > > +		struct per_cpu_pageset *pset;
> > > > +		struct per_cpu_pages *pcp;
> > > > +
> > > > +		pset = zone_pcp(zone, cpu);
> > > > +		pcp = &pset->pcp;
> > > > +
> > > > +		local_irq_save(flags);
> > > > +		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> > >
> > > There are no pages in the pageset since the pcp batch is zero right?
> > It might not be zero for a populated zone, see above comments.
> 
> But you are populating an unpopulated zone?
yes, but free_pages_bulk() works with zero pcp->count too. And the zone
might/might not populate before hotplug, so free the pages is always ok
here to me.


In my test, 128M memory is hot add, but zone's pcp batch is 0, which
is an obvious error. When pages are onlined, zone pcp should be
updated accordingly.

Include fixes suggested by Christoph Lameter and Andrew Morton.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/linux/mm.h  |    2 ++
 mm/memory_hotplug.c |    1 +
 mm/page_alloc.c     |   26 ++++++++++++++++++++++++++
 3 files changed, 29 insertions(+)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2009-06-30 09:14:21.000000000 +0800
+++ linux/include/linux/mm.h	2009-07-01 09:13:22.000000000 +0800
@@ -1073,6 +1073,8 @@ extern void setup_per_cpu_pageset(void);
 static inline void setup_per_cpu_pageset(void) {}
 #endif
 
+extern void zone_pcp_update(struct zone *zone);
+
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
 
Index: linux/mm/memory_hotplug.c
===================================================================
--- linux.orig/mm/memory_hotplug.c	2009-06-30 09:14:21.000000000 +0800
+++ linux/mm/memory_hotplug.c	2009-07-01 09:13:22.000000000 +0800
@@ -422,6 +422,7 @@ int online_pages(unsigned long pfn, unsi
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 
+	zone_pcp_update(zone);
 	setup_per_zone_wmarks();
 	calculate_zone_inactive_ratio(zone);
 	if (onlined_pages) {
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-06-30 09:14:21.000000000 +0800
+++ linux/mm/page_alloc.c	2009-07-01 09:40:08.000000000 +0800
@@ -3131,6 +3131,32 @@ int zone_wait_table_init(struct zone *zo
 	return 0;
 }
 
+static int __zone_pcp_update(void *data)
+{
+	struct zone *zone = data;
+	int cpu;
+	unsigned long batch = zone_batchsize(zone), flags;
+
+	for_each_possible_cpu(cpu) {
+		struct per_cpu_pageset *pset;
+		struct per_cpu_pages *pcp;
+
+		pset = zone_pcp(zone, cpu);
+		pcp = &pset->pcp;
+
+		local_irq_save(flags);
+		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
+		setup_pageset(pset, batch);
+		local_irq_restore(flags);
+	}
+	return 0;
+}
+
+void zone_pcp_update(struct zone *zone)
+{
+	stop_machine(__zone_pcp_update, zone, NULL);
+}
+
 static __meminit void zone_pcp_init(struct zone *zone)
 {
 	int cpu;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 691456B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 03:48:13 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so1374789rvb.26
        for <linux-mm@kvack.org>; Wed, 08 Jul 2009 00:55:06 -0700 (PDT)
Date: Wed, 8 Jul 2009 15:55:01 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: OOM killer in 2.6.31-rc2
Message-ID: <20090708075501.GA1122@localhost>
References: <200907061056.00229.gene.heskett@verizon.net> <200907071057.31152.gene.heskett@verizon.net> <20090708021708.GA10481@localhost> <200907072342.07822.gene.heskett@verizon.net> <20090708051515.GA17156@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708051515.GA17156@localhost>
Sender: owner-linux-mm@kvack.org
To: Gene Heskett <gene.heskett@verizon.net>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 01:15:15PM +0800, Wu Fengguang wrote:
> On Tue, Jul 07, 2009 at 11:42:07PM -0400, Gene Heskett wrote:
> > On Tuesday 07 July 2009, Wu Fengguang wrote:
> > >On Tue, Jul 07, 2009 at 10:57:30PM +0800, Gene Heskett wrote:
> > >> On Tuesday 07 July 2009, Wu Fengguang wrote:
> > >> >On Mon, Jul 06, 2009 at 10:56:00AM -0400, Gene Heskett wrote:
> > >> >> Greetings all;
> > [...]
> > >> >
> > >> >Normal zone is absent in the above lines.
> > >>
> > >> Is this a .config issue?
> > >
> > >At least CONFIG_HIGHMEM64G is not necessary, could try disabling it.
> > 
> > I have in a rebuild of this 2.6.30.1 kernel, but ISTR I enabled that because 
> > it was only using 3G of the 4G of ram in this box, an AMD-64 Phenom, 4 cores, 
> > 4G ram.  But I haven't rebooted to it yet.  Next good excuse.  See below... :)
> 
> I guess you can only use 3G ram because there is a big memory hole.
> Your HighMem zone spanned 951810 pages, 813013 of which is present.
> So it's not quite accurate for the OOM message "951810 pages HighMem"
> to report the spanned pages.
> 
> Your Normal zone has 221994 present pages, while the OOM message shows
> "slab:206505", which indicates that the OOM is caused by too much
> slab pages(they cannot be allocated from HighMem zone).
> 
> I guess your near 800MB slab cache is somehow under scanned.

Gene, can you run .31 with this patch? When OOM happens, it will tell
us whether the majority slab pages are reclaimable. Another way to 
find things out is to run `slabtop` when your system is moderately loaded.

Thanks,
Fengguang
---
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Subject: [PATCH] add per-zone statistics to show_free_areas()

Currently, show_free_area() mainly display system memory usage. but it
doesn't display per-zone memory usage information.

However, if DMA zone OOM occur, Administrator definitely need to know
per-zone memory usage information.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2151,6 +2151,16 @@ void show_free_areas(void)
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
 			" present:%lukB"
+			" mlocked:%lukB"
+			" dirty:%lukB"
+			" writeback:%lukB"
+			" mapped:%lukB"
+			" slab_reclaimable:%lukB"
+			" slab_unreclaimable:%lukB"
+			" pagetables:%lukB"
+			" unstable:%lukB"
+			" bounce:%lukB"
+			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
 			"\n",
@@ -2165,6 +2175,16 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
 			K(zone_page_state(zone, NR_UNEVICTABLE)),
 			K(zone->present_pages),
+			K(zone_page_state(zone, NR_MLOCK)),
+			K(zone_page_state(zone, NR_FILE_DIRTY)),
+			K(zone_page_state(zone, NR_WRITEBACK)),
+			K(zone_page_state(zone, NR_FILE_MAPPED)),
+			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
+			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
+			K(zone_page_state(zone, NR_PAGETABLE)),
+			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
+			K(zone_page_state(zone, NR_BOUNCE)),
+			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
 			);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

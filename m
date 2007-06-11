Date: Mon, 11 Jun 2007 14:09:55 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: mm: memory/cpu hotplug section mismatch.
Message-ID: <20070611050955.GA23215@linux-sh.org>
References: <20070611043543.GA22910@linux-sh.org> <20070611140145.05726c0f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070611140145.05726c0f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 11, 2007 at 02:01:45PM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 11 Jun 2007 13:35:43 +0900
> Paul Mundt <lethal@linux-sh.org> wrote:
> 
> > When building with memory hotplug enabled and cpu hotplug disabled, we
> > end up with the following section mismatch:
> > 
> > WARNING: mm/built-in.o(.text+0x4e58): Section mismatch: reference to
> > .init.text: (between 'free_area_init_node' and '__build_all_zonelists')
> > 
> > This happens as a result of:
> > 
> > 	-> free_area_init_node()
> > 	  -> free_area_init_core()
> > 	    -> zone_pcp_init() <-- all __meminit up to this point
> > 	      -> zone_batchsize() <-- marked as __cpuinit
> > 
> > This happens because CONFIG_HOTPLUG_CPU=n sets __cpuinit to __init, but
> > CONFIG_MEMORY_HOTPLUG=y unsets __meminit.
> > 
> > Changing zone_batchsize() to __init_refok fixes this.
> > 
> 
> It seems this zone_batchsize() is called by cpu-hotplug and memory-hotplug.
> So, __init_refok doesn't look good, here.
> 
> maybe we can use __devinit here. (Because HOTPLUG_CPU and MEMORY_HOTPLUG are
> depend on CONFIG_HOTPLUG.)
> 
Yes, that's probably a more reasonable way to go. The __devinit name is a
bit misleading, though..

--

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bd8e335..05ace44 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1968,7 +1968,7 @@ void zone_init_free_lists(struct pglist_data *pgdat, struct zone *zone,
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
-static int __cpuinit zone_batchsize(struct zone *zone)
+static int __devinit zone_batchsize(struct zone *zone)
 {
 	int batch;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

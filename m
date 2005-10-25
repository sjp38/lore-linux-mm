Received: by zproxy.gmail.com with SMTP id k1so137168nzf
        for <linux-mm@kvack.org>; Tue, 25 Oct 2005 04:37:52 -0700 (PDT)
Message-ID: <aec7e5c30510250437h6c300066s14e39a0c91be772c@mail.gmail.com>
Date: Tue, 25 Oct 2005 20:37:52 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
In-Reply-To: <20051024074418.GC2016@logos.cnet>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_26501_31547462.1130240272839"
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
	 <aec7e5c30510201857r7cf9d337wce9a4017064adcf@mail.gmail.com>
	 <20051022005050.GA27317@logos.cnet>
	 <aec7e5c30510230550j66d6e37fg505fd6041dca9bee@mail.gmail.com>
	 <20051024074418.GC2016@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

------=_Part_26501_31547462.1130240272839
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 10/24/05, Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> On Sun, Oct 23, 2005 at 09:50:18PM +0900, Magnus Damm wrote:
> > Maybe SLAB defragmentation code is suitable for page migration too?
>
> Free dentries are possible to migrate, but not referenced ones.
>
> How are you going to inform users that the address of a dentry has
> changed?

Um, not sure, but the idea of defragmenting SLAB entries might be
similar to moving them, ie migration. But how to solve the per-SLAB
referencing is another story... =3D)

> > > > But I'm probably underestimating the cost of page migration...
> > >
> > > The zone balancing issue you describe might be an issue once zone
> > > said pages can be migrated :)
> >
> > My main concern is that we use one LRU per zone, and I suspect that
> > this design might be suboptimal if the sizes of the zones differs
> > much. But I have no numbers.
>
> Migrating user pages from lowmem to highmem under situations with
> intense low memory pressure (due to certain important allocations
> which are restricted to lowmem) might be very useful.

I patched the kernel on my desktop machine to provide some numbers.
The zoneinfo file and a small patch is attached.

$ uname -r
2.6.14-rc5-git3

$ uptime
 20:27:47 up 1 day,  6:27, 18 users,  load average: 0.01, 0.13, 0.15

$ cat /proc/zoneinfo | grep present
        present  4096
        present  225280
        present  30342

$ cat /proc/zoneinfo | grep tscanned
        tscanned 151352
        tscanned 3480599
        tscanned 541466

"tscanned" counts how many pages that has been scanned in each zone
since power on. Executive summary assuming that only LRU pages exist
in the zone:

DMA: each page has been scanned ~37 times
Normal: each page has been scanned ~15 times
HighMem: each page has been scanned ~18 times

So if your user space page happens to be allocated from the DMA zone,
it looks like it is more probable that it will be paged out sooner
than if it was allocated from another zone. And this is on a half year
old P4 system.

> > There are probably not that many drivers using the DMA zone on a
> > modern PC, so instead of bringing performance penalty on the entire
> > system I think it would be nicer to punish the evil hardware instead.
>
> Agreed - the 16MB DMA zone is silly. Would love to see it go away...

But is the DMA zone itself evil, or just that we have one LRU per zone...?

/ magnus

------=_Part_26501_31547462.1130240272839
Content-Type: application/octet-stream; name=zoneinfo
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="zoneinfo"

Node 0, zone      DMA
  pages free     1370
        min      17
        low      21
        high     25
        active   1715
        inactive 34
        scanned  0 (a: 24 i: 4)
        tscanned 151352
        spanned  4096
        present  4096
        protection: (0, 880, 998)
  pagesets
    cpu: 0 pcp: 0
              count: 5
              low:   2
              high:  6
              batch: 1
    cpu: 0 pcp: 1
              count: 1
              low:   0
              high:  2
              batch: 1
  all_unreclaimable: 0
  prev_priority:     12
  temp_priority:     12
  start_pfn:         0
Node 0, zone   Normal
  pages free     11121
        min      939
        low      1173
        high     1408
        active   151351
        inactive 38572
        scanned  0 (a: 0 i: 0)
        tscanned 3480599
        spanned  225280
        present  225280
        protection: (0, 0, 948)
  pagesets
    cpu: 0 pcp: 0
              count: 121
              low:   62
              high:  186
              batch: 31
    cpu: 0 pcp: 1
              count: 1
              low:   0
              high:  62
              batch: 31
  all_unreclaimable: 0
  prev_priority:     12
  temp_priority:     12
  start_pfn:         4096
Node 0, zone  HighMem
  pages free     30
        min      32
        low      40
        high     48
        active   29059
        inactive 537
        scanned  0 (a: 0 i: 0)
        tscanned 541466
        spanned  30342
        present  30342
        protection: (0, 0, 0)
  pagesets
    cpu: 0 pcp: 0
              count: 57
              low:   30
              high:  90
              batch: 15
    cpu: 0 pcp: 1
              count: 14
              low:   0
              high:  30
              batch: 15
  all_unreclaimable: 0
  prev_priority:     12
  temp_priority:     12
  start_pfn:         229376

------=_Part_26501_31547462.1130240272839
Content-Type: text/x-patch; name=lru_total_scanned.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="lru_total_scanned.patch"

--- from-0002/include/linux/mmzone.h
+++ to-work/include/linux/mmzone.h	2005-10-24 10:43:13.000000000 +0900
@@ -151,6 +151,7 @@ struct zone {
 	unsigned long		nr_active;
 	unsigned long		nr_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
+	unsigned long		pages_scanned_total;
 	int			all_unreclaimable; /* All pages pinned */
 
 	/*
--- from-0002/mm/page_alloc.c
+++ to-work/mm/page_alloc.c	2005-10-24 10:51:05.000000000 +0900
@@ -2101,6 +2101,7 @@ static int zoneinfo_show(struct seq_file
 			   "\n        active   %lu"
 			   "\n        inactive %lu"
 			   "\n        scanned  %lu (a: %lu i: %lu)"
+			   "\n        tscanned %lu"
 			   "\n        spanned  %lu"
 			   "\n        present  %lu",
 			   zone->free_pages,
@@ -2111,6 +2112,7 @@ static int zoneinfo_show(struct seq_file
 			   zone->nr_inactive,
 			   zone->pages_scanned,
 			   zone->nr_scan_active, zone->nr_scan_inactive,
+			   zone->pages_scanned_total,
 			   zone->spanned_pages,
 			   zone->present_pages);
 		seq_printf(m,
--- from-0002/mm/vmscan.c
+++ to-work/mm/vmscan.c	2005-10-24 10:44:09.000000000 +0900
@@ -633,6 +633,7 @@ static void shrink_cache(struct zone *zo
 					     &page_list, &nr_scan);
 		zone->nr_inactive -= nr_taken;
 		zone->pages_scanned += nr_scan;
+		zone->pages_scanned_total += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
 		if (nr_taken == 0)
@@ -713,6 +714,7 @@ refill_inactive_zone(struct zone *zone, 
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
 				    &l_hold, &pgscanned);
 	zone->pages_scanned += pgscanned;
+	zone->pages_scanned_total += pgscanned;
 	zone->nr_active -= pgmoved;
 	spin_unlock_irq(&zone->lru_lock);
 

------=_Part_26501_31547462.1130240272839--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

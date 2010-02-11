Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDB66B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 18:02:09 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o1BN26KT002114
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:02:06 -0800
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by kpbe15.cbf.corp.google.com with ESMTP id o1BN1tLb010857
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:02:05 -0800
Received: by pwi10 with SMTP id 10so94801pwi.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:02:04 -0800 (PST)
Date: Thu, 11 Feb 2010 15:02:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm: suppress pfn range output for zones without pages
In-Reply-To: <alpine.DEB.2.00.1002111626440.7201@router.home>
Message-ID: <alpine.DEB.2.00.1002111459160.27917@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com> <alpine.DEB.2.00.1002111406110.7201@router.home> <alpine.DEB.2.00.1002111405120.16763@chino.kir.corp.google.com> <alpine.DEB.2.00.1002111626440.7201@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Christoph Lameter wrote:

> > So you want to parse this table of zone pfn ranges to determine, for
> > example, whether CONFIG_HIGHMEM was enabled for i386 kernels?  That
> > doesn't tell you whether its CONFIG_HIGHMEM4G or CONFIG_HIGHMEM64G, so
> > it's a pretty bad way to interpret the kernel config and decide whether
> 
> It tells me that there is highmem zone.
> 

Not as far as the user is concerned, it's empty.  Your point was to 
determine what support was compiled into the kernel and the presence of a 
highmem pfn range does not point to either CONFIG_HIGHMEM4G or 
CONFIG_HIGHMEM64G.

> > the pfn ranges are valid or not.  The only other use case would be to find
> > if the values are sane when we don't have CONFIG_ZONE_DMA or
> > CONFIG_ZONE_DMA32, but those typically aren't even disabled: I just sent a
> > patch to the x86 maintainers to get that configuration to compile on -rc7.
> 
> CONFIG_ZONE_DMA32 is disabled on 32 bit
> CONFIG_ZONE_DMA may be disabled on IA64 or other platforms that do have
> priviledged areas of memory.
> 
> Strange embedded kernel configs may sometimes play tricks with ZONE_DMA.
> 

If it requires spamming the kernel log for an invalid zone pfn range to 
indicate a zone was compiled into the kernel, then fine.



mm: suppress pfn range output for zones without pages

free_area_init_nodes() emits pfn ranges for all zones on the system.
There may be no pages on a higher zone, however, due to memory
limitations or the use of the mem= kernel parameter.  For example:

Zone PFN ranges:
  DMA      0x00000001 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000

The implementation copies the previous zone's highest pfn, if any, as the
next zone's lowest pfn.  If its highest pfn is then greater than the
amount of addressable memory, the upper memory limit is used instead.
Thus, both the lowest and highest possible pfn for higher zones without
memory may be the same.

The pfn range for zones without memory is now shown as "empty" instead.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4377,8 +4377,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		if (i == ZONE_MOVABLE)
 			continue;
-		printk("  %-8s %0#10lx -> %0#10lx\n",
-				zone_names[i],
+		printk("  %-8s ", zone_names[i]);
+		if (arch_zone_lowest_possible_pfn[i] ==
+				arch_zone_highest_possible_pfn[i])
+			printk("empty\n");
+		else
+			printk("%0#10lx -> %0#10lx\n",
 				arch_zone_lowest_possible_pfn[i],
 				arch_zone_highest_possible_pfn[i]);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

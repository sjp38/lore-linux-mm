Date: Tue, 22 Jan 2008 12:29:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080122122954.GC10987@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <p73hcha9vc5.fsf@bingen.suse.de> <20080119160743.GA8352@csn.ul.ie> <20080122121400.GB31253@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080122121400.GB31253@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (22/01/08 13:14), Ingo Molnar didst pronounce:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > [...] I tested this situation on a 4-node NUMA Opteron box. It didn't 
> > work very well based on a few problems.
> > 
> > - alloc_remap() and SPARSEMEM on HIGHMEM4G explodes [1]
> > - Without SRAT, there is a build failure 
> > - Enabling SRAT requires BOOT_IOREMAP and it explodes early in boot
> > 
> > I have one fix for items 1 and 2 with the patch below. It probably 
> > should be split in two but lets see if we want to pursue alternative 
> > fixes to this problem first. In particular, this patch stops SPARSEMEM 
> > using alloc_remap() because not enough memory is set aside. An 
> > alternative solution may be to reserve more for alloc_remap() when 
> > SPARSEMEM is in use.
> > 
> > With the patch applied, an x86-64 capable NUMA Opteron box will boot a 
> > 32 bit NUMA enabled kernel with DISCONTIGMEM or SPARSEMEM. Due to the 
> > lack of SRAT parsing, there is only node 0 of course.
> > 
> > Based on this, I have no doubt there is going to be a series of broken 
> > boots while stuff like this gets rattled out. For the moment, NUMA on 
> > x86 32-bit should remain CONFIG_EXPERIMENTAL.
> 
> thanks, applied.
> 

Sorry, there was a screwup on my behalf. The version I sent still had a
stray static inline in it.  It will fail to compile without this.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-015_remap_discontigmem/arch/x86/mm/discontig_32.c linux-2.6.24-rc8-015_remap_discontigmem-fix/arch/x86/mm/discontig_32.c
--- linux-2.6.24-rc8-015_remap_discontigmem/arch/x86/mm/discontig_32.c	2008-01-22 12:27:52.000000000 +0000
+++ linux-2.6.24-rc8-015_remap_discontigmem-fix/arch/x86/mm/discontig_32.c	2008-01-22 12:28:39.000000000 +0000
@@ -485,7 +485,7 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to
  * not set. There are functions in srat_64.c for parsing this table
  * and it may be possible to make them common functions.
  */
-static inline void acpi_numa_slit_init (struct acpi_table_slit *slit)
+void acpi_numa_slit_init (struct acpi_table_slit *slit)
 {
 	printk(KERN_INFO "ACPI: No support for parsing SLIT table\n");
 }

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

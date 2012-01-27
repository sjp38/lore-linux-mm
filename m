Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B45406B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 16:43:10 -0500 (EST)
Message-ID: <4F231A6B.1050607@oracle.com>
Date: Fri, 27 Jan 2012 13:43:07 -0800
From: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
MIME-Version: 1.0
Subject: [BUG] 3.2.2 crash in isolate_migratepages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>


3.2.2 panics on a 16GB i686 blade:

BUG: unable to handle kernel paging request at 01c00008
IP: [<c0522399>] isolate_migratepages+0x119/0x390
*pdpt = 000000002f7ce001 *pde = 0000000000000000

The crash happens on this line in mm/compaction.c::isolate_migratepages:

    328                 page = pfn_to_page(low_pfn);

This macro finds the struct page pointer for a given pfn.  These struct
page pointers are stored in sections of 131072 pages if
CONFIG_SPARSEMEM=y.  If an entire section has no memory pages, the page
structs are not allocated for this section.  On this particular machine,
there is no RAM mapped from 2GB - 4GB:

# dmesg|grep usable
 BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
 BIOS-e820: 0000000000100000 - 000000007fe4e000 (usable)
 BIOS-e820: 000000007fe56000 - 000000007fe57000 (usable)
 BIOS-e820: 0000000100000000 - 000000047ffff000 (usable)

So there are no page structs for the sections between 2GB and 4GB.

I believe this check was intended to catch page numbers that point to holes:

    323                 if (!pfn_valid_within(low_pfn))
    324                         continue;

But pfn_valid_within is defined to (1) on all archs except ARM and ia64
as far as I can tell.  So this check always passes (it's in fact
optimized out), and pfn_to_page ends up dereferencing an invalid address
due to a null pointer in the mem_section structure.

Other compaction code checks for pfn_valid(pfn), which actually checks
for the null pointer in the mem_section structure.  It is not clear to
me why isolate_migratepages uses pfn_valid_within().  Changing it to
pfn_valid() prevents the crash.  It looks like the correct solution to
me, but I'm not familiar with this code.

I also tried this on a 64-bit machine with a 1GB gap at 3GB, but the
address calculated from (struct page *)0 + pfn is a valid readable
memory location, so it doesn't panic.  Not sure what other bad things
happen later though.

Any comments, questions, other data you'd like to see?

Thanks,
Herbert.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/7] Sparsemem Virtual Memmap V5
Message-ID: <exportbomb.1184333503@pinky>
Date: Fri, 13 Jul 2007 14:34:37 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Following this email is the current state of the Sparsemem Virtual
Memory Map support (description below).  This version is essentially
unchanged from V4.  The ia64 crowd has decided they want a 4MB
mapping size for the map which will come later, so this set includes
only base page support for them.  This patch set has been tested
pretty heavily over the last few weeks.

The current aim is to bring a common virtually mapped mem_map
to all architectures.  This should facilitate the removal of the
bespoke implementations from the architectures.  This also brings
performance improvements for most architecture making sparsmem
vmemmap the more desirable memory model.  The ultimate aim of this
work is to expand sparsemem support to encompass all the features
of the other memory models.  This could allow us to drop support
for and remove the other models in the longer term.

Below are some comparitive kernbench numbers for various
architectures, comparing default memory model against SPARSEMEM
VMEMMAP.  All but ia64 show marginal improvement; we expect the ia64
figures to be sorted out when the larger mapping support returns.

x86-64 non-NUMA
             Base    VMEMAP    % change (-ve good)
User        85.07     84.84    -0.26
System      34.32     33.84    -1.39
Total      119.38    118.68    -0.59

ia64
             Base    VMEMAP    % change (-ve good)
User      1016.41   1016.93    0.05
System      50.83     51.02    0.36
Total     1067.25   1067.95    0.07

x86-64 NUMA
             Base   VMEMAP    % change (-ve good)
User        30.77   431.73     0.22
System      45.39    43.98    -3.11
Total      476.17   475.71    -0.10

ppc64
             Base   VMEMAP    % change (-ve good)
User       488.77   488.35    -0.09
System      56.92    56.37    -0.97
Total      545.69   544.72    -0.18

Below are some AIM bencharks on IA64 and x86-64 (thank Bob).  The seems
pretty much flat as you would expect.


ia64 results 2 cpu non-numa 4Gb SCSI disk

Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	extreme	Jun  1 07:17:24 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	98.9		100	58.9	1.3	1.6482
101	5547.1		95	106.0	79.4	0.9154
201	6377.7		95	183.4	158.3	0.5288
301	6932.2		95	252.7	237.3	0.3838
401	7075.8		93	329.8	316.7	0.2941
501	7235.6		94	403.0	396.2	0.2407
600	7387.5		94	472.7	475.0	0.2052

Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	vmemmap	Jun  1 09:59:04 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	99.1		100	58.8	1.2	1.6509
101	5480.9		95	107.2	79.2	0.9044
201	6490.3		95	180.2	157.8	0.5382
301	6886.6		94	254.4	236.8	0.3813
401	7078.2		94	329.7	316.0	0.2942
501	7250.3		95	402.2	395.4	0.2412
600	7399.1		94	471.9	473.9	0.2055


open power 710 2 cpu, 4 Gb, SCSI and configured physically

Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	extreme	May 29 15:42:53 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	25.7		100	226.3	4.3	0.4286
101	1096.0		97	536.4	199.8	0.1809
201	1236.4		96	946.1	389.1	0.1025
301	1280.5		96	1368.0	582.3	0.0709
401	1270.2		95	1837.4	771.0	0.0528
501	1251.4		96	2330.1	955.9	0.0416
601	1252.6		96	2792.4	1139.2	0.0347
701	1245.2		96	3276.5	1334.6	0.0296
918	1229.5		96	4345.4	1728.7	0.0223

Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	vmemmap	May 30 07:28:26 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	25.6		100	226.9	4.3	0.4275
101	1049.3		97	560.2	198.1	0.1731
201	1199.1		97	975.6	390.7	0.0994
301	1261.7		96	1388.5	591.5	0.0699
401	1256.1		96	1858.1	771.9	0.0522
501	1220.1		96	2389.7	955.3	0.0406
601	1224.6		96	2856.3	1133.4	0.0340
701	1252.0		96	3258.7	1314.1	0.0298
915	1232.8		96	4319.7	1704.0	0.0225


amd64 2 2-core, 4Gb and SATA

Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	extreme	Jun  2 03:59:48 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	13.0		100	446.4	2.1	0.2173
101	533.4		97	1102.0	110.2	0.0880
201	578.3		97	2022.8	220.8	0.0480
301	583.8		97	3000.6	332.3	0.0323
401	580.5		97	4020.1	442.2	0.0241
501	574.8		98	5072.8	558.8	0.0191
600	566.5		98	6163.8	671.0	0.0157

Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	vmemmap	Jun  3 04:19:31 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	13.0		100	447.8	2.0	0.2166
101	536.5		97	1095.6	109.7	0.0885
201	567.7		97	2060.5	219.3	0.0471
301	582.1		96	3009.4	330.2	0.0322
401	578.2		96	4036.4	442.4	0.0240
501	585.1		98	4983.2	555.1	0.0195
600	565.5		98	6175.2	660.6	0.0157

This stack is against v2.6.22-rc6-mm1.  It has been compile, boot
and tested on x86_64, ia64 and PPC64.

Andrew, please consider for -mm.

Note that I am away from my keyboard all of next week, but I figured
it better to get this out for testing.

-apw

===
SPARSEMEM is a pretty nice framework that unifies quite a bit of
code over all the arches. It would be great if it could be the
default so that we can get rid of various forms of DISCONTIG and
other variations on memory maps. So far what has hindered this are
the additional lookups that SPARSEMEM introduces for virt_to_page
and page_address. This goes so far that the code to do this has to
be kept in a separate function and cannot be used inline.

This patch introduces a virtual memmap mode for SPARSEMEM, in which
the memmap is mapped into a virtually contigious area, only the
active sections are physically backed.  This allows virt_to_page
page_address and cohorts become simple shift/add operations.
No page flag fields, no table lookups, nothing involving memory
is required.

The two key operations pfn_to_page and page_to_page become:

   #define __pfn_to_page(pfn)      (vmemmap + (pfn))
   #define __page_to_pfn(page)     ((page) - vmemmap)

By having a virtual mapping for the memmap we allow simple access
without wasting physical memory.  As kernel memory is typically
already mapped 1:1 this introduces no additional overhead.
The virtual mapping must be big enough to allow a struct page to
be allocated and mapped for all valid physical pages.  This vill
make a virtual memmap difficult to use on 32 bit platforms that
support 36 address bits.

However, if there is enough virtual space available and the arch
already maps its 1-1 kernel space using TLBs (f.e. true of IA64
and x86_64) then this technique makes SPARSEMEM lookups even more
efficient than CONFIG_FLATMEM.  FLATMEM needs to read the contents
of the mem_map variable to get the start of the memmap and then add
the offset to the required entry.  vmemmap is a constant to which
we can simply add the offset.

This patch has the potential to allow us to make SPARSMEM the default
(and even the only) option for most systems.  It should be optimal
on UP, SMP and NUMA on most platforms.  Then we may even be able
to remove the other memory models: FLATMEM, DISCONTIG etc.

V4->V5
 - IA64 16MB support shelved
 - rebase to current -mm

V3->V4
 - SPARC64 support -- from Dave Miller
 - PPC64 support -- from Andy Whitcroft
 - sparsemem precense/valid split
 - rename Kconfig options into SPARSEMEM configuration name space
 - redundant vmemmap alignment removed
 - split out PMD support to x86_64
 - x86_64 Kconfig dependancies
 - ia64 Kconfig dependancies
 - sparc64 dependancies, cleanup defines
 - cleanup function names _pop_ -> _populate_
 - markup __meminit
 - cleanup style
 - whitespace cleanups

V2->V3
 - Add IA64 16M vmemmap size support (reduces TLB pressure)
 - Add function to test for eventual node/node vmemmap overlaps
 - Upper / Lower boundary fix.

V1->V2
 - Support for PAGE_SIZE vmemmap which allows the general use of
   of virtual memmap on any MMU capable platform (enabled IA64
   support).
 - Fix various issues as suggested by Dave Hansen.
 - Add comments and error handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 25276900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 07:46:52 -0400 (EDT)
Date: Thu, 23 Jun 2011 12:46:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: sandy bridge kswapd0 livelock with pagecache
Message-ID: <20110623114646.GM9396@suse.de>
References: <4E0069FE.4000708@draigBrady.com>
 <20110621103920.GF9396@suse.de>
 <4E0076C7.4000809@draigBrady.com>
 <20110621113447.GG9396@suse.de>
 <4E008784.80107@draigBrady.com>
 <20110621130756.GH9396@suse.de>
 <4E00A96D.8020806@draigBrady.com>
 <20110622094401.GJ9396@suse.de>
 <4E01C19F.20204@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4E01C19F.20204@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P?draig Brady <P@draigBrady.com>
Cc: linux-mm@kvack.org

On Wed, Jun 22, 2011 at 11:19:11AM +0100, P?draig Brady wrote:
> On 22/06/11 10:44, Mel Gorman wrote:
> > I haven't started looking at this properly yet (stuck with other
> > bugs unfortunately) but I glanced at the sysrq message and on a 2G
> > 64-bit machine, you have a tiny Normal zone! This is very unexpected.
> > Can you boot with mminit_loglevel=4 loglevel=9 and post your full
> > dmesg please? I want to see what the memory layout of this thing
> > looks like to see in the future if there is a correlation between
> > this type of bug and a tiny highest zone.
> 
> Note this machine has 3G RAM

My bad, I read the 2G from Dan Doel's machine in the bugzilla. I
still haven't been able to reproduce this locally but that's not new.
Eventually one of these laptops will show up on ebay :/

> dmesg attached
> 
> > 
> > Broadly speaking though from seeing that, it reminds me of a
> > similar bug where small zones could keep kswapd alive for high-order
> > allocations reclaiming slab constantly. I suspect on your machine
> > that the Normal zone cannot be balanced for order-0 allocations and
> > is keeping kswapd awake.
> > 
> > Can you try booting with mem=1792M and if the Normal zone disappears,
> > try reproducing the bug?
> > 
> 
> I tried mem=1792M but grub gave an ENOSPC error
> Maybe I need to supply a memmap= too?

Not sure what is going on there unfortunately. The range of memory
grub should be using for the initrd and kernel image should be still
available with those parameters.

> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 2.6.38.8-32.fc15.x86_64 (padraig@pb-n5110) (gcc version 4.6.0 20110509 (Red Hat 4.6.0-7) (GCC) ) #5 SMP Tue Jun 21 16:24:12 IST 2011
> [    0.000000] Command line: ro root=UUID=da48811c-7aeb-4514-8c75-a56a82bba9fa rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYTABLE=uk rhgb quiet mminit_loglevel=4 loglevel=9
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009d400 (usable)
> [    0.000000]  BIOS-e820: 000000000009d400 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 0000000020000000 (usable)
> [    0.000000]  BIOS-e820: 0000000020000000 - 0000000020200000 (reserved)
> [    0.000000]  BIOS-e820: 0000000020200000 - 0000000040000000 (usable)
> [    0.000000]  BIOS-e820: 0000000040000000 - 0000000040200000 (reserved)
> [    0.000000]  BIOS-e820: 0000000040200000 - 00000000b9ce3000 (usable)
> [    0.000000]  BIOS-e820: 00000000b9ce3000 - 00000000b9d26000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 00000000b9d26000 - 00000000b9f92000 (usable)
> [    0.000000]  BIOS-e820: 00000000b9f92000 - 00000000ba167000 (reserved)
> [    0.000000]  BIOS-e820: 00000000ba167000 - 00000000ba3a9000 (usable)
> [    0.000000]  BIOS-e820: 00000000ba3a9000 - 00000000ba568000 (reserved)
> [    0.000000]  BIOS-e820: 00000000ba568000 - 00000000ba7e8000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 00000000ba7e8000 - 00000000ba800000 (ACPI data)
> [    0.000000]  BIOS-e820: 00000000bb000000 - 00000000bf200000 (reserved)
> [    0.000000]  BIOS-e820: 00000000f8000000 - 00000000fc000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed04000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
> [    0.000000]  BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
> [    0.000000]  BIOS-e820: 0000000100000000 - 0000000100600000 (usable)
> [    0.000000] Faking a node at 0000000000000000-0000000100600000
> [    0.000000] mminit::memory_register Entering add_active_range(0, 0x10, 0x9d) 0 entries of 25600 used
> [    0.000000] mminit::memory_register Entering add_active_range(0, 0x100, 0x20000) 1 entries of 25600 used
> [    0.000000] mminit::memory_register Entering add_active_range(0, 0x20200, 0x40000) 2 entries of 25600 used
> [    0.000000] mminit::memory_register Entering add_active_range(0, 0x40200, 0xb9ce3) 3 entries of 25600 used
> [    0.000000] mminit::memory_register Entering add_active_range(0, 0xb9d26, 0xb9f92) 4 entries of 25600 used
> [    0.000000] mminit::memory_register Entering add_active_range(0, 0xba167, 0xba3a9) 5 entries of 25600 used
> [    0.000000] mminit::memory_register Entering add_active_range(0, 0x100000, 0x100600) 6 entries of 25600 used
> [    0.000000] Initmem setup node 0 0000000000000000-0000000100600000
> [    0.000000]   NODE_DATA [00000001005ec000 - 00000001005fffff]
> [    0.000000]  [ffffea0000000000-ffffea00039fffff] PMD -> [ffff88001b600000-ffff88001e1fffff] on node 0
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00000010 -> 0x00001000
> [    0.000000]   DMA32    0x00001000 -> 0x00100000
> [    0.000000]   Normal   0x00100000 -> 0x00100600

The address space for DMA32 is oddly fragmented with just enough device
mappings to create a small Normal zone of 6M which I can replicate
with movablecore=. Unfortunately, I only saw really high kswapd usage
once and it didn't hang with the same severity. I wasn't running X
which based on your profile is a factor though so will try again. We
could figure out exactly what devices with /proc/iomem and lspci but
it's not important. Am going to mark it down as a quirk of the laptop.

Based on the information you have provided from sysrq and the profile,
I put together a theory as to what is going wrong for your machine at
least although I somehow doubt the same fix will work for Dan. Can you
try out the following please? It's against 2.6.38.8 (and presumably
Fedora) but will apply with offset against 2.6.39 and 3.0-rc4.

==== CUT HERE ====
mm: vmscan: Correct check for kswapd sleeping in sleeping_prematurely

During allocator-intensive workloads, kswapd will be woken frequently
causing free memory to oscillate between the high and min watermark.
This is expected behaviour.

A problem occurs if the highest zone is small that keeps kswapd awake.
balance_pgdat() only considers unreclaimable zones when priority
is DEF_PRIORITY but sleeping_prematurely considers all zones. It's
possible for this sequence to occur

  1. kswapd wakes up and enters balance_pgdat()
  2. At DEF_PRIORITY, marks highest zone unreclaimable
  3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
  4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
        highest zone, clearing all_unreclaimable. Highest zone
        is still unbalanced
  5. kswapd returns and calls sleeping_prematurely before sleep
  6. sleeping_prematurely looks at *all* zones, not just the ones
     being considered by balance_pgdat. The highest small zone
     has all_unreclaimable cleared but the zone is not
     balanced. all_zones_ok is false so kswapd stays awake

The impact is that kswapd chews up a lot of CPU as it avoids most of
the scheduling points and reclaims excessively from the lower zones.
This patch corrects the behaviour of sleeping_prematurely to check
the zones balance_pgdat() checked.

Reported-by: Padraig Brady <P@draigBrady.com>
Not-signed-off-awaiting-confirmation: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a74bf72..a578535 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2261,7 +2261,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 		return true;
 
 	/* Check the watermark levels */
-	for (i = 0; i < pgdat->nr_zones; i++) {
+	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
 		if (!populated_zone(zone))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

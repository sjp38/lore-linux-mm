Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E876D6B0003
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 23:41:40 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id h184-v6so5188865wmf.1
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 20:41:40 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id 4-v6si5206036wmk.174.2018.11.10.20.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 20:41:38 -0800 (PST)
From: Qian Cai <cai@gmx.us>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 12.0 \(3445.100.39\))
Subject: crashkernel=512M is no longer working on this aarch64 server
Message-Id: <1A7E2E89-34DB-41A0-BBA2-323073A7E298@gmx.us>
Date: Sat, 10 Nov 2018 23:41:34 -0500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

It was broken somewhere between b00d209241ff and 3541833fd1f2.

[    0.000000] cannot allocate crashkernel (size:0x20000000)

Where a good one looks like this,

[    0.000000] crashkernel reserved: 0x0000000008600000 - =
0x0000000028600000 (512 MB)

Some commits look more suspicious than others.

      mm: add mm_pxd_folded checks to pgtable_bytes accounting functions
      mm: introduce mm_[p4d|pud|pmd]_folded
      mm: make the __PAGETABLE_PxD_FOLDED defines non-empty

# diff -u ../iomem.good.txt ../iomem.bad.txt=20
--- ../iomem.good.txt	2018-11-10 22:28:20.092614398 -0500
+++ ../iomem.bad.txt	2018-11-10 20:39:54.930294479 -0500
@@ -1,9 +1,8 @@
 00000000-3965ffff : System RAM
   00080000-018cffff : Kernel code
-  018d0000-020affff : reserved
-  020b0000-045affff : Kernel data
-  08600000-285fffff : Crash kernel
-  28730000-2d5affff : reserved
+  018d0000-0762ffff : reserved
+  07630000-09b2ffff : Kernel data
+  231b0000-2802ffff : reserved
   30ec0000-30ecffff : reserved
   35660000-3965ffff : reserved
 39660000-396fffff : reserved
@@ -127,7 +126,7 @@
   7c5200000-7c520ffff : 0004:48:00.0
 1040000000-17fbffffff : System RAM
   13fbfd0000-13fdfdffff : reserved
-  16fba80000-17fbfdffff : reserved
+  16fafd0000-17fbfdffff : reserved
   17fbfe0000-17fbffffff : reserved
 1800000000-1ffbffffff : System RAM
   1bfbff0000-1bfdfeffff : reserved

The memory map looks like this,

[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000398D0014 000024 (v02 HISI  )
[    0.000000] ACPI: XSDT 0x00000000398C00E8 000064 (v01 HISI   HIP07    =
00000000      01000013)
[    0.000000] ACPI: FACP 0x0000000039770000 000114 (v06 HISI   HIP07    =
00000000 INTL 20151124)
[    0.000000] ACPI: DSDT 0x0000000039730000 00691A (v02 HISI   HIP07    =
00000000 INTL 20170728)
[    0.000000] ACPI: MCFG 0x00000000397C0000 0000AC (v01 HISI   HIP07    =
00000000 INTL 20151124)
[    0.000000] ACPI: SLIT 0x00000000397B0000 00003C (v01 HISI   HIP07    =
00000000 INTL 20151124)
[    0.000000] ACPI: SRAT 0x00000000397A0000 000578 (v03 HISI   HIP07    =
00000000 INTL 20151124)
[    0.000000] ACPI: DBG2 0x0000000039790000 00005A (v00 HISI   HIP07    =
00000000 INTL 20151124)
[    0.000000] ACPI: GTDT 0x0000000039760000 00007C (v02 HISI   HIP07    =
00000000 INTL 20151124)
[    0.000000] ACPI: APIC 0x0000000039750000 0014E4 (v04 HISI   HIP07    =
00000000 INTL 20151124)
[    0.000000] ACPI: IORT 0x0000000039740000 000554 (v00 HISI   HIP07    =
00000000 INTL 20170728)
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x3fffffff]
[    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x1800000000-0x1fffffffff]
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x1000000000-0x17ffffffff]
[    0.000000] ACPI: SRAT: Node 3 PXM 3 [mem 0x9000000000-0x97ffffffff]
[    0.000000] ACPI: SRAT: Node 2 PXM 2 [mem 0x8800000000-0x8fffffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x17fbffe5c0-0x17fbffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x1ffbffe5c0-0x1ffbffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x8ffbffe5c0-0x8ffbffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x97fadce5c0-0x97fadcffff]
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000097fbffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x000000003965ffff]
[    0.000000]   node   0: [mem 0x0000000039660000-0x00000000396fffff]
[    0.000000]   node   0: [mem 0x0000000039700000-0x000000003977ffff]
[    0.000000]   node   0: [mem 0x0000000039780000-0x000000003978ffff]
[    0.000000]   node   0: [mem 0x0000000039790000-0x00000000397cffff]
[    0.000000]   node   0: [mem 0x00000000397d0000-0x00000000398bffff]
[    0.000000]   node   0: [mem 0x00000000398c0000-0x00000000398dffff]
[    0.000000]   node   0: [mem 0x00000000398e0000-0x0000000039d5ffff]
[    0.000000]   node   0: [mem 0x0000000039d60000-0x000000003ed4ffff]
[    0.000000]   node   0: [mem 0x000000003ed50000-0x000000003ed7ffff]
[    0.000000]   node   0: [mem 0x000000003ed80000-0x000000003fbfffff]
[    0.000000]   node   0: [mem 0x0000001040000000-0x00000017fbffffff]
[    0.000000]   node   1: [mem 0x0000001800000000-0x0000001ffbffffff]
[    0.000000]   node   2: [mem 0x0000008800000000-0x0000008ffbffffff]
[    0.000000]   node   3: [mem 0x0000009000000000-0x00000097fbffffff]

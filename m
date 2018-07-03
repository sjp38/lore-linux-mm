Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFD176B0269
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 17:10:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h14-v6so1596471pfi.19
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 14:10:56 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id a1-v6si1893157plp.247.2018.07.03.14.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 14:10:55 -0700 (PDT)
Subject: [PATCH] x86/numa_emulation: Fix uniform size build failure
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 03 Jul 2018 14:00:57 -0700
Message-ID: <153065162801.12250.4860144566061573514.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Wei Yang <richard.weiyang@gmail.com>, kbuild test robot <lkp@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The calculation of a uniform numa-node size attempted to perform
division with a 64-bit diviser leading to the following failure on
32-bit:

    arch/x86/mm/numa_emulation.o: In function `split_nodes_size_interleave_uniform':
    arch/x86/mm/numa_emulation.c:239: undefined reference to `__udivdi3'

Convert the implementation to do the division in terms of pages and then
shift the result back to an absolute physical address.

Fixes: 93e738834fcc ("x86/numa_emulation: Introduce uniform split capability")
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Wei Yang <richard.weiyang@gmail.com>
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

    Applies to tip/x86/cpu for 4.19.

 arch/x86/mm/numa_emulation.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index 039db00541b7..cc7523e45926 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -198,6 +198,14 @@ static u64 __init find_end_of_node(u64 start, u64 max_addr, u64 size)
 	return end;
 }
 
+static u64 uniform_size(u64 max_addr, u64 base, int nr_nodes)
+{
+	unsigned long max_pfn = PHYS_PFN(max_addr);
+	unsigned long base_pfn = PHYS_PFN(base);
+
+	return PFN_PHYS((max_pfn - base_pfn) / nr_nodes);
+}
+
 /*
  * Sets up fake nodes of `size' interleaved over physical nodes ranging from
  * `addr' to `max_addr'.
@@ -236,7 +244,7 @@ static int __init split_nodes_size_interleave_uniform(struct numa_meminfo *ei,
 	}
 
 	if (uniform) {
-		min_size = (max_addr - addr) / nr_nodes;
+		min_size = uniform_size(max_addr, addr, nr_nodes);
 		size = min_size;
 	} else {
 		/*

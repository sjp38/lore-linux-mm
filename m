Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id CF71F6B0039
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 10:27:07 -0500 (EST)
Received: by mail-oa0-f54.google.com with SMTP id o6so1947718oag.27
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 07:27:07 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id r7si797304oem.136.2014.01.08.07.27.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 07:27:06 -0800 (PST)
From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] x86/mm: memblock: switch to use NUMA_NO_NODE
Date: Wed, 8 Jan 2014 18:23:18 +0200
Message-ID: <1389198198-31027-1-git-send-email-grygorii.strashko@ti.com>
In-Reply-To: <20140107022559.GE14055@localhost>
References: <20140107022559.GE14055@localhost>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, santosh.shilimkar@ti.com
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

Update X86 code to use NUMA_NO_NODE instead of MAX_NUMNODES while
calling memblock APIs, because memblock API is changed to use NUMA_NO_NODE and
will produce warning during boot otherwise.

See:
 https://lkml.org/lkml/2013/12/9/898

Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
Hi Fengguang,

This patch should fix these warnings.

Regards,
-grygorii

 arch/x86/kernel/check.c |    2 +-
 arch/x86/kernel/e820.c  |    2 +-
 arch/x86/mm/memtest.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/check.c b/arch/x86/kernel/check.c
index e2dbcb7..83a7995 100644
--- a/arch/x86/kernel/check.c
+++ b/arch/x86/kernel/check.c
@@ -91,7 +91,7 @@ void __init setup_bios_corruption_check(void)
 
 	corruption_check_size = round_up(corruption_check_size, PAGE_SIZE);
 
-	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL) {
+	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL) {
 		start = clamp_t(phys_addr_t, round_up(start, PAGE_SIZE),
 				PAGE_SIZE, corruption_check_size);
 		end = clamp_t(phys_addr_t, round_down(end, PAGE_SIZE),
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 174da5f..988c00a 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1120,7 +1120,7 @@ void __init memblock_find_dma_reserve(void)
 		nr_pages += end_pfn - start_pfn;
 	}
 
-	for_each_free_mem_range(u, MAX_NUMNODES, &start, &end, NULL) {
+	for_each_free_mem_range(u, NUMA_NO_NODE, &start, &end, NULL) {
 		start_pfn = min_t(unsigned long, PFN_UP(start), MAX_DMA_PFN);
 		end_pfn = min_t(unsigned long, PFN_DOWN(end), MAX_DMA_PFN);
 		if (start_pfn < end_pfn)
diff --git a/arch/x86/mm/memtest.c b/arch/x86/mm/memtest.c
index 8dabbed..1e9da79 100644
--- a/arch/x86/mm/memtest.c
+++ b/arch/x86/mm/memtest.c
@@ -74,7 +74,7 @@ static void __init do_one_pass(u64 pattern, u64 start, u64 end)
 	u64 i;
 	phys_addr_t this_start, this_end;
 
-	for_each_free_mem_range(i, MAX_NUMNODES, &this_start, &this_end, NULL) {
+	for_each_free_mem_range(i, NUMA_NO_NODE, &this_start, &this_end, NULL) {
 		this_start = clamp_t(phys_addr_t, this_start, start, end);
 		this_end = clamp_t(phys_addr_t, this_end, start, end);
 		if (this_start < this_end) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

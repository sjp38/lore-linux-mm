Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF8E6B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 16:46:49 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n0JLjE4M026901
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 14:45:14 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0JLkkaP211738
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 14:46:46 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0JLkjfs001045
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 14:46:46 -0700
Date: Mon, 19 Jan 2009 13:46:41 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: [PATCH] x86_64: remove kernel_physical_mapping_init() from init
	section
Message-ID: <20090119214641.GB7476@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu
Cc: yhlu.kernel@gmail.com, garyhade@us.ibm.com, lcm@us.ibm.com, x86@kernel.org
List-ID: <linux-mm.kvack.org>


kernel_physical_mapping_init() is called during memory hotplug
so it does not belong in the init section.

If the kernel is built with CONFIG_DEBUG_SECTION_MISMATCH=y on
the make command line, arch/x86/mm/init_64.c is compiled with
the -fno-inline-functions-called-once gcc option defeating
inlining of kernel_physical_mapping_init() within init_memory_mapping().
When kernel_physical_mapping_init() is not inlined it is placed
in the .init.text section according to the __init in it's current
declaration.  A later call to kernel_physical_mapping_init() during
a memory hotplug operation encounters an int3 trap because the
.init.text section memory has been freed.  This patch eliminates
the crash caused by the int3 trap by moving the non-inlined
kernel_physical_mapping_init() from .init.text to .meminit.text.

Signed-off-by: Gary Hade <garyhade@us.ibm.com>

---

--- linux-2.6.29-rc2/arch/x86/mm/init_64.c.orig	2009-01-16 14:38:34.000000000 -0800
+++ linux-2.6.29-rc2/arch/x86/mm/init_64.c	2009-01-16 14:39:21.000000000 -0800
@@ -596,7 +596,7 @@ static void __init init_gbpages(void)
 		direct_gbpages = 0;
 }
 
-static unsigned long __init kernel_physical_mapping_init(unsigned long start,
+static unsigned long __meminit kernel_physical_mapping_init(unsigned long start,
 						unsigned long end,
 						unsigned long page_size_mask)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

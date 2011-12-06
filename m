Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id B2B3E6B004F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 03:08:27 -0500 (EST)
Date: Tue, 6 Dec 2011 09:08:34 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH] mm,x86: initialize high mem before free_all_bootmem()
Message-ID: <20111206080833.GB3105@redhat.com>
References: <1322582711-14571-1-git-send-email-sgruszka@redhat.com>
 <20111205110656.GA22259@elte.hu>
 <20111205150019.GA5434@redhat.com>
 <20111205155434.GD30287@elte.hu>
 <20111206075530.GA3105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111206075530.GA3105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

Patch fixes boot crash with my previous patch "mm,x86: remove
debug_pagealloc_enabled" applied:

Initializing HighMem for node 0 (000377fe:0003fff0)
BUG: unable to handle kernel paging request at f6fefe80
IP: [<c1621ab5>] find_range_array+0x5e/0x69
*pde = 01ff2067 *pte = 36fef160
Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
Modules linked in:

Pid: 0, comm: swapper Not tainted 3.2.0-rc4-tip-01533-g9b242f0-dirty #162987 System manufacturer System Product Name/A8N-E
EIP: 0060:[<c1621ab5>] EFLAGS: 00010046 CPU: 0
EIP is at find_range_array+0x5e/0x69
EAX: 00000000 EBX: 00000300 ECX: 00000300 EDX: f6fefe80
ESI: 00000030 EDI: f6fefe80 EBP: c15b9ed0 ESP: c15b9eb0
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Process swapper (pid: 0, ti=c15b8000 task=c15bdee0 task.ti=c15b8000)
Stack:
 377fe000 00000000 00000300 00000000 00000010 00000000 c1608c40 00000000
 c15b9f00 c1622064 c15b0020 c15c32a0 c15c32b0 c15c32a0 000377fe c15b9f1c
 00000002 c1608c40 000377fe 0003fff0 c15b9f2c c1620dd0 0003fff0 d9d9ca83
Call Trace:
 [<c1622064>] __get_free_all_memory_range+0x39/0xb4
 [<c1620dd0>] add_highpages_with_active_regions+0x18/0x9b
 [<c1621a2e>] set_highmem_pages_init+0x70/0x90
 [<c162122b>] mem_init+0x50/0x21b
 [<c1629913>] ? __alloc_bootmem_node_nopanic+0x63/0x86
 [<c13ea147>] ? printk+0x1d/0x1f
 [<c162ac6a>] ? page_cgroup_init_flatmem+0x8f/0xbc
 [<c16155bd>] start_kernel+0x1bf/0x31c
 [<c1615213>] ? obsolete_checksetup+0x95/0x95
 [<c1615065>] i386_start_kernel+0x65/0x67
Code: 00 00 c7 44 24 04 00 00 00 00 e8 e5 81 00 00 09 c2 75 0c c7 04 24
28 fc 51 c1 e8 60 84 dc ff 8d 90 00 00 00 c0 89 d9 31 c0 89 d7 <f3> aa
83 c4 18 89 d0 5b 5f
+5d c3 55 89 e5 57 89 d7 56 89 c6 53
EIP: [<c1621ab5>] find_range_array+0x5e/0x69 SS:ESP 0068:c15b9eb0
CR2: 00000000f6fefe80

Crash can happen when memblock want to allocate big area for temporary
"struct range" array and reuse pages from top of low memory, which were
already passed to the buddy allocator.

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
Would be good to apply this patch before "mm,x86: remove
debug_pagealloc_enabled" to prevent problem be possibly
observable during bisection.

 arch/x86/mm/init_32.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 29f7c6d..649de41 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -760,6 +760,17 @@ void __init mem_init(void)
 #ifdef CONFIG_FLATMEM
 	BUG_ON(!mem_map);
 #endif
+	/*
+	 * With CONFIG_DEBUG_PAGEALLOC initialization of highmem pages has to
+	 * be done before free_all_bootmem(). Memblock use free low memory for
+	 * temporary data (see find_range_array()) and for this purpose can use
+	 * pages that was already passed to the buddy allocator, hence marked as
+	 * not accessible in the page tables when compiled with
+	 * CONFIG_DEBUG_PAGEALLOC. Otherwise order of initialization is not
+	 * important here.
+	 */
+	set_highmem_pages_init();
+
 	/* this will put all low memory onto the freelists */
 	totalram_pages += free_all_bootmem();
 
@@ -771,8 +782,6 @@ void __init mem_init(void)
 		if (page_is_ram(tmp) && PageReserved(pfn_to_page(tmp)))
 			reservedpages++;
 
-	set_highmem_pages_init();
-
 	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
 	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
 	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

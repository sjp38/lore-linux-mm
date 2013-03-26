Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 9EBF76B0124
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 12:02:29 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id rr4so2114580pbb.24
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 09:02:28 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 30/39] mm/score: prepare for removing num_physpages and simplify mem_init()
Date: Tue, 26 Mar 2013 23:54:49 +0800
Message-Id: <1364313298-17336-31-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Chen Liqin <liqin.chen@sunplusct.com>, Lennox Wu <lennox.wu@gmail.com>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chen Liqin <liqin.chen@sunplusct.com>
Cc: Lennox Wu <lennox.wu@gmail.com>
Cc: linux-kernel@vger.kernel.org
---
Hi all,
	Sorry for my mistake that my previous patch series has been screwed up.
So I regenerate a third version and also set up a git tree at:
	git://github.com/jiangliu/linux.git mem_init
	Any help to review and test are welcomed!

	Regards!
	Gerry
---
 arch/score/mm/init.c |   26 ++------------------------
 1 file changed, 2 insertions(+), 24 deletions(-)

diff --git a/arch/score/mm/init.c b/arch/score/mm/init.c
index 579fc4e..2a223d8 100644
--- a/arch/score/mm/init.c
+++ b/arch/score/mm/init.c
@@ -77,33 +77,11 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	unsigned long codesize, reservedpages, datasize, initsize;
-	unsigned long tmp, ram = 0;
-
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
 	free_all_bootmem();
 	setup_zero_page();	/* Setup zeroed pages. */
-	reservedpages = 0;
-
-	for (tmp = 0; tmp < max_low_pfn; tmp++)
-		if (page_is_ram(tmp)) {
-			ram++;
-			if (PageReserved(pfn_to_page(tmp)))
-				reservedpages++;
-		}
-
-	num_physpages = ram;
-	codesize = (unsigned long) &_etext - (unsigned long) &_text;
-	datasize = (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize = (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
-	printk(KERN_INFO "Memory: %luk/%luk available (%ldk kernel code, "
-			"%ldk reserved, %ldk data, %ldk init, %ldk highmem)\n",
-			(unsigned long) nr_free_pages() << (PAGE_SHIFT-10),
-			ram << (PAGE_SHIFT-10), codesize >> 10,
-			reservedpages << (PAGE_SHIFT-10), datasize >> 10,
-			initsize >> 10,
-			totalhigh_pages << (PAGE_SHIFT-10));
+
+	mem_init_print_info(NULL);
 }
 #endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

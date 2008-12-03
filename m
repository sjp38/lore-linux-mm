Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id mB3LPWnb028348
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 21:25:32 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3LPW9u4141126
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 22:25:32 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB3LPVhg009968
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 22:25:32 +0100
Subject: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
Content-Type: text/plain
Date: Wed, 03 Dec 2008 22:25:24 +0100
Message-Id: <1228339524.6598.11.camel@t60p>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

From: Gerald Schaefer <gerald.schaefer@de.ibm.com>

offline_pages() calls lru_add_drain_all() followed by drain_all_pages().
While drain_all_pages() works on each cpu, lru_add_drain_all() only runs
on the current cpu for architectures w/o CONFIG_NUMA. This let us run
into the BUG_ON(!PageBuddy(page)) in __offline_isolated_pages() during
memory hotplug stress test on s390. The page in question was still on the
pcp list, because of a race with lru_add_drain_all() and drain_all_pages()
on different cpus.

This is fixed with this patch by adding CONFIG_MEMORY_HOTREMOVE to the
lru_add_drain_all() #ifdef, to let it run on each cpu.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

---
 mm/swap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -299,7 +299,8 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
-#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
+#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU) || \
+    defined(CONFIG_MEMORY_HOTREMOVE)
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

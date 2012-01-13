Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id A57636B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 06:49:57 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Fri, 13 Jan 2012 11:35:37 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0DBgU7h3539064
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:42:30 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0DBkvJj026031
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:46:57 +1100
Message-ID: <4F1019B0.5080503@linux.vnet.ibm.com>
Date: Fri, 13 Jan 2012 19:46:56 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/5] mm: do not reset cached_hole_size when vma is unmapped
References: <4F101904.8090405@linux.vnet.ibm.com>
In-Reply-To: <4F101904.8090405@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

In current code, cached_hole_size is set to the maximal value if the unmapped
vma is under free_area_cache, next search will search from the base addr

Actually, we can keep cached_hole_size so that if next required size is more
that cached_hole_size, it can search from free_area_cache

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/mmap.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3f758c7..970f572 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1423,10 +1423,8 @@ void arch_unmap_area(struct mm_struct *mm, unsigned long addr)
 	/*
 	 * Is this a new hole at the lowest possible address?
 	 */
-	if (addr >= TASK_UNMAPPED_BASE && addr < mm->free_area_cache) {
+	if (addr >= TASK_UNMAPPED_BASE && addr < mm->free_area_cache)
 		mm->free_area_cache = addr;
-		mm->cached_hole_size = ~0UL;
-	}
 }

 /*
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9946B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:39:11 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so6222089pbc.23
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 17:39:11 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Sep 2013 06:09:05 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id DB5D03940058
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:08:49 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8I0d0Ol42008738
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:09:00 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8I0d2tL014672
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:09:02 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 1/4] mm/hwpoison: fix traverse hugetlbfs page to avoid printk flood
Date: Wed, 18 Sep 2013 08:38:54 +0800
Message-Id: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

madvise_hwpoison won't check if the page is small page or huge page and traverse
in small page granularity against the range unconditional, which result in a printk
flood "MCE xxx: already hardware poisoned" if the page is huge page. This patch fix
it by increase compound_order(compound_head(page)) for huge page iterator.

Testcase:

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <errno.h>

#define PAGES_TO_TEST 3
#define PAGE_SIZE	4096 * 512

int main(void)
{
	char *mem;
	int i;

	mem = mmap(NULL, PAGES_TO_TEST * PAGE_SIZE,
			PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, 0, 0);

	if (madvise(mem, PAGES_TO_TEST * PAGE_SIZE, MADV_HWPOISON) == -1)
		return -1;

	munmap(mem, PAGES_TO_TEST * PAGE_SIZE);

	return 0;
}

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/madvise.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 6975bc8..539eeb9 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -343,10 +343,11 @@ static long madvise_remove(struct vm_area_struct *vma,
  */
 static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 {
+	struct page *p;
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
-	for (; start < end; start += PAGE_SIZE) {
-		struct page *p;
+	for (; start < end; start += PAGE_SIZE <<
+				compound_order(compound_head(p))) {
 		int ret;
 
 		ret = get_user_pages_fast(start, 1, 0, &p);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

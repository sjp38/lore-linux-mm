Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id DD9756B0037
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 06:31:06 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 20:19:48 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 659612CE8054
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:57 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7NAUf9I31391870
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:46 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7NAUpGi028283
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:51 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 1/7] mm/hwpoison: fix lose PG_dirty flag for errors on mlocked pages
Date: Fri, 23 Aug 2013 18:30:35 +0800
Message-Id: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

memory_failure() store the page flag of the error page before doing unmap,
and (only) if the first check with page flags at the time decided the error
page is unknown, it do the second check with the stored page flag since
memory_failure() does unmapping of the error pages before doing page_action().
This unmapping changes the page state, especially page_remove_rmap() (called
from try_to_unmap_one()) clears PG_mlocked, so page_action() can't catch
mlocked pages after that.

However, memory_failure() can't handle memory errors on dirty mlocked pages
correctly. try_to_unmap_one will move the dirty bit from pte to the physical
page, the second check lose it since it check the stored page flag. This patch
fix it by restore PG_dirty flag to stored page flag if the page is dirty.

Testcase:

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <errno.h>

#define PAGES_TO_TEST 2
#define PAGE_SIZE	4096

int main(void)
{
	char *mem;
	int i;

	mem = mmap(NULL, PAGES_TO_TEST * PAGE_SIZE,
			PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKED, 0, 0);

	for (i = 0; i < PAGES_TO_TEST; i++)
		mem[i * PAGE_SIZE] = 'a';

	if (madvise(mem, PAGES_TO_TEST * PAGE_SIZE, MADV_HWPOISON) == -1)
		return -1;

	return 0;
}

Before patch:

[  912.839247] Injecting memory failure for page 7dfb8 at 7f6b4e37b000
[  912.839257] MCE 0x7dfb8: clean mlocked LRU page recovery: Recovered
[  912.845550] MCE 0x7dfb8: clean mlocked LRU page still referenced by 1 users
[  912.852586] Injecting memory failure for page 7e6aa at 7f6b4e37c000
[  912.852594] MCE 0x7e6aa: clean mlocked LRU page recovery: Recovered
[  912.858936] MCE 0x7e6aa: clean mlocked LRU page still referenced by 1 users

After patch:

[  163.590225] Injecting memory failure for page 91bc2f at 7f9f5b0e5000
[  163.590264] MCE 0x91bc2f: dirty mlocked LRU page recovery: Recovered
[  163.596680] MCE 0x91bc2f: dirty mlocked LRU page still referenced by 1 users
[  163.603831] Injecting memory failure for page 91cdd3 at 7f9f5b0e6000
[  163.603852] MCE 0x91cdd3: dirty mlocked LRU page recovery: Recovered
[  163.610305] MCE 0x91cdd3: dirty mlocked LRU page still referenced by 1 users

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2c13aa7..d5686d4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1204,6 +1204,9 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	for (ps = error_states;; ps++)
 		if ((p->flags & ps->mask) == ps->res)
 			break;
+
+	page_flags |= (p->flags & (1UL << PG_dirty));
+
 	if (!ps->mask)
 		for (ps = error_states;; ps++)
 			if ((page_flags & ps->mask) == ps->res)
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id F00F16B003C
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 04:46:38 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 18:35:14 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DEDAB2CE8052
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:46:33 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q8UUYZ66715850
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:30:30 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7Q8kWQj010047
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:46:33 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 8/10] mm/hwpoison: fix memory failure still hold reference count after unpoison empty zero page 
Date: Mon, 26 Aug 2013 16:46:12 +0800
Message-Id: <1377506774-5377-8-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

madvise hwpoison inject will poison the read-only empty zero page if there is 
no write access before poison. Empty zero page reference count will be increased 
for hwpoison, subsequent poison zero page will return directly since page has
already been set PG_hwpoison, however, page reference count is still increased 
by get_user_pages_fast. The unpoison process will unpoison the empty zero page 
and decrease the reference count successfully for the fist time, however, 
subsequent unpoison empty zero page will return directly since page has already 
been unpoisoned and without decrease the page reference count of empty zero page.
This patch fix it by decrease page reference count for empty zero page which has 
already been unpoisoned and page count > 1.

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
#define PAGE_SIZE	4096

int main(void)
{
	char *mem;
	int i;

	mem = mmap(NULL, PAGES_TO_TEST * PAGE_SIZE,
			PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);

	if (madvise(mem, PAGES_TO_TEST * PAGE_SIZE, MADV_HWPOISON) == -1)
		return -1;
	
	munmap(mem, PAGES_TO_TEST * PAGE_SIZE);

	return 0;
}

Add printk to dump page reference count:

[   93.075959] Injecting memory failure for page 0x19d0 at 0xb77d8000
[   93.076207] MCE 0x19d0: non LRU page recovery: Ignored
[   93.076209] pfn 0x19d0, page count = 1 after memory failure
[   93.076220] Injecting memory failure for page 0x19d0 at 0xb77d9000
[   93.076221] MCE 0x19d0: already hardware poisoned
[   93.076222] pfn 0x19d0, page count = 2 after memory failure
[   93.076224] Injecting memory failure for page 0x19d0 at 0xb77da000
[   93.076224] MCE 0x19d0: already hardware poisoned
[   93.076225] pfn 0x19d0, page count = 3 after memory failure

Before patch:

[  139.197474] MCE: Software-unpoisoned page 0x19d0
[  139.197479] pfn 0x19d0, page count = 2 after unpoison memory
[  150.478130] MCE: Page was already unpoisoned 0x19d0
[  150.478135] pfn 0x19d0, page count = 2 after unpoison memory
[  151.548288] MCE: Page was already unpoisoned 0x19d0
[  151.548292] pfn 0x19d0, page count = 2 after unpoison memory

After patch:

[  116.022122] MCE: Software-unpoisoned page 0x19d0
[  116.022127] pfn 0x19d0, page count = 2 after unpoison memory
[  117.256163] MCE: Page was already unpoisoned 0x19d0
[  117.256167] pfn 0x19d0, page count = 1 after unpoison memory
[  117.917772] MCE: Page was already unpoisoned 0x19d0
[  117.917777] pfn 0x19d0, page count = 1 after unpoison memory

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ca714ac..fb687fd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1335,6 +1335,8 @@ int unpoison_memory(unsigned long pfn)
 	page = compound_head(p);
 
 	if (!PageHWPoison(p)) {
+		if (pfn == my_zero_pfn(0) && page_count(p) > 1)
+			put_page(p);
 		pr_info("MCE: Page was already unpoisoned %#lx\n", pfn);
 		return 0;
 	}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D988D6B005A
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 04:46:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 14:07:31 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id EA6031258053
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 14:16:29 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q8mGIJ37683304
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 14:18:17 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7Q8kaCI002353
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 14:16:36 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 10/10] mm/hwpoison: fix bug triggered by unpoison empty zero page 
Date: Mon, 26 Aug 2013 16:46:14 +0800
Message-Id: <1377506774-5377-10-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

[   57.579580] Injecting memory failure for page 0x19d0 at 0xb77d2000
[   57.579824] MCE 0x19d0: non LRU page recovery: Ignored
[   91.290453] MCE: Software-unpoisoned page 0x19d0
[   91.290456] BUG: Bad page state in process bash  pfn:019d0
[   91.290466] page:f3461a00 count:0 mapcount:0 mapping:  (null) index:0x0
[   91.290467] page flags: 0x40000404(referenced|reserved)
[   91.290469] Modules linked in: nfsd auth_rpcgss i915 nfs_acl nfs lockd video drm_kms_helper drm bnep rfcomm sunrpc bluetooth psmouse parport_pc ppdev lp serio_raw fscache parport gpio_ich lpc_ich mac_hid i2c_algo_bit tpm_tis wmi usb_storage hid_generic usbhid hid e1000e firewire_ohci firewire_core ahci ptp libahci pps_core crc_itu_t
[   91.290486] CPU: 3 PID: 2123 Comm: bash Not tainted 3.11.0-rc6+ #12
[   91.290487] Hardware name: LENOVO 7034DD7/        , BIOS 9HKT47AUS 01//2012
[   91.290488]  00000000 00000000 e9625ea0 c15ec49b f3461a00 e9625eb8 c15ea119 c17cbf18
[   91.290491]  ef084314 000019d0 f3461a00 e9625ed8 c110dc8a f3461a00 00000001 00000000
[   91.290494]  f3461a00 40000404 00000000 e9625ef8 c110dcc1 f3461a00 f3461a00 000019d0
[   91.290497] Call Trace:
[   91.290501]  [<c15ec49b>] dump_stack+0x41/0x52
[   91.290504]  [<c15ea119>] bad_page+0xcf/0xeb
[   91.290515]  [<c110dc8a>] free_pages_prepare+0x12a/0x140
[   91.290517]  [<c110dcc1>] free_hot_cold_page+0x21/0x110
[   91.290519]  [<c11123c1>] __put_single_page+0x21/0x30
[   91.290521]  [<c1112815>] put_page+0x25/0x40
[   91.290524]  [<c11544e7>] unpoison_memory+0x107/0x200
[   91.290526]  [<c104a537>] ? ns_capable+0x27/0x60
[   91.290528]  [<c1155720>] hwpoison_unpoison+0x20/0x30
[   91.290530]  [<c1178266>] simple_attr_write+0xb6/0xd0
[   91.290532]  [<c11781b0>] ? generic_fh_to_dentry+0x50/0x50
[   91.290535]  [<c1158c60>] vfs_write+0xa0/0x1b0
[   91.290537]  [<c11781b0>] ? generic_fh_to_dentry+0x50/0x50
[   91.290539]  [<c11590df>] SyS_write+0x4f/0x90
[   91.290549]  [<c15f9a81>] sysenter_do_call+0x12/0x22
[   91.290550] Disabling lock debugging due to kernel taint

Testcase:

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <errno.h>

#define PAGES_TO_TEST 1
#define PAGE_SIZE	4096

int main(void)
{
	char *mem;

	mem = mmap(NULL, PAGES_TO_TEST * PAGE_SIZE,
			PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);

	if (madvise(mem, PAGES_TO_TEST * PAGE_SIZE, MADV_HWPOISON) == -1)
		return -1;
	
	munmap(mem, PAGES_TO_TEST * PAGE_SIZE);

	return 0;
}

There is one page reference count for default empty zero page, madvise_hwpoison 
add another one by get_user_pages_fast. memory_hwpoison reduce one page reference 
count since it's a non LRU page. unpoison_memory release the last page reference 
count and free empty zero page to buddy system which is not correct since empty 
zero page has PG_reserved flag. This patch fix it by don't reduce the page 
reference count under 1 against empty zero page.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index fb687fd..be6b453 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1387,7 +1387,7 @@ int unpoison_memory(unsigned long pfn)
 	unlock_page(page);
 
 	put_page(page);
-	if (freeit)
+	if (freeit && !(pfn == my_zero_pfn(0) && page_count(p) == 1))
 		put_page(page);
 
 	return 0;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

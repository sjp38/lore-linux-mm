Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52F706B0033
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 10:56:28 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t184so1781763qke.0
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 07:56:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l88si10736qte.337.2017.09.22.07.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 07:56:26 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8MEtg4Q068226
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 10:56:25 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d54m9gc87-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 10:56:24 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Fri, 22 Sep 2017 10:56:23 -0400
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH] mm/device-public-memory: Fix edge case in _vm_normal_page()
Date: Fri, 22 Sep 2017 09:56:18 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <1506092178-20351-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

With device public pages at the end of my memory space, I'm getting
output from _vm_normal_page():

BUG: Bad page map in process migrate_pages  pte:c0800001ffff0d06 pmd:f95d3000
addr:00007fff89330000 vm_flags:00100073 anon_vma:c0000000fa899320 mapping:          (null) index:7fff8933
file:          (null) fault:          (null) mmap:          (null) readpage:          (null)
CPU: 0 PID: 13963 Comm: migrate_pages Tainted: P    B      OE 4.14.0-rc1-wip #155
Call Trace:
[c0000000f965f910] [c00000000094d55c] dump_stack+0xb0/0xf4 (unreliable)
[c0000000f965f950] [c0000000002b269c] print_bad_pte+0x28c/0x340
[c0000000f965fa00] [c0000000002b59c0] _vm_normal_page+0xc0/0x140
[c0000000f965fa20] [c0000000002b6e64] zap_pte_range+0x664/0xc10
[c0000000f965fb00] [c0000000002b7858] unmap_page_range+0x318/0x670
[c0000000f965fbd0] [c0000000002b8074] unmap_vmas+0x74/0xe0
[c0000000f965fc20] [c0000000002c4a18] exit_mmap+0xe8/0x1f0
[c0000000f965fce0] [c0000000000ecbdc] mmput+0xac/0x1f0
[c0000000f965fd10] [c0000000000f62e8] do_exit+0x348/0xcd0
[c0000000f965fdd0] [c0000000000f6d2c] do_group_exit+0x5c/0xf0
[c0000000f965fe10] [c0000000000f6ddc] SyS_exit_group+0x1c/0x20
[c0000000f965fe30] [c00000000000b184] system_call+0x58/0x6c

The pfn causing this is the very last one. Correct the bounds check
accordingly.

Fixes: df6ad69838fc ("mm/device-public-memory: device memory cache coherent with CPU")
Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index ec4e154..a728bed 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -845,7 +845,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		 * vm_normal_page() so that we do not have to special case all
 		 * call site of vm_normal_page().
 		 */
-		if (likely(pfn < highest_memmap_pfn)) {
+		if (likely(pfn <= highest_memmap_pfn)) {
 			struct page *page = pfn_to_page(pfn);
 
 			if (is_device_public_page(page)) {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

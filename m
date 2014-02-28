Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CE9A36B0072
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 00:28:29 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj1so278022pad.17
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 21:28:29 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id iy3si617652pbb.304.2014.02.27.21.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Feb 2014 21:28:28 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 28 Feb 2014 10:58:25 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id AD29DE0053
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 11:01:57 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1S5S4LJ59768898
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 10:58:04 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1S5SL3U022283
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 10:58:21 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2] mm: numa: bugfix for LAST_CPUPID_NOT_IN_PAGE_FLAGS
Date: Fri, 28 Feb 2014 10:58:12 +0530
Message-Id: <1393565292-13377-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <877g8fn8qw.fsf@linux.vnet.ibm.com>
References: <877g8fn8qw.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, akpm@linux-foundation.org, Peter Zijlstra <peterz@infradead.org>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Liu Ping Fan <qemulist@gmail.com>, Liu Ping Fan <pingfank@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: Liu Ping Fan <qemulist@gmail.com>

When doing some numa tests on powerpc, I triggered an oops bug. I find
it is caused by using page->_last_cpupid.  It should be initialized as
"-1 & LAST_CPUPID_MASK", but not "-1". Otherwise, in task_numa_fault(),
we will miss the checking (last_cpupid == (-1 & LAST_CPUPID_MASK)).
And finally cause an oops bug in task_numa_group(), since the online cpu is
less than possible cpu. This happen with CONFIG_SPARSE_VMEMMAP disabled

Call trace:
[   55.978091] SMP NR_CPUS=64 NUMA PowerNV
[   55.978118] Modules linked in:
[   55.978145] CPU: 24 PID: 804 Comm: systemd-udevd Not tainted3.13.0-rc1+ #32
[   55.978183] task: c000001e2746aa80 ti: c000001e32c50000 task.ti:c000001e32c50000
[   55.978219] NIP: c0000000000f5ad0 LR: c0000000000f5ac8 CTR:c000000000913cf0
[   55.978256] REGS: c000001e32c53510 TRAP: 0300   Not tainted(3.13.0-rc1+)
[   55.978286] MSR: 9000000000009032 <SF,HV,EE,ME,IR,DR,RI>  CR:28024424  XER: 20000000
[   55.978380] CFAR: c000000000009324 DAR: 7265717569726857 DSISR:40000000 SOFTE: 1
GPR00: c0000000000f5ac8 c000001e32c53790 c000000001f343380000000000000021
GPR04: 0000000000000000 0000000000000031 c000000001f743380000ffffffffffff
GPR08: 0000000000000001 7265717569726573 00000000000000000000000000000000
GPR12: 0000000028024422 c00000000ffdd800 00000000296b2e640000000000000020
GPR16: 0000000000000002 0000000000000003 c000001e2f8e4658c000001e25c1c1d8
GPR20: c000001e2f8e4000 c000000001f7a858 00000000000006580000000040000392
GPR24: 00000000000000a8 c000001e33c1a400 00000000000001d8c000001e25c1c000
GPR28: c000001e33c37ff0 0007837840000392 000000000000003fc000001e32c53790
[   55.978903] NIP [c0000000000f5ad0] .task_numa_fault+0x1470/0x2370
[   55.978934] LR [c0000000000f5ac8] .task_numa_fault+0x1468/0x2370
[   55.978964] Call Trace:
[   55.978978] [c000001e32c53790] [c0000000000f5ac8].task_numa_fault+0x1468/0x2370 (unreliable)
[   55.979036] [c000001e32c539e0] [c00000000020a820].do_numa_page+0x480/0x4a0
[   55.979072] [c000001e32c53b10] [c00000000020bfec].handle_mm_fault+0x4ec/0xc90
[   55.979123] [c000001e32c53c00] [c000000000e88c98].do_page_fault+0x3a8/0x890
[   55.979161] [c000001e32c53e30] [c000000000009568]handle_page_fault+0x10/0x30
[   55.979197] Instruction dump:
[   55.979216] 3c82fefb 3884b138 48d9cff1 60000000 48000574 3c62fefb3863af78 3c82fefb
[   55.979277] 3884b138 48d9cfd5 60000000 e93f0100 <812902e4> 7d2907b45529063e 7d2a07b4
[   55.979354] ---[ end trace 15f2510da5ae07cf ]---

Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46eade6a..1a0ea24ff972 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -766,7 +766,7 @@ static inline int page_cpupid_last(struct page *page)
 }
 static inline void page_cpupid_reset_last(struct page *page)
 {
-	page->_last_cpupid = -1;
+	page->_last_cpupid = -1 & LAST_CPUPID_MASK;
 }
 #else
 static inline int page_cpupid_last(struct page *page)
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

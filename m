Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8AB6B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:10:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w5so3198496pgt.4
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:10:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 59si654496ple.24.2017.12.13.21.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 21:10:28 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBE58s69066081
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:10:28 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2euf58quj3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:10:27 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 14 Dec 2017 05:10:26 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/mprotect: Add a cond_resched() inside change_pte_range()
Date: Thu, 14 Dec 2017 10:40:21 +0530
Message-Id: <20171214051021.20880-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mhocko@suse.com

While testing on a large CPU system, detected the following RCU
stall many times over the span of the workload. This problem
is solved by adding a cond_resched() in the change_pte_range()
function.

[  850.962530] INFO: rcu_sched detected stalls on CPUs/tasks:
[  850.962584]  154-....: (670 ticks this GP) idle=022/140000000000000/0 softirq=2825/2825 fqs=612
[  850.962605]  (detected by 955, t=6002 jiffies, g=4486, c=4485, q=90864)
[  850.962895] Sending NMI from CPU 955 to CPUs 154:
[  850.992667] NMI backtrace for cpu 154
[  850.993069] CPU: 154 PID: 147071 Comm: workload Not tainted 4.15.0-rc3+ #3
[  850.993258] NIP:  c0000000000b3f64 LR: c0000000000b33d4 CTR: 000000000000aa18
[  850.993503] REGS: 00000000a4b0fb44 TRAP: 0501   Not tainted  (4.15.0-rc3+)
[  850.993707] MSR:  8000000000009033 <SF,EE,ME,IR,DR,RI,LE>  CR: 22422082  XER: 00000000
[  850.994386] CFAR: 00000000006cf8f0 SOFTE: 1
GPR00: 0010000000000000 c00003ef9b1cb8c0 c0000000010cc600 0000000000000000
GPR04: 8e0000018c32b200 40017b3858fd6e00 8e0000018c32b208 40017b3858fd6e00
GPR08: 8e0000018c32b210 40017b3858fd6e00 8e0000018c32b218 40017b3858fd6e00
GPR12: ffffffffffffffff c00000000fb25100
[  850.995976] NIP [c0000000000b3f64] plpar_hcall9+0x44/0x7c
[  850.996174] LR [c0000000000b33d4] pSeries_lpar_flush_hash_range+0x384/0x420
[  850.996401] Call Trace:
[  850.996600] [c00003ef9b1cb8c0] [c00003fa8fff7d40] 0xc00003fa8fff7d40 (unreliable)
[  850.996959] [c00003ef9b1cba40] [c0000000000688a8] flush_hash_range+0x48/0x100
[  850.997261] [c00003ef9b1cba90] [c000000000071b14] __flush_tlb_pending+0x44/0xd0
[  850.997600] [c00003ef9b1cbac0] [c000000000071fa8] hpte_need_flush+0x408/0x470
[  850.997958] [c00003ef9b1cbb30] [c0000000002c646c] change_protection_range+0xaac/0xf10
[  850.998180] [c00003ef9b1cbcb0] [c0000000002f2510] change_prot_numa+0x30/0xb0
[  850.998502] [c00003ef9b1cbce0] [c00000000013a950] task_numa_work+0x2d0/0x3e0
[  850.998816] [c00003ef9b1cbda0] [c00000000011ea30] task_work_run+0x130/0x190
[  850.999121] [c00003ef9b1cbe00] [c00000000001bcd8] do_notify_resume+0x118/0x120
[  850.999421] [c00003ef9b1cbe30] [c00000000000b744] ret_from_except_lite+0x70/0x74
[  850.999716] Instruction dump:
[  850.999959] 60000000 f8810028 7ca42b78 7cc53378 7ce63b78 7d074378 7d284b78 7d495378
[  851.000575] e9410060 e9610068 e9810070 44000022 <7d806378> e9810028 f88c0000 f8ac0008

Suggested-by: Nicholas Piggin <npiggin@gmail.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/mprotect.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index ec39f73..4fce0f5 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -144,6 +144,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
 
 	return pages;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

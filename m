Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 725718E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:19:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id t26so12558070pgu.18
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 05:19:11 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id m35si324534pgb.246.2019.01.14.05.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 05:19:09 -0800 (PST)
Subject: Re: [PATCH v11 00/26] Speculative page faults
From: Vinayak Menon <vinmenon@codeaurora.org>
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
Message-ID: <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
Date: Mon, 14 Jan 2019 18:49:04 +0530
MIME-Version: 1.0
In-Reply-To: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ldufour@linux.vnet.ibm.com
Cc: Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org

On 1/11/2019 9:13 PM, Vinayak Menon wrote:
> Hi Laurent,
>
> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).


With the patch below, we don't hit the issue.

From: Vinayak Menon <vinmenon@codeaurora.org>
Date: Mon, 14 Jan 2019 16:06:34 +0530
Subject: [PATCH] mm: flush stale tlb entries on speculative write fault

It is observed that the following scenario results in
threads A and B of process 1 blocking on pthread_mutex_lock
forever after few iterations.

CPU 1                   CPU 2                    CPU 3
Process 1,              Process 1,               Process 1,
Thread A                Thread B                 Thread C

while (1) {             while (1) {              while(1) {
pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
}                       }

When from thread C, copy_one_pte write-protects the parent pte
(of lock l), stale tlb entries can exist with write permissions
on one of the CPUs at least. This can create a problem if one
of the threads A or B hits the write fault. Though dup_mmap calls
flush_tlb_mm after copy_page_range, since speculative page fault
does not take mmap_sem it can proceed further fixing a fault soon
after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
entry can still modify old_page even after it is copied to
new_page by wp_page_copy, thus causing a corruption.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/memory.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 52080e4..1ea168ff 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
                return VM_FAULT_RETRY;
        }

+       /*
+        * Discard tlb entries created before ptep_set_wrprotect
+        * in copy_one_pte
+        */
+       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
+               flush_tlb_page(vmf.vma, address);
+
        mem_cgroup_oom_enable();
        ret = handle_pte_fault(&vmf);
        mem_cgroup_oom_disable();
--
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

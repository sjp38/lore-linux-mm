Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 525016B04C4
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r23-v6so2862579wrc.2
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:07:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h9-v6si5105614edk.225.2018.05.17.04.07.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 04:07:42 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4HB4aKK057666
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:40 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j17yf1taf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:40 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 May 2018 12:07:38 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v11 23/26] mm: add speculative page fault vmstats
Date: Thu, 17 May 2018 13:06:30 +0200
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1526555193-7242-24-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Add speculative_pgfault vmstat counter to count successful speculative page
fault handling.

Also fixing a minor typo in include/linux/vm_event_item.h.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/vm_event_item.h | 3 +++
 mm/memory.c                   | 3 +++
 mm/vmstat.c                   | 5 ++++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 5c7f010676a7..a240acc09684 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -111,6 +111,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		SWAP_RA,
 		SWAP_RA_HIT,
 #endif
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+		SPECULATIVE_PGFAULT,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/mm/memory.c b/mm/memory.c
index 30433bde32f2..48e1cf0a54ef 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4509,6 +4509,9 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 
 	put_vma(vma);
 
+	if (ret != VM_FAULT_RETRY)
+		count_vm_event(SPECULATIVE_PGFAULT);
+
 	/*
 	 * The task may have entered a memcg OOM situation but
 	 * if the allocation error was handled gracefully (no
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a2b9518980ce..3af74498a969 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1289,7 +1289,10 @@ const char * const vmstat_text[] = {
 	"swap_ra",
 	"swap_ra_hit",
 #endif
-#endif /* CONFIG_VM_EVENTS_COUNTERS */
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	"speculative_pgfault",
+#endif
+#endif /* CONFIG_VM_EVENT_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
 
-- 
2.7.4

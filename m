Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAiRVt031252
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:44:27 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAlhAI285498
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:47:43 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhrxh010349
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:53 +1000
Message-Id: <20071022104531.555501453@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:27 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 8/9] debug: instrument the fault path
Content-Disposition: inline; filename=8_stats.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

---
 arch/x86_64/mm/fault.c |    8 ++++++++
 include/linux/vmstat.h |    1 +
 mm/vmstat.c            |    5 +++++
 3 files changed, 14 insertions(+)

--- linux-2.6.23-rc6.orig/arch/x86_64/mm/fault.c
+++ linux-2.6.23-rc6/arch/x86_64/mm/fault.c
@@ -25,6 +25,7 @@
 #include <linux/kprobes.h>
 #include <linux/uaccess.h>
 #include <linux/kdebug.h>
+#include <linux/vmstat.h>
 
 #include <asm/system.h>
 #include <asm/pgalloc.h>
@@ -393,10 +394,16 @@ asmlinkage void __kprobes do_page_fault(
 
 	if (likely(!locked)) {
 		vma = __find_get_vma(mm, address, &locked);
+		if (unlikely(locked))
+			count_vm_event(FAULT_RCU_SLOW);
+		else
+			count_vm_event(FAULT_RCU);
+
 	} else {
 		down_read(&mm->mmap_sem);
 		vma = find_vma(mm, address);
 		get_vma(vma);
+		count_vm_event(FAULT_LOCKED);
 	}
 	if (!vma)
 		goto bad_area;
@@ -416,6 +423,7 @@ asmlinkage void __kprobes do_page_fault(
 		locked = 1;
 		goto again;
 	}
+	count_vm_event(FAULT_STACK);
 	if (expand_stack(vma, address))
 		goto bad_area;
 /*
--- linux-2.6.23-rc6.orig/include/linux/vmstat.h
+++ linux-2.6.23-rc6/include/linux/vmstat.h
@@ -37,6 +37,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		FAULT_RCU, FAULT_RCU_SLOW, FAULT_LOCKED, FAULT_STACK,
 		NR_VM_EVENT_ITEMS
 };
 
--- linux-2.6.23-rc6.orig/mm/vmstat.c
+++ linux-2.6.23-rc6/mm/vmstat.c
@@ -529,6 +529,11 @@ static const char * const vmstat_text[] 
 	"allocstall",
 
 	"pgrotated",
+
+	"fault_rcu",
+	"fault_rcu_slow",
+	"fault_locked",
+	"fault_stack",
 #endif
 };
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

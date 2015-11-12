Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 36A386B0253
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 02:15:24 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so56356455pac.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:15:24 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id di4si18084755pbc.31.2015.11.11.23.15.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 23:15:23 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so56355936pac.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:15:22 -0800 (PST)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH V3] mm: fix kernel crash in khugepaged thread
Date: Thu, 12 Nov 2015 15:15:00 +0800
Message-Id: <1447312500-1210-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rostedt@goodmis.org, mingo@redhat.com, akpm@linux-foundation.org, riel@redhat.com, ebru.akagunduz@gmail.com, kirill.shutemov@linux.intel.com, yalin.wang2010@gmail.com, vbabka@suse.cz, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This crash is caused by NULL pointer deference, in page_to_pfn() marco,
when page == NULL :

[  182.639154 ] Unable to handle kernel NULL pointer dereference at virtual address 00000000
[  182.639491 ] pgd = ffffffc00077a000
[  182.639761 ] [00000000] *pgd=00000000b9422003, *pud=00000000b9422003, *pmd=00000000b9423003, *pte=0060000008000707
[  182.640749 ] Internal error: Oops: 94000006 [#1] SMP
[  182.641197 ] Modules linked in:
[  182.641580 ] CPU: 1 PID: 26 Comm: khugepaged Tainted: G        W       4.3.0-rc6-next-20151022ajb-00001-g32f3386-dirty #3
[  182.642077 ] Hardware name: linux,dummy-virt (DT)
[  182.642227 ] task: ffffffc07957c080 ti: ffffffc079638000 task.ti: ffffffc079638000
[  182.642598 ] PC is at khugepaged+0x378/0x1af8
[  182.642826 ] LR is at khugepaged+0x418/0x1af8
[  182.643047 ] pc : [<ffffffc0001980ac>] lr : [<ffffffc00019814c>] pstate: 60000145
[  182.643490 ] sp : ffffffc07963bca0
[  182.643650 ] x29: ffffffc07963bca0 x28: ffffffc00075c000
[  182.644024 ] x27: ffffffc00f275040 x26: ffffffc0006c7000
[  182.644334 ] x25: 00e8000048800f51 x24: 0000000006400000
[  182.644687 ] x23: 0000000000000002 x22: 0000000000000000
[  182.644972 ] x21: 0000000000000000 x20: 0000000000000000
[  182.645446 ] x19: 0000000000000000 x18: 0000007ff86d0990
[  182.645931 ] x17: 00000000007ef9c8 x16: ffffffc000098390
[  182.646236 ] x15: ffffffffffffffff x14: 00000000ffffffff
[  182.646649 ] x13: 000000000000016a x12: 0000000000000000
[  182.647046 ] x11: ffffffc07f025020 x10: 0000000000000000
[  182.647395 ] x9 : 0000000000000048 x8 : ffffffc000721e28
[  182.647872 ] x7 : 0000000000000000 x6 : ffffffc07f02d000
[  182.648261 ] x5 : fffffffffffffe00 x4 : ffffffc00f275040
[  182.648611 ] x3 : 0000000000000000 x2 : ffffffc00f2ad000
[  182.648908 ] x1 : 0000000000000000 x0 : ffffffc000727000
[  182.649147 ]
[  182.649252 ] Process khugepaged (pid: 26, stack limit = 0xffffffc079638020)
[  182.649724 ] Stack: (0xffffffc07963bca0 to 0xffffffc07963c000)
[  182.650141 ] bca0: ffffffc07963be30 ffffffc0000b5044 ffffffc07961fb80 ffffffc00072e630
[  182.650587 ] bcc0: ffffffc0005d5090 0000000000000000 ffffffc000197d34 0000000000000000
[  182.651009 ] bce0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.651446 ] bd00: ffffffc07963bd90 ffffffc07f1cbf80 000000004f3be003 ffffffc00f2750a4
[  182.651956 ] bd20: ffffffc00f3bf000 ffffffc000000001 0000000000000001 ffffffc07f085740
[  182.652520 ] bd40: ffffffc00f2ad188 ffffffc000000000 0000000006200000 ffffffc00f275040
[  182.652972 ] bd60: ffffffc0006b1a90 ffffffc079638000 ffffffc07963be20 ffffffc00f0144d0
[  182.653357 ] bd80: ffffffc000000000 0000000006400000 ffffffc00f0144d0 00000a0800000001
[  182.653793 ] bda0: 0000100000000001 ffffffc000000001 ffffffc07f025000 ffffffc00f2750a8
[  182.654226 ] bdc0: 00000001000005f8 ffffffc00075a000 0000000006a00000 ffffffc000727000
[  182.654522 ] bde0: ffffffc0006e8478 ffffffc000000000 0000000100000000 ffffffc078fb9000
[  182.654869 ] be00: ffffffc07963be30 ffffffc000000000 ffffffc07957c080 ffffffc0000cfc4c
[  182.655225 ] be20: ffffffc07963be20 ffffffc07963be20 0000000000000000 ffffffc000085c50
[  182.655588 ] be40: ffffffc0000b4f64 ffffffc07961fb80 0000000000000000 0000000000000000
[  182.656138 ] be60: 0000000000000000 ffffffc0000bee2c ffffffc0000b4f64 0000000000000000
[  182.656609 ] be80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.657145 ] bea0: ffffffc07963bea0 ffffffc07963bea0 0000000000000000 ffffffc000000000
[  182.657475 ] bec0: ffffffc07963bec0 ffffffc07963bec0 0000000000000000 0000000000000000
[  182.657922 ] bee0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.658558 ] bf00: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.658972 ] bf20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.659291 ] bf40: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.659722 ] bf60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.660122 ] bf80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.660654 ] bfa0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.661064 ] bfc0: 0000000000000000 0000000000000000 0000000000000000 0000000000000005
[  182.661466 ] bfe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  182.661848 ] Call trace:
[  182.662050 ] [<ffffffc0001980ac>] khugepaged+0x378/0x1af8
[  182.662294 ] [<ffffffc0000b5040>] kthread+0xdc/0xf4
[  182.662605 ] [<ffffffc000085c4c>] ret_from_fork+0xc/0x40
[  182.663046 ] Code: 35001700 f0002c60 aa0703e3 f9009fa0 (f94000e0)
[  182.663901 ] ---[ end trace 637503d8e28ae69e  ]---
[  182.664160 ] Kernel panic - not syncing: Fatal exception
[  182.664571 ] CPU2: stopping
[  182.664794 ] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G      D W       4.3.0-rc6-next-20151022ajb-00001-g32f3386-dirty #3
[  182.665248 ] Hardware name: linux,dummy-virt (DT)

add the trace point with TP_CONDITION(page),
avoid trace NULL page.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 include/trace/events/huge_memory.h | 10 ++++++----
 mm/huge_memory.c                   |  2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index 11c59ca..369d912 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -45,12 +45,14 @@ SCAN_STATUS
 #define EM(a, b)	{a, b},
 #define EMe(a, b)	{a, b}
 
-TRACE_EVENT(mm_khugepaged_scan_pmd,
+TRACE_EVENT_CONDITION(mm_khugepaged_scan_pmd,
 
-	TP_PROTO(struct mm_struct *mm, unsigned long pfn, bool writable,
+	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
 		 bool referenced, int none_or_zero, int status, int unmapped),
 
-	TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status, unmapped),
+	TP_ARGS(mm, page, writable, referenced, none_or_zero, status, unmapped),
+
+	TP_CONDITION(page),
 
 	TP_STRUCT__entry(
 		__field(struct mm_struct *, mm)
@@ -64,7 +66,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 
 	TP_fast_assign(
 		__entry->mm = mm;
-		__entry->pfn = pfn;
+		__entry->pfn = page_to_pfn(page);
 		__entry->writable = writable;
 		__entry->referenced = referenced;
 		__entry->none_or_zero = none_or_zero;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 67b00a1..ff2b105 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2530,7 +2530,7 @@ out_unmap:
 		collapse_huge_page(mm, address, hpage, vma, node);
 	}
 out:
-	trace_mm_khugepaged_scan_pmd(mm, page_to_pfn(page), writable, referenced,
+	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
 				     none_or_zero, result, unmapped);
 	return ret;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

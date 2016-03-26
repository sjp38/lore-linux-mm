Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 97E436B025E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 12:42:59 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id td3so101692073pab.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 09:42:59 -0700 (PDT)
Received: from smtp-outbound-2.vmware.com (smtp-outbound-2.vmware.com. [208.91.2.13])
        by mx.google.com with ESMTPS id lq6si24623814pab.140.2016.03.28.09.42.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Mar 2016 09:42:56 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v2 1/2] x86/mm: TLB_REMOTE_SEND_IPI should count pages
Date: Sat, 26 Mar 2016 01:25:04 -0700
Message-Id: <1458980705-121507-2-git-send-email-namit@vmware.com>
In-Reply-To: <1458980705-121507-1-git-send-email-namit@vmware.com>
References: <1458980705-121507-1-git-send-email-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, mgorman@suse.de, sasha.levin@oracle.com, akpm@linux-foundation.org, namit@vmware.com, riel@redhat.com, dave.hansen@linux.intel.com, luto@kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, hughd@google.com, vdavydov@virtuozzo.com, minchan@kernel.org, linux-kernel@vger.kernel.org

TLB_REMOTE_SEND_IPI was recently introduced, but it counts bytes instead
of pages. In addition, it does not report correctly the case in which
flush_tlb_page flushes a page. Fix it to be consistent with other TLB
counters.

Fixes: 4595f9620cda8a1e973588e743cf5f8436dd20c6

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/x86/mm/tlb.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 8f4cc3d..5fb6ada 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -106,8 +106,6 @@ static void flush_tlb_func(void *info)
 
 	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
 		return;
-	if (!f->flush_end)
-		f->flush_end = f->flush_start + PAGE_SIZE;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
@@ -135,12 +133,20 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 				 unsigned long end)
 {
 	struct flush_tlb_info info;
+
+	if (end == 0)
+		end = start + PAGE_SIZE;
 	info.flush_mm = mm;
 	info.flush_start = start;
 	info.flush_end = end;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
-	trace_tlb_flush(TLB_REMOTE_SEND_IPI, end - start);
+	if (end == TLB_FLUSH_ALL)
+		trace_tlb_flush(TLB_REMOTE_SEND_IPI, TLB_FLUSH_ALL);
+	else
+		trace_tlb_flush(TLB_REMOTE_SEND_IPI,
+				(end - start) >> PAGE_SHIFT);
+
 	if (is_uv_system()) {
 		unsigned int cpu;
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

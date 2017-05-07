Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2A276B0390
	for <linux-mm@kvack.org>; Sun,  7 May 2017 08:38:56 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s62so47390571pgc.2
        for <linux-mm@kvack.org>; Sun, 07 May 2017 05:38:56 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id v71si7061656pgd.186.2017.05.07.05.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 05:38:55 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 02/10] x86/mm: Reduce indentation in flush_tlb_func()
Date: Sun,  7 May 2017 05:38:31 -0700
Message-Id: <210e32be00774ecdb93a1f56dad3cd7a400fd5a5.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>

The leave_mm() case can just exit the function early so we don't
need to indent the entire remainder of the function.

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index fe6471132ea3..4d303864b310 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -237,24 +237,26 @@ static void flush_tlb_func(void *info)
 		return;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
-	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
-		if (f->flush_end == TLB_FLUSH_ALL) {
-			local_flush_tlb();
-			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
-		} else {
-			unsigned long addr;
-			unsigned long nr_pages =
-				(f->flush_end - f->flush_start) / PAGE_SIZE;
-			addr = f->flush_start;
-			while (addr < f->flush_end) {
-				__flush_tlb_single(addr);
-				addr += PAGE_SIZE;
-			}
-			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, nr_pages);
-		}
-	} else
+
+	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
 		leave_mm(smp_processor_id());
+		return;
+	}
 
+	if (f->flush_end == TLB_FLUSH_ALL) {
+		local_flush_tlb();
+		trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
+	} else {
+		unsigned long addr;
+		unsigned long nr_pages =
+			(f->flush_end - f->flush_start) / PAGE_SIZE;
+		addr = f->flush_start;
+		while (addr < f->flush_end) {
+			__flush_tlb_single(addr);
+			addr += PAGE_SIZE;
+		}
+		trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, nr_pages);
+	}
 }
 
 void native_flush_tlb_others(const struct cpumask *cpumask,
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

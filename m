Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id F068C6B02C3
	for <linux-mm@kvack.org>; Mon, 22 May 2017 18:30:20 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id m2so111680374oik.4
        for <linux-mm@kvack.org>; Mon, 22 May 2017 15:30:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w65si8053163oia.58.2017.05.22.15.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 15:30:20 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 02/11] x86/mm: Reduce indentation in flush_tlb_func()
Date: Mon, 22 May 2017 15:30:02 -0700
Message-Id: <97901ddcc9821d7bc7b296d2918d1179f08aaf22.1495492063.git.luto@kernel.org>
In-Reply-To: <cover.1495492063.git.luto@kernel.org>
References: <cover.1495492063.git.luto@kernel.org>
In-Reply-To: <cover.1495492063.git.luto@kernel.org>
References: <cover.1495492063.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>

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

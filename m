Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D272C6B02FD
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:48:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n188so257027261oig.3
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:48:01 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z131si9579976oia.75.2017.05.25.17.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:48:01 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 7/8] x86/mm: Be more consistent wrt PAGE_SHIFT vs PAGE_SIZE in tlb flush code
Date: Thu, 25 May 2017 17:47:51 -0700
Message-Id: <1b177a9f0af93eda660f57614ce31c2d0dc844db.1495759610.git.luto@kernel.org>
In-Reply-To: <cover.1495759610.git.luto@kernel.org>
References: <cover.1495759610.git.luto@kernel.org>
In-Reply-To: <cover.1495759610.git.luto@kernel.org>
References: <cover.1495759610.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

Nadav pointed out that some code used PAGE_SIZE and other code used
PAGE_SHIFT.  Use PAGE_SHIFT instead of multiplying or dividing by
PAGE_SIZE.

Requested-by: Nadav Amit <nadav.amit@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 4bfadb869a1e..4bcec510174c 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -220,8 +220,7 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 		trace_tlb_flush(reason, TLB_FLUSH_ALL);
 	} else {
 		unsigned long addr;
-		unsigned long nr_pages =
-			(f->end - f->start) / PAGE_SIZE;
+		unsigned long nr_pages = (f->end - f->start) >> PAGE_SHIFT;
 		addr = f->start;
 		while (addr < f->end) {
 			__flush_tlb_single(addr);
@@ -351,7 +350,7 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 
 	/* Balance as user space task's flush, a bit conservative */
 	if (end == TLB_FLUSH_ALL ||
-	    (end - start) > tlb_single_page_flush_ceiling * PAGE_SIZE) {
+	    (end - start) > tlb_single_page_flush_ceiling << PAGE_SHIFT) {
 		on_each_cpu(do_flush_tlb_all, NULL, 1);
 	} else {
 		struct flush_tlb_info info;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

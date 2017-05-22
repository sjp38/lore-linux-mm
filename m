Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB8A6B0315
	for <linux-mm@kvack.org>; Mon, 22 May 2017 18:30:33 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o65so174461559oif.15
        for <linux-mm@kvack.org>; Mon, 22 May 2017 15:30:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h54si57433ote.269.2017.05.22.15.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 15:30:32 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 10/11] x86/mm: Be more consistent wrt PAGE_SHIFT vs PAGE_SIZE in tlb flush code
Date: Mon, 22 May 2017 15:30:10 -0700
Message-Id: <29e74164b213b349fd9c4bc1bec5e154af38ac87.1495492063.git.luto@kernel.org>
In-Reply-To: <cover.1495492063.git.luto@kernel.org>
References: <cover.1495492063.git.luto@kernel.org>
In-Reply-To: <cover.1495492063.git.luto@kernel.org>
References: <cover.1495492063.git.luto@kernel.org>
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
index 4bfadb869a1e..20659edd9347 100644
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
+	    (end - start) > tlb_single_page_flush_ceiling >> PAGE_SHIFT) {
 		on_each_cpu(do_flush_tlb_all, NULL, 1);
 	} else {
 		struct flush_tlb_info info;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

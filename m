Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3B16B02F3
	for <linux-mm@kvack.org>; Sun, 28 May 2017 13:02:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h4so51845800oib.5
        for <linux-mm@kvack.org>; Sun, 28 May 2017 10:02:52 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p82si2877920oif.7.2017.05.28.10.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 May 2017 10:02:51 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 7/8] x86/mm: Be more consistent wrt PAGE_SHIFT vs PAGE_SIZE in tlb flush code
Date: Sun, 28 May 2017 10:00:16 -0700
Message-Id: <9454d1913cdda2b6adbf1f14eb99281d4f1716e5.1495990440.git.luto@kernel.org>
In-Reply-To: <cover.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
In-Reply-To: <cover.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

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
index 44db82013f1c..2a5e851f2035 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

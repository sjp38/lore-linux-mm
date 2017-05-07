Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC38F6B03A2
	for <linux-mm@kvack.org>; Sun,  7 May 2017 08:39:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f5so42726232pff.13
        for <linux-mm@kvack.org>; Sun, 07 May 2017 05:39:10 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id c188si10495413pfc.54.2017.05.07.05.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 05:39:10 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 05/10] x86/mm: Change the leave_mm() condition for local TLB flushes
Date: Sun,  7 May 2017 05:38:34 -0700
Message-Id: <21008c912205b477c002c06bf385fd8dad52c451.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On a remote TLB flush, we leave_mm() if we're TLBSTATE_LAZY.  For a
local flush_tlb_mm_range(), we leave_mm() if !current->mm.  These
are approximately the same condition -- the scheduler sets lazy TLB
mode when switching to a thread with no mm.

I'm about to merge the local and remote flush code, but for ease of
verifying and bisecting the patch, I want the local and remote flush
behavior to match first.  This patch changes the local code to match
the remote code.

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 776469cc54e0..3143c9a180e5 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -311,7 +311,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		goto out;
 	}
 
-	if (!current->mm) {
+	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
 		leave_mm(smp_processor_id());
 
 		/* Synchronize with switch_mm. */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

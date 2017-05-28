Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 508C46B02F3
	for <linux-mm@kvack.org>; Sun, 28 May 2017 13:01:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h4so51771713oib.5
        for <linux-mm@kvack.org>; Sun, 28 May 2017 10:01:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t205si2880830oie.236.2017.05.28.10.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 May 2017 10:01:38 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 2/8] x86/mm: Change the leave_mm() condition for local TLB flushes
Date: Sun, 28 May 2017 10:00:11 -0700
Message-Id: <61de238db6d9c9018db020c41047ce32dac64488.1495990440.git.luto@kernel.org>
In-Reply-To: <cover.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
In-Reply-To: <cover.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

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

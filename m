Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A7BE16B0103
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:19:04 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so17223527pdb.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:19:04 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id kv16si26164444pab.207.2015.05.27.07.19.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 07:19:03 -0700 (PDT)
Date: Wed, 27 May 2015 07:18:13 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-7f0431e3dc8953f41e9433581c1fdd7ee45860b0@git.kernel.org>
Reply-To: peterz@infradead.org, dvlasenk@redhat.com, tglx@linutronix.de,
        mingo@kernel.org, luto@amacapital.net, toshi.kani@hp.com,
        torvalds@linux-foundation.org, bp@suse.de, linux-mm@kvack.org,
        brgerst@gmail.com, hpa@zytor.com, akpm@linux-foundation.org,
        mcgrof@suse.com, linux-kernel@vger.kernel.org, bp@alien8.de
In-Reply-To: <1432628901-18044-3-git-send-email-bp@alien8.de>
References: <1431714237-880-3-git-send-email-toshi.kani@hp.com>
	<1432628901-18044-3-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/mtrr:
  Fix MTRR lookup to handle an inclusive entry
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@kernel.org, tglx@linutronix.de, dvlasenk@redhat.com, peterz@infradead.org, bp@suse.de, luto@amacapital.net, torvalds@linux-foundation.org, toshi.kani@hp.com, akpm@linux-foundation.org, mcgrof@suse.com, hpa@zytor.com, brgerst@gmail.com, linux-mm@kvack.org, bp@alien8.de, linux-kernel@vger.kernel.org

Commit-ID:  7f0431e3dc8953f41e9433581c1fdd7ee45860b0
Gitweb:     http://git.kernel.org/tip/7f0431e3dc8953f41e9433581c1fdd7ee45860b0
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Tue, 26 May 2015 10:28:05 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Wed, 27 May 2015 14:40:56 +0200

x86/mm/mtrr: Fix MTRR lookup to handle an inclusive entry

When an MTRR entry is inclusive to a requested range, i.e. the
start and end of the request are not within the MTRR entry range
but the range contains the MTRR entry entirely:

  range_start ... [mtrr_start ... mtrr_end] ... range_end

__mtrr_type_lookup() ignores such a case because both
start_state and end_state are set to zero.

This bug can cause the following issues:

1) reserve_memtype() tracks an effective memory type in case
   a request type is WB (ex. /dev/mem blindly uses WB). Missing
   to track with its effective type causes a subsequent request
   to map the same range with the effective type to fail.

2) pud_set_huge() and pmd_set_huge() check if a requested range
   has any overlap with MTRRs. Missing to detect an overlap may
   cause a performance penalty or undefined behavior.

This patch fixes the bug by adding a new flag, 'inclusive',
to detect the inclusive case.  This case is then handled in
the same way as end_state:1 since the first region is the same.
With this fix, __mtrr_type_lookup() handles the inclusive case
properly.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: dave.hansen@intel.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: pebolle@tiscali.nl
Link: http://lkml.kernel.org/r/1431714237-880-3-git-send-email-toshi.kani@hp.com
Link: http://lkml.kernel.org/r/1432628901-18044-3-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/generic.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index 5b23967..e202d26 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -154,7 +154,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
 	prev_match = 0xFF;
 	for (i = 0; i < num_var_ranges; ++i) {
-		unsigned short start_state, end_state;
+		unsigned short start_state, end_state, inclusive;
 
 		if (!(mtrr_state.var_ranges[i].mask_lo & (1 << 11)))
 			continue;
@@ -166,19 +166,27 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 
 		start_state = ((start & mask) == (base & mask));
 		end_state = ((end & mask) == (base & mask));
+		inclusive = ((start < base) && (end > base));
 
-		if (start_state != end_state) {
+		if ((start_state != end_state) || inclusive) {
 			/*
 			 * We have start:end spanning across an MTRR.
-			 * We split the region into
-			 * either
-			 * (start:mtrr_end) (mtrr_end:end)
-			 * or
-			 * (start:mtrr_start) (mtrr_start:end)
+			 * We split the region into either
+			 *
+			 * - start_state:1
+			 * (start:mtrr_end)(mtrr_end:end)
+			 * - end_state:1
+			 * (start:mtrr_start)(mtrr_start:end)
+			 * - inclusive:1
+			 * (start:mtrr_start)(mtrr_start:mtrr_end)(mtrr_end:end)
+			 *
 			 * depending on kind of overlap.
-			 * Return the type for first region and a pointer to
-			 * the start of second region so that caller will
-			 * lookup again on the second region.
+			 *
+			 * Return the type of the first region and a pointer
+			 * to the start of next region so that caller will be
+			 * advised to lookup again after having adjusted start
+			 * and end.
+			 *
 			 * Note: This way we handle multiple overlaps as well.
 			 */
 			if (start_state)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

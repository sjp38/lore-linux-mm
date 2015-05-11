Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 99A4D6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 08:47:06 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so109345528pac.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 05:47:06 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id z2si10620022par.230.2015.05.11.05.47.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 05:47:05 -0700 (PDT)
Date: Mon, 11 May 2015 05:46:14 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-cd2f6a5a4704a359635eb34919317052e6a96ba7@git.kernel.org>
Reply-To: bp@suse.de, toshi.kani@hp.com, linux-kernel@vger.kernel.org,
        brgerst@gmail.com, hpa@zytor.com, peterz@infradead.org,
        torvalds@linux-foundation.org, mcgrof@suse.com, dvlasenk@redhat.com,
        akpm@linux-foundation.org, mingo@kernel.org, luto@amacapital.net,
        bp@alien8.de, tglx@linutronix.de, linux-mm@kvack.org
In-Reply-To: <1431332153-18566-8-git-send-email-bp@alien8.de>
References: <1427234921-19737-4-git-send-email-toshi.kani@hp.com>
	<1431332153-18566-8-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/mtrr:
  Remove incorrect address check in __mtrr_type_lookup()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: brgerst@gmail.com, linux-kernel@vger.kernel.org, bp@suse.de, toshi.kani@hp.com, hpa@zytor.com, peterz@infradead.org, akpm@linux-foundation.org, dvlasenk@redhat.com, mcgrof@suse.com, torvalds@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, tglx@linutronix.de, luto@amacapital.net, mingo@kernel.org

Commit-ID:  cd2f6a5a4704a359635eb34919317052e6a96ba7
Gitweb:     http://git.kernel.org/tip/cd2f6a5a4704a359635eb34919317052e6a96ba7
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Mon, 11 May 2015 10:15:52 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Mon, 11 May 2015 10:38:44 +0200

x86/mm/mtrr: Remove incorrect address check in __mtrr_type_lookup()

__mtrr_type_lookup() checks MTRR fixed ranges when mtrr_state.have_fixed
is set and start is less than 0x100000.

However, the 'else if (start < 0x1000000)' in the code checks with an
incorrect address as it has an extra-zero in the address.

The code still runs correctly as this check is meaningless, though.

This patch replaces the incorrect address check with 'else' with no
condition.

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
Link: http://lkml.kernel.org/r/1427234921-19737-4-git-send-email-toshi.kani@hp.com
Link: http://lkml.kernel.org/r/1431332153-18566-8-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index 7d74f7b..5b23967 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -137,7 +137,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
 			idx = 1 * 8;
 			idx += ((start - 0x80000) >> 14);
 			return mtrr_state.fixed_ranges[idx];
-		} else if (start < 0x1000000) {
+		} else {
 			idx = 3 * 8;
 			idx += ((start - 0xC0000) >> 12);
 			return mtrr_state.fixed_ranges[idx];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

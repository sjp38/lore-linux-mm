Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id BC3CB6B0070
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:27:51 -0400 (EDT)
Received: by obdfc2 with SMTP id fc2so5740758obd.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:27:51 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id d84si365344oif.24.2015.03.24.15.27.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:27:51 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 3/7] mtrr, x86: Remove a wrong address check in __mtrr_type_lookup()
Date: Tue, 24 Mar 2015 16:08:37 -0600
Message-Id: <1427234921-19737-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

__mtrr_type_lookup() checks MTRR fixed ranges when
mtrr_state.have_fixed is set and start is less than
0x100000.  However, the 'else if (start < 0x1000000)'
in the code checks with a wrong address as it has
an extra-zero in the address.  The code still runs
correctly as this check is meaningless, though.

This patch replaces the wrong address check with 'else'
with no condition.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/kernel/cpu/mtrr/generic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index a82e370..c5be327 100644
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

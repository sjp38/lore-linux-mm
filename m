Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 10517828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:50:59 -0500 (EST)
Received: by mail-lf0-f47.google.com with SMTP id 17so10407979lfz.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:50:59 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id th5si68987388lbb.36.2016.01.11.04.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 04:50:57 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/2] x86/kasan: write protect kasan zero shadow
Date: Mon, 11 Jan 2016 15:51:19 +0300
Message-ID: <1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
References: <20160110185916.GD22896@pd.tnic>
 <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

After kasan_init() executed, no one is allowed to write to kasan_zero_page,
so write protect it.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 arch/x86/mm/kasan_init_64.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 303e470..1b1110f 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -125,10 +125,16 @@ void __init kasan_init(void)
 
 	/*
 	 * kasan_zero_page has been used as early shadow memory, thus it may
-	 * contain some garbage. Now we can clear it, since after the TLB flush
-	 * no one should write to it.
+	 * contain some garbage. Now we can clear and write protect it, since
+	 * after the TLB flush no one should write to it.
 	 */
 	memset(kasan_zero_page, 0, PAGE_SIZE);
+	for (i = 0; i < PTRS_PER_PTE; i++) {
+		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO);
+		set_pte(&kasan_zero_pte[i], pte);
+	}
+	/* Flush TLBs again to be sure that write protection applied. */
+	__flush_tlb_all();
 
 	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

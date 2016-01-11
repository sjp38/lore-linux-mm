Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4406D828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:50:50 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id sv6so245824935lbb.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:50:50 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h64si33935787lfb.126.2016.01.11.04.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 04:50:49 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/2] x86/kasan: clear kasan_zero_page after TLB flush
Date: Mon, 11 Jan 2016 15:51:18 +0300
Message-ID: <1452516679-32040-2-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
References: <20160110185916.GD22896@pd.tnic>
 <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Currently we clear kasan_zero_page before __flush_tlb_all(). This
works with current implementation of native_flush_tlb[_global]()
because it doesn't cause do any writes to kasan shadow memory.
But any subtle change made in native_flush_tlb*() could break this.
Also current code seems doesn't work for paravirt guests (lguest).

Only after the TLB flush we can be sure that kasan_zero_page is not
used as early shadow anymore (instrumented code will not write to it).
So it should cleared it only after the TLB flush.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 arch/x86/mm/kasan_init_64.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index d470cf2..303e470 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -120,11 +120,16 @@ void __init kasan_init(void)
 	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
 			(void *)KASAN_SHADOW_END);
 
-	memset(kasan_zero_page, 0, PAGE_SIZE);
-
 	load_cr3(init_level4_pgt);
 	__flush_tlb_all();
-	init_task.kasan_depth = 0;
 
+	/*
+	 * kasan_zero_page has been used as early shadow memory, thus it may
+	 * contain some garbage. Now we can clear it, since after the TLB flush
+	 * no one should write to it.
+	 */
+	memset(kasan_zero_page, 0, PAGE_SIZE);
+
+	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
 }
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

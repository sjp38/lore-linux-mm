Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B50C56B029B
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 08:02:40 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g1so5739321wmd.0
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 05:02:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o103si2835529wrc.422.2018.01.08.05.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 05:02:39 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 01/22] x86/kasan: Write protect kasan zero shadow
Date: Mon,  8 Jan 2018 13:59:28 +0100
Message-Id: <20180108125925.665331563@linuxfoundation.org>
In-Reply-To: <20180108125925.601688333@linuxfoundation.org>
References: <20180108125925.601688333@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Guenter Roeck <linux@roeck-us.net>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andrey Ryabinin <aryabinin@virtuozzo.com>

commit 063fb3e56f6dd29b2633b678b837e1d904200e6f upstream.

After kasan_init() executed, no one is allowed to write to kasan_zero_page,
so write protect it.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/mm/kasan_init_64.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -126,10 +126,16 @@ void __init kasan_init(void)
 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

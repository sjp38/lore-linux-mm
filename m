Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC466B0069
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:50:29 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id p9so2416618wre.22
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:50:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z68si6088726wmh.72.2017.12.22.00.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 00:50:28 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 04/78] x86/mm: Fix INVPCID asm constraint
Date: Fri, 22 Dec 2017 09:45:45 +0100
Message-Id: <20171222084557.319660368@linuxfoundation.org>
In-Reply-To: <20171222084556.909780563@linuxfoundation.org>
References: <20171222084556.909780563@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Michael Matz <matz@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Borislav Petkov <bp@suse.de>

commit e2c7698cd61f11d4077fdb28148b2d31b82ac848 upstream.

So we want to specify the dependency on both @pcid and @addr so that the
compiler doesn't reorder accesses to them *before* the TLB flush. But
for that to work, we need to express this properly in the inline asm and
deref the whole desc array, not the pointer to it. See clwb() for an
example.

This fixes the build error on 32-bit:

  arch/x86/include/asm/tlbflush.h: In function a??__invpcida??:
  arch/x86/include/asm/tlbflush.h:26:18: error: memory input 0 is not directly addressable

which gcc4.7 caught but 5.x didn't. Which is strange. :-\

Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Michael Matz <matz@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -10,7 +10,7 @@
 static inline void __invpcid(unsigned long pcid, unsigned long addr,
 			     unsigned long type)
 {
-	u64 desc[2] = { pcid, addr };
+	struct { u64 d[2]; } desc = { { pcid, addr } };
 
 	/*
 	 * The memory clobber is because the whole point is to invalidate
@@ -22,7 +22,7 @@ static inline void __invpcid(unsigned lo
 	 * invpcid (%rcx), %rax in long mode.
 	 */
 	asm volatile (".byte 0x66, 0x0f, 0x38, 0x82, 0x01"
-		      : : "m" (desc), "a" (type), "c" (desc) : "memory");
+		      : : "m" (desc), "a" (type), "c" (&desc) : "memory");
 }
 
 #define INVPCID_TYPE_INDIV_ADDR		0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

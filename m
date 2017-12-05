Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B91CB6B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so52766pfg.14
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p11si35199pfl.325.2017.12.05.04.41.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:18 -0800 (PST)
Message-Id: <20171205123820.085253494@infradead.org>
Date: Tue, 05 Dec 2017 13:34:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 4/9] x86/mm: Use __flush_tlb_one() for kernel memory
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-tlb-flush_kernel_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

__flush_tlb_single() is for user mappings, __flush_tlb_one() for
kernel mappings.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/mm/tlb.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -605,9 +605,7 @@ static void do_kernel_range_flush(void *
 
 	/* flush range by one by one 'invlpg' */
 	for (addr = f->start; addr < f->end; addr += PAGE_SIZE)
-		__flush_tlb_single(addr);
-
-	invalidate_pcid_other();
+		__flush_tlb_one(addr);
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

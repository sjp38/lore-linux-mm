Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84B046B026B
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:42 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x24so3984544pgv.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n69si3111867pfk.214.2017.12.14.03.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.747073137@infradead.org>
Date: Thu, 14 Dec 2017 12:27:39 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 13/17] x86/mm: Force LDT desc accessed bit
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-ldt-force-accessed.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

In preparation to mapping the LDT RO, unconditionally set the accessed
bit.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/desc.h |    5 +++++
 arch/x86/kernel/tls.c       |   11 ++---------
 2 files changed, 7 insertions(+), 9 deletions(-)

--- a/arch/x86/include/asm/desc.h
+++ b/arch/x86/include/asm/desc.h
@@ -20,6 +20,11 @@ static inline void fill_ldt(struct desc_
 
 	desc->type		= (info->read_exec_only ^ 1) << 1;
 	desc->type	       |= info->contents << 2;
+	/*
+	 * Always set the accessed bit so that the CPU
+	 * doesn't try to write to the (read-only) GDT/LDT.
+	 */
+	desc->type             |= 1;
 
 	desc->s			= 1;
 	desc->dpl		= 0x3;
--- a/arch/x86/kernel/tls.c
+++ b/arch/x86/kernel/tls.c
@@ -93,17 +93,10 @@ static void set_tls_desc(struct task_str
 	cpu = get_cpu();
 
 	while (n-- > 0) {
-		if (LDT_empty(info) || LDT_zero(info)) {
+		if (LDT_empty(info) || LDT_zero(info))
 			memset(desc, 0, sizeof(*desc));
-		} else {
+		else
 			fill_ldt(desc, info);
-
-			/*
-			 * Always set the accessed bit so that the CPU
-			 * doesn't try to write to the (read-only) GDT.
-			 */
-			desc->type |= 1;
-		}
 		++info;
 		++desc;
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

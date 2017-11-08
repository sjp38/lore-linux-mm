Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 021526B02F9
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:31 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y5so3541547pgq.15
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:30 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n23si4606184plp.371.2017.11.08.11.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:29 -0800 (PST)
Subject: [PATCH 17/30] x86, kaiser: map debug IDT tables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:19 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194719.0D818738@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The IDT table it references are another structure where the
CPU references a virtual address.  It also obviously needs these
to handle an interrupt in userspace, so these need to be mapped into
the user copy of the page tables.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/mm/kaiser.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff -puN arch/x86/mm/kaiser.c~kaiser-user-map-trace-and-debug-idt arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-user-map-trace-and-debug-idt	2017-11-08 10:45:35.124681380 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-08 10:45:35.127681380 -0800
@@ -275,6 +275,14 @@ int kaiser_add_user_map_ptrs(const void
 				   flags);
 }
 
+static int kaiser_user_map_ptr_early(const void *start_addr, unsigned long size,
+				 unsigned long flags)
+{
+	int ret = kaiser_add_user_map(start_addr, size, flags);
+	WARN_ON(ret);
+	return ret;
+}
+
 /*
  * Ensure that the top level of the (shadow) page tables are
  * entirely populated.  This ensures that all processes that get
@@ -363,6 +371,10 @@ void __init kaiser_init(void)
 				  sizeof(gate_desc) * NR_VECTORS,
 				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);
 
+	kaiser_user_map_ptr_early(&debug_idt_table,
+				  sizeof(gate_desc) * NR_VECTORS,
+				  __PAGE_KERNEL | _PAGE_GLOBAL);
+
 	/*
 	 * We could theoretically do this in setup_fixmap_gdt().
 	 * But, we would need to rewrite the above page table
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

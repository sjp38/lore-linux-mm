Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 522CC280244
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b6so371461pff.18
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k82si2735537pfg.374.2017.10.31.15.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:17 -0700 (PDT)
Subject: [PATCH 16/23] x86, kaiser: map debug IDT tables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:15 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223215.4875ED48@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


The IDT table it references are another structure where the
CPU references a virtual address.  It also obviously needs these
to handle an interrupt in userspace, so these need to be mapped into
the user copy of the page tables.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/mm/kaiser.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff -puN arch/x86/mm/kaiser.c~kaiser-user-map-trace-and-debug-idt arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-user-map-trace-and-debug-idt	2017-10-31 15:03:57.365444956 -0700
+++ b/arch/x86/mm/kaiser.c	2017-10-31 15:03:57.368445098 -0700
@@ -250,6 +250,14 @@ int kaiser_add_user_map_ptrs(const void
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
@@ -331,6 +339,10 @@ void __init kaiser_init(void)
 				  sizeof(gate_desc) * NR_VECTORS,
 				  __PAGE_KERNEL_RO);
 
+	kaiser_user_map_ptr_early(&debug_idt_table,
+				  sizeof(gate_desc) * NR_VECTORS,
+				  __PAGE_KERNEL);
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8E316B026F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:10 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s2so425074pge.19
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:10 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y3si2609853pfl.499.2017.10.31.15.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:09 -0700 (PDT)
Subject: [PATCH 12/23] x86, kaiser: map dynamically-allocated LDTs
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:08 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223208.F271E813@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


Normally, a process just has a NULL mm->context.ldt.  But, we
have a syscall for a process to set a new one.  If a process does
that, we need to map the new LDT.

The original KAISER patch missed this case.

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

 b/arch/x86/kernel/ldt.c |   25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff -puN arch/x86/kernel/ldt.c~kaiser-user-map-new-ldts arch/x86/kernel/ldt.c
--- a/arch/x86/kernel/ldt.c~kaiser-user-map-new-ldts	2017-10-31 15:03:55.034334777 -0700
+++ b/arch/x86/kernel/ldt.c	2017-10-31 15:03:55.038334966 -0700
@@ -10,6 +10,7 @@
 #include <linux/gfp.h>
 #include <linux/sched.h>
 #include <linux/string.h>
+#include <linux/kaiser.h>
 #include <linux/mm.h>
 #include <linux/smp.h>
 #include <linux/slab.h>
@@ -55,11 +56,21 @@ static void flush_ldt(void *__mm)
 	refresh_ldt_segments();
 }
 
+static void __free_ldt_struct(struct ldt_struct *ldt)
+{
+	if (ldt->nr_entries * LDT_ENTRY_SIZE > PAGE_SIZE)
+		vfree_atomic(ldt->entries);
+	else
+		free_page((unsigned long)ldt->entries);
+	kfree(ldt);
+}
+
 /* The caller must call finalize_ldt_struct on the result. LDT starts zeroed. */
 static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
 {
 	struct ldt_struct *new_ldt;
 	unsigned int alloc_size;
+	int ret;
 
 	if (num_entries > LDT_ENTRIES)
 		return NULL;
@@ -87,6 +98,12 @@ static struct ldt_struct *alloc_ldt_stru
 		return NULL;
 	}
 
+	ret = kaiser_add_mapping((unsigned long)new_ldt->entries, alloc_size,
+				 __PAGE_KERNEL);
+	if (ret) {
+		__free_ldt_struct(new_ldt);
+		return NULL;
+	}
 	new_ldt->nr_entries = num_entries;
 	return new_ldt;
 }
@@ -113,12 +130,10 @@ static void free_ldt_struct(struct ldt_s
 	if (likely(!ldt))
 		return;
 
+	kaiser_remove_mapping((unsigned long)ldt->entries,
+			      ldt->nr_entries * LDT_ENTRY_SIZE);
 	paravirt_free_ldt(ldt->entries, ldt->nr_entries);
-	if (ldt->nr_entries * LDT_ENTRY_SIZE > PAGE_SIZE)
-		vfree_atomic(ldt->entries);
-	else
-		free_page((unsigned long)ldt->entries);
-	kfree(ldt);
+	__free_ldt_struct(ldt);
 }
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7F66B0253
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id c9so12753903wrb.4
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:47 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 200si50349wml.100.2017.12.12.09.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:46 -0800 (PST)
Message-Id: <20171212173333.750040758@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:27 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 06/16] mm: Provide vm_special_mapping::close
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=mm--Provide-vm_special_mapping--close.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Peter Zijlstra  <peterz@infradead.org>

Userspace can (malisiously) munmap() the VMAs injected into its memory
map through install_special_mapping(). In order to ensure there are no
hardware resources tied to the mapping, we need a close callback.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
---
 include/linux/mm_types.h |    3 +++
 mm/mmap.c                |    4 ++++
 2 files changed, 7 insertions(+)

--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -644,6 +644,9 @@ struct vm_special_mapping {
 
 	int (*mremap)(const struct vm_special_mapping *sm,
 		     struct vm_area_struct *new_vma);
+
+	void (*close)(const struct vm_special_mapping *sm,
+		      struct vm_area_struct *vma);
 };
 
 enum tlb_flush_reason {
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3206,6 +3206,10 @@ static int special_mapping_fault(struct
  */
 static void special_mapping_close(struct vm_area_struct *vma)
 {
+	struct vm_special_mapping *sm = vma->vm_private_data;
+
+	if (sm->close)
+		sm->close(sm, vma);
 }
 
 static const char *special_mapping_name(struct vm_area_struct *vma)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

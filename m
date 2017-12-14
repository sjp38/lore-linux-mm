Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA4E94403DA
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:50 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e41so7685770itd.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:50 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s9si3011855itd.10.2017.12.14.03.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:42 -0800 (PST)
Message-Id: <20171214113851.197682513@infradead.org>
Date: Thu, 14 Dec 2017 12:27:28 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 02/17] mm: Exempt special mappings from mlock(), mprotect() and madvise()
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-vm-no-special-mapping.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

It makes no sense to ever prod at special mappings with any of these
syscalls.

XXX should we include munmap() ?

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 mm/madvise.c  |    3 +++
 mm/mlock.c    |    3 ++-
 mm/mprotect.c |    3 +++
 3 files changed, 8 insertions(+), 1 deletion(-)

--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -678,6 +678,9 @@ static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
 {
+	if (vma_is_special_mapping(vma))
+		return -EINVAL;
+
 	switch (behavior) {
 	case MADV_REMOVE:
 		return madvise_remove(vma, prev, start, end);
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -521,7 +521,8 @@ static int mlock_fixup(struct vm_area_st
 	vm_flags_t old_flags = vma->vm_flags;
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
-	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
+	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm) ||
+	    vma_is_special_mapping(vma))
 		/* don't set VM_LOCKED or VM_LOCKONFAULT and don't count */
 		goto out;
 
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -307,6 +307,9 @@ mprotect_fixup(struct vm_area_struct *vm
 		return 0;
 	}
 
+	if (vma_is_special_mapping(vma))
+		return -ENOMEM;
+
 	/*
 	 * If we make a private mapping writable we increase our commit;
 	 * but (without finer accounting) cannot reduce our commit if we


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

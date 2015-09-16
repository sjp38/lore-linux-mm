Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 92D6F6B0260
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:34 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so215099080pad.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id cj4si42289090pbc.126.2015.09.16.10.49.12
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:12 -0700 (PDT)
Subject: [PATCH 20/26] [NEWSYSCALL] mm: implement new mprotect_pkey() system call
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:09 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174909.3E595780@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


mprotect_pkey() is just like mprotect, except it also takes a
protection key as an argument.  On systems that do not support
protection keys, it still works, but requires that key=0.
Otherwise it does exactly what mprotect does.

I expect it to get used like this, if you want to guarantee that
any mapping you create can *never* be accessed without the right
protection keys set up.

	pkey_deny_access(11); // random pkey
	int real_prot = PROT_READ|PROT_WRITE;
	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
	ret = mprotect_pkey(ptr, PAGE_SIZE, real_prot, 11);

This way, there is *no* window where the mapping is accessible
since it was always either PROT_NONE or had a protection key set.

---

 b/mm/Kconfig    |    7 +++++++
 b/mm/mprotect.c |   20 +++++++++++++++++---
 2 files changed, 24 insertions(+), 3 deletions(-)

diff -puN mm/Kconfig~pkeys-85-mprotect_pkey mm/Kconfig
--- a/mm/Kconfig~pkeys-85-mprotect_pkey	2015-09-16 10:48:20.270374302 -0700
+++ b/mm/Kconfig	2015-09-16 10:48:20.275374529 -0700
@@ -683,3 +683,10 @@ config FRAME_VECTOR
 
 config ARCH_USES_HIGH_VMA_FLAGS
 	bool
+
+config NR_PROTECTION_KEYS
+	int
+	# Everything supports a _single_ key, so allow folks to
+	# at least call APIs that take keys, but require that the
+	# key be 0.
+	default 1
diff -puN mm/mprotect.c~pkeys-85-mprotect_pkey mm/mprotect.c
--- a/mm/mprotect.c~pkeys-85-mprotect_pkey	2015-09-16 10:48:20.272374393 -0700
+++ b/mm/mprotect.c	2015-09-16 10:48:20.276374574 -0700
@@ -344,8 +344,8 @@ fail:
 	return error;
 }
 
-SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
-		unsigned long, prot)
+static int do_mprotect_key(unsigned long start, size_t len,
+		unsigned long prot, unsigned long key)
 {
 	unsigned long vm_flags, nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
@@ -365,6 +365,8 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 		return -ENOMEM;
 	if (!arch_validate_prot(prot))
 		return -EINVAL;
+	if (key >= CONFIG_NR_PROTECTION_KEYS)
+		return -EINVAL;
 
 	reqprot = prot;
 	/*
@@ -373,7 +375,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
 		prot |= PROT_EXEC;
 
-	vm_flags = calc_vm_prot_bits(prot, 0);
+	vm_flags = calc_vm_prot_bits(prot, key);
 
 	down_write(&current->mm->mmap_sem);
 
@@ -443,3 +445,15 @@ out:
 	up_write(&current->mm->mmap_sem);
 	return error;
 }
+
+SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
+		unsigned long, prot)
+{
+	return do_mprotect_key(start, len, prot, 0);
+}
+
+SYSCALL_DEFINE4(mprotect_key, unsigned long, start, size_t, len,
+		unsigned long, prot, unsigned long, key)
+{
+	return do_mprotect_key(start, len, prot, key);
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

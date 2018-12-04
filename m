Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 763906B6D96
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:37:34 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t26so8447159pgu.18
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:37:34 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o16si15820728pgd.117.2018.12.03.23.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:37:25 -0800 (PST)
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC v2 06/13] mm: Add the encrypt_mprotect() system call
Date: Mon,  3 Dec 2018 23:39:53 -0800
Message-Id: <0c5d9e96c75445ced3b22d9359a8cb3fa2b6f8ad.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

Implement memory encryption with a new system call that is an
extension of the legacy mprotect() system call.

In encrypt_mprotect the caller must pass a handle to a previously
allocated and programmed encryption key. Validate the key and store
the keyid bits in the vm_page_prot for each VMA in the protection
range.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/exec.c           |  4 ++--
 include/linux/key.h |  2 ++
 include/linux/mm.h  |  3 ++-
 mm/mprotect.c       | 63 +++++++++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 62 insertions(+), 10 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index fc281b738a98..a0946b23e2c5 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -752,8 +752,8 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	vm_flags |= mm->def_flags;
 	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
 
-	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
-			vm_flags);
+	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end, vm_flags,
+			     -1);
 	if (ret)
 		goto out_unlock;
 	BUG_ON(prev != vma);
diff --git a/include/linux/key.h b/include/linux/key.h
index e58ee10f6e58..fb8a7d5f6149 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -346,6 +346,8 @@ static inline key_serial_t key_serial(const struct key *key)
 
 extern void key_set_timeout(struct key *, unsigned);
 
+extern key_ref_t lookup_user_key(key_serial_t id, unsigned long lflags,
+				 key_perm_t perm);
 /*
  * The permissions required on a key that we're looking up.
  */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e2d87e92ca74..09182d78e7b7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1607,7 +1607,8 @@ extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long
 			      int dirty_accountable, int prot_numa);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, unsigned long newflags,
+			  int newkeyid);
 
 /*
  * doesn't attempt to fault and will return short.
diff --git a/mm/mprotect.c b/mm/mprotect.c
index b57075e278fb..ad8127dc9aac 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -28,6 +28,7 @@
 #include <linux/ksm.h>
 #include <linux/uaccess.h>
 #include <linux/mm_inline.h>
+#include <linux/key.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
@@ -346,7 +347,8 @@ static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	       unsigned long start, unsigned long end, unsigned long newflags,
+	       int newkeyid)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long oldflags = vma->vm_flags;
@@ -356,7 +358,14 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	int error;
 	int dirty_accountable = 0;
 
-	if (newflags == oldflags) {
+	/*
+	 * Flags match and Keyids match or we have NO_KEY.
+	 * This _fixup is usually called from do_mprotect_ext() except
+	 * for one special case: caller fs/exec.c/setup_arg_pages()
+	 * In that case, newkeyid is passed as -1 (NO_KEY).
+	 */
+	if (newflags == oldflags &&
+	    (newkeyid == vma_keyid(vma) || newkeyid == NO_KEY)) {
 		*pprev = vma;
 		return 0;
 	}
@@ -422,6 +431,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	}
 
 success:
+	if (newkeyid != NO_KEY)
+		mprotect_set_encrypt(vma, newkeyid, start, end);
 	/*
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
@@ -453,10 +464,15 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 }
 
 /*
- * When pkey==NO_KEY we get legacy mprotect behavior here.
+ * do_mprotect_ext() supports the legacy mprotect behavior plus extensions
+ * for Protection Keys and Memory Encryption Keys. These extensions are
+ * mutually exclusive and the behavior is:
+ *	(pkey==NO_KEY && keyid==NO_KEY) ==> legacy mprotect
+ *	(pkey is valid)  ==> legacy mprotect plus Protection Key extensions
+ *	(keyid is valid) ==> legacy mprotect plus Encryption Key extensions
  */
 static int do_mprotect_ext(unsigned long start, size_t len,
-		unsigned long prot, int pkey)
+			   unsigned long prot, int pkey, int keyid)
 {
 	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
@@ -554,7 +570,8 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 		tmp = vma->vm_end;
 		if (tmp > end)
 			tmp = end;
-		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags);
+		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags,
+				       keyid);
 		if (error)
 			goto out;
 		nstart = tmp;
@@ -579,7 +596,7 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	return do_mprotect_ext(start, len, prot, NO_KEY);
+	return do_mprotect_ext(start, len, prot, NO_KEY, NO_KEY);
 }
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -587,7 +604,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
-	return do_mprotect_ext(start, len, prot, pkey);
+	return do_mprotect_ext(start, len, prot, pkey, NO_KEY);
 }
 
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
@@ -636,3 +653,35 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 }
 
 #endif /* CONFIG_ARCH_HAS_PKEYS */
+
+#ifdef CONFIG_X86_INTEL_MKTME
+
+SYSCALL_DEFINE4(encrypt_mprotect, unsigned long, start, size_t, len,
+		unsigned long, prot, key_serial_t, serial)
+{
+	key_ref_t key_ref;
+	struct key *key;
+	int ret, keyid;
+
+	if (!PAGE_ALIGNED(len))
+		return -EINVAL;
+
+	key_ref = lookup_user_key(serial, 0, KEY_NEED_VIEW);
+	if (IS_ERR(key_ref))
+		return PTR_ERR(key_ref);
+
+	key = key_ref_to_ptr(key_ref);
+	mktme_map_lock();
+	keyid = mktme_map_keyid_from_key(key);
+	if (!keyid) {
+		mktme_map_unlock();
+		key_ref_put(key_ref);
+		return -EINVAL;
+	}
+	ret = do_mprotect_ext(start, len, prot, NO_KEY, keyid);
+	mktme_map_unlock();
+	key_ref_put(key_ref);
+	return ret;
+}
+
+#endif /* CONFIG_X86_INTEL_MKTME */
-- 
2.14.1

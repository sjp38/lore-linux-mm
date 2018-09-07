Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38F288E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:36:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d1-v6so8117349pfo.16
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:36:11 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 1-v6si8956466plz.220.2018.09.07.15.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:36:09 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:36:51 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 06/12] mm: Add the encrypt_mprotect() system call
Message-ID: <7d27511b07c8337e15096214622b66ef8f0fa345.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Implement memory encryption with a new system call that is an
extension of the legacy mprotect() system call.

In encrypt_mprotect the caller must pass a handle to a previously
allocated and programmed encryption key. Validate the key and store
the keyid bits in the vm_page_prot for each VMA in the protection
range.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 fs/exec.c           |  4 ++--
 include/linux/key.h |  2 ++
 include/linux/mm.h  |  3 ++-
 mm/mprotect.c       | 67 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 67 insertions(+), 9 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index a1a246062561..b681a413db9c 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -754,8 +754,8 @@ int setup_arg_pages(struct linux_binprm *bprm,
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
index ac85c0805761..0f9422c7841e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1579,7 +1579,8 @@ extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long
 			      int dirty_accountable, int prot_numa);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, unsigned long newflags,
+			  int newkeyid);
 
 /*
  * doesn't attempt to fault and will return short.
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 56e64ef7931e..6c2e1106525c 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -28,14 +28,17 @@
 #include <linux/ksm.h>
 #include <linux/uaccess.h>
 #include <linux/mm_inline.h>
+#include <linux/key.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
 #include <asm/tlbflush.h>
+#include <asm/mktme.h>
 
 #include "internal.h"
 
 #define NO_PKEY  -1
+#define NO_KEYID -1
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
@@ -310,7 +313,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	       unsigned long start, unsigned long end, unsigned long newflags,
+	       int newkeyid)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long oldflags = vma->vm_flags;
@@ -320,10 +324,24 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	int error;
 	int dirty_accountable = 0;
 
+	/*
+	 * Flags match and Keyids match or we have NO_KEYID.
+	 * This _fixup is usually called from do_mprotect_ext() except
+	 * for one special case: caller fs/exec.c/setup_arg_pages()
+	 * In that case, newkeyid is passed as -1 (NO_KEYID).
+	 */
+	if (newflags == oldflags &&
+	    (newkeyid == vma_keyid(vma) || newkeyid == NO_KEYID)) {
+		*pprev = vma;
+		return 0;
+	}
+	/* Flags match and Keyid changes */
 	if (newflags == oldflags) {
+		mprotect_set_encrypt(vma, newkeyid);
 		*pprev = vma;
 		return 0;
 	}
+	/* Flags and Keyids both change, continue. */
 
 	/*
 	 * If we make a private mapping writable we increase our commit;
@@ -373,6 +391,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	}
 
 success:
+	if (newkeyid != NO_KEYID)
+		mprotect_set_encrypt(vma, newkeyid);
 	/*
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
@@ -404,10 +424,15 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 }
 
 /*
- * When pkey==NO_PKEY we get legacy mprotect behavior here.
+ * do_mprotect_ext() supports the legacy mprotect behavior plus extensions
+ * for protection keys and memory encryption keys. These extensions are
+ * mutually exclusive and the behavior is:
+ *	(pkey==NO_PKEY && keyid==NO_KEYID) ==> legacy mprotect
+ *	(pkey is valid)  ==> legacy mprotect plus protection key extensions
+ *	(keyid is valid) ==> legacy mprotect plus encryption key extensions
  */
 static int do_mprotect_ext(unsigned long start, size_t len,
-		unsigned long prot, int pkey)
+			   unsigned long prot, int pkey, int keyid)
 {
 	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
@@ -505,7 +530,8 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 		tmp = vma->vm_end;
 		if (tmp > end)
 			tmp = end;
-		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags);
+		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags,
+				       keyid);
 		if (error)
 			goto out;
 		nstart = tmp;
@@ -530,7 +556,7 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	return do_mprotect_ext(start, len, prot, NO_PKEY);
+	return do_mprotect_ext(start, len, prot, NO_PKEY, NO_KEYID);
 }
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -538,7 +564,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
-	return do_mprotect_ext(start, len, prot, pkey);
+	return do_mprotect_ext(start, len, prot, pkey, NO_KEYID);
 }
 
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
@@ -587,3 +613,32 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 }
 
 #endif /* CONFIG_ARCH_HAS_PKEYS */
+
+#ifdef CONFIG_X86_INTEL_MKTME
+
+SYSCALL_DEFINE4(encrypt_mprotect, unsigned long, start, size_t, len,
+		unsigned long, prot, key_serial_t, serial)
+{
+	key_ref_t key_ref;
+	int ret, keyid;
+
+	/* TODO MKTME key service must be initialized */
+
+	key_ref = lookup_user_key(serial, 0, KEY_NEED_VIEW);
+	if (IS_ERR(key_ref))
+		return PTR_ERR(key_ref);
+
+	mktme_map_lock();
+	keyid = mktme_map_keyid_from_serial(serial);
+	if (!keyid) {
+		mktme_map_unlock();
+		key_ref_put(key_ref);
+		return -EINVAL;
+	}
+	ret = do_mprotect_ext(start, len, prot, NO_PKEY, keyid);
+	mktme_map_unlock();
+	key_ref_put(key_ref);
+	return ret;
+}
+
+#endif /* CONFIG_X86_INTEL_MKTME */
-- 
2.14.1

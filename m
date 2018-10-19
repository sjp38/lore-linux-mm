Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F17A6B0007
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 11:14:57 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 88-v6so26999309wrp.21
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 08:14:57 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id p5si4242058wrx.116.2018.10.19.08.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 08:14:55 -0700 (PDT)
Message-Id: <336eb81e62d6c683a69d312f533899dcb6bcf770.1539959864.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH] mm: add probe_user_read() and probe_user_address()
Date: Fri, 19 Oct 2018 15:14:54 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

In the powerpc, there are several places implementing safe
access to user data. This is sometimes implemented using
probe_kerne_address() with additional access_ok() verification,
sometimes with get_user() enclosed in a pagefault_disable()/enable()
pair, etc... :
    show_user_instructions()
    bad_stack_expansion()
    p9_hmi_special_emu()
    fsl_pci_mcheck_exception()
    read_user_stack_64()
    read_user_stack_32() on PPC64
    read_user_stack_32() on PPC32
    power_pmu_bhrb_to()

In the same spirit as probe_kernel_read() and probe_kernel_address(),
this patch adds probe_user_read() and probe_user_address().

probe_user_read() does the same as probe_kernel_read() but
first checks that it is really a user address.

probe_user_address() is a shortcut to probe_user_read()

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 include/linux/uaccess.h | 10 ++++++++++
 mm/maccess.c            | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index efe79c1cdd47..fb00e3f847d7 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -266,6 +266,16 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
 #define probe_kernel_address(addr, retval)		\
 	probe_kernel_read(&retval, addr, sizeof(retval))
 
+/**
+ * probe_user_address(): safely attempt to read from a user location
+ * @addr: address to read from
+ * @retval: read into this variable
+ *
+ * Returns 0 on success, or -EFAULT.
+ */
+#define probe_user_address(addr, retval)		\
+	probe_user_read(&(retval), addr, sizeof(retval))
+
 #ifndef user_access_begin
 #define user_access_begin() do { } while (0)
 #define user_access_end() do { } while (0)
diff --git a/mm/maccess.c b/mm/maccess.c
index ec00be51a24f..85d4a88a6917 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -67,6 +67,39 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
 EXPORT_SYMBOL_GPL(probe_kernel_write);
 
 /**
+ * probe_user_read(): safely attempt to read from a user location
+ * @dst: pointer to the buffer that shall take the data
+ * @src: address to read from
+ * @size: size of the data chunk
+ *
+ * Safely read from address @src to the buffer at @dst.  If a kernel fault
+ * happens, handle that and return -EFAULT.
+ *
+ * We ensure that the copy_from_user is executed in atomic context so that
+ * do_page_fault() doesn't attempt to take mmap_sem.  This makes
+ * probe_user_read() suitable for use within regions where the caller
+ * already holds mmap_sem, or other locks which nest inside mmap_sem.
+ */
+
+long __weak probe_user_read(void *dst, const void *src, size_t size)
+	__attribute__((alias("__probe_user_read")));
+
+long __probe_user_read(void *dst, const void __user *src, size_t size)
+{
+	long ret;
+
+	if (!access_ok(VERIFY_READ, src, size))
+		return -EFAULT;
+
+	pagefault_disable();
+	ret = __copy_from_user_inatomic(dst, src, size);
+	pagefault_enable();
+
+	return ret ? -EFAULT : 0;
+}
+EXPORT_SYMBOL_GPL(probe_user_read);
+
+/**
  * strncpy_from_unsafe: - Copy a NUL terminated string from unsafe address.
  * @dst:   Destination address, in kernel space.  This buffer must be at
  *         least @count bytes long.
-- 
2.13.3

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB906B6A4E
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 12:06:46 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id t62-v6so4538766wmg.6
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 09:06:46 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x12si11016001wrt.114.2018.12.03.09.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 09:06:44 -0800 (PST)
Message-Id: <dd9ef91add7fcf5a9e369dde322b1822e90eb218.1543811917.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 1/2] mm: add probe_user_read() and probe_user_address()
Date: Mon,  3 Dec 2018 17:06:42 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

In the powerpc, there are several places implementing safe
access to user data. This is sometimes implemented using
probe_kernel_address() with additional access_ok() verification,
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
 Changes since RFC: Made a static inline function instead of weak function as recommended by Kees.

 include/linux/uaccess.h | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index efe79c1cdd47..83ea8aefca75 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -266,6 +266,48 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
 #define probe_kernel_address(addr, retval)		\
 	probe_kernel_read(&retval, addr, sizeof(retval))
 
+/**
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
+#ifndef probe_user_read
+static __always_inline long probe_user_read(void *dst, const void __user *src,
+					    size_t size)
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
+#endif
+
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
-- 
2.13.3

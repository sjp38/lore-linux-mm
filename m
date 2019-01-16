Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 657EC8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:59:30 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id y85so1474181wmc.7
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:59:30 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id g1si55416782wrv.204.2019.01.16.08.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 08:59:28 -0800 (PST)
Message-Id: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 1/2] mm: add probe_user_read()
Date: Wed, 16 Jan 2019 16:59:27 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

In powerpc code, there are several places implementing safe
access to user data. This is sometimes implemented using
probe_kernel_address() with additional access_ok() verification,
sometimes with get_user() enclosed in a pagefault_disable()/enable()
pair, etc. :
    show_user_instructions()
    bad_stack_expansion()
    p9_hmi_special_emu()
    fsl_pci_mcheck_exception()
    read_user_stack_64()
    read_user_stack_32() on PPC64
    read_user_stack_32() on PPC32
    power_pmu_bhrb_to()

In the same spirit as probe_kernel_read(), this patch adds
probe_user_read().

probe_user_read() does the same as probe_kernel_read() but
first checks that it is really a user address.

The patch defines this function as a static inline so the "size"
variable can be examined for const-ness by the check_object_size()
in __copy_from_user_inatomic()

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 v3: Moved 'Returns:" comment after description.
     Explained in the commit log why the function is defined static inline

 v2: Added "Returns:" comment and removed probe_user_address()

 include/linux/uaccess.h | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index 37b226e8df13..ef99edd63da3 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
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
+ *
+ * Returns: 0 on success, -EFAULT on error.
+ */
+
+#ifndef probe_user_read
+static __always_inline long probe_user_read(void *dst, const void __user *src,
+					    size_t size)
+{
+	long ret;
+
+	if (!access_ok(src, size))
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
 #ifndef user_access_begin
 #define user_access_begin(ptr,len) access_ok(ptr, len)
 #define user_access_end() do { } while (0)
-- 
2.13.3

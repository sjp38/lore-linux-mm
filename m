Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 07/17] prmem: lkdtm tests for memory protection
Date: Wed, 24 Oct 2018 00:34:54 +0300
Message-Id: <20181023213504.28905-8-igor.stoppa@huawei.com>
In-Reply-To: <20181023213504.28905-1-igor.stoppa@huawei.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Various cases meant to verify that illegal operations on protected
memory will either BUG() or WARN().

The test cases fall into 2 main categories:
- trying to overwrite (directly) something that is write protected
- trying to use write rare functions on something that is not write rare

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Kees Cook <keescook@chromium.org>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Arnd Bergmann <arnd@arndb.de>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 drivers/misc/lkdtm/core.c  |  13 ++
 drivers/misc/lkdtm/lkdtm.h |  13 ++
 drivers/misc/lkdtm/perms.c | 248 +++++++++++++++++++++++++++++++++++++
 3 files changed, 274 insertions(+)

diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
index 2154d1bfd18b..41a3ba16bc57 100644
--- a/drivers/misc/lkdtm/core.c
+++ b/drivers/misc/lkdtm/core.c
@@ -155,6 +155,19 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(ACCESS_USERSPACE),
 	CRASHTYPE(WRITE_RO),
 	CRASHTYPE(WRITE_RO_AFTER_INIT),
+	CRASHTYPE(WRITE_WR_AFTER_INIT),
+	CRASHTYPE(WRITE_WR_AFTER_INIT_ON_RO_AFTER_INIT),
+	CRASHTYPE(WRITE_WR_AFTER_INIT_ON_CONST),
+#ifdef CONFIG_PRMEM
+	CRASHTYPE(WRITE_RO_PMALLOC),
+	CRASHTYPE(WRITE_AUTO_RO_PMALLOC),
+	CRASHTYPE(WRITE_WR_PMALLOC),
+	CRASHTYPE(WRITE_AUTO_WR_PMALLOC),
+	CRASHTYPE(WRITE_START_WR_PMALLOC),
+	CRASHTYPE(WRITE_WR_PMALLOC_ON_RO_PMALLOC),
+	CRASHTYPE(WRITE_WR_PMALLOC_ON_CONST),
+	CRASHTYPE(WRITE_WR_PMALLOC_ON_RO_AFT_INIT),
+#endif
 	CRASHTYPE(WRITE_KERN),
 	CRASHTYPE(REFCOUNT_INC_OVERFLOW),
 	CRASHTYPE(REFCOUNT_ADD_OVERFLOW),
diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
index 9e513dcfd809..08368c4545f7 100644
--- a/drivers/misc/lkdtm/lkdtm.h
+++ b/drivers/misc/lkdtm/lkdtm.h
@@ -38,6 +38,19 @@ void lkdtm_READ_BUDDY_AFTER_FREE(void);
 void __init lkdtm_perms_init(void);
 void lkdtm_WRITE_RO(void);
 void lkdtm_WRITE_RO_AFTER_INIT(void);
+void lkdtm_WRITE_WR_AFTER_INIT(void);
+void lkdtm_WRITE_WR_AFTER_INIT_ON_RO_AFTER_INIT(void);
+void lkdtm_WRITE_WR_AFTER_INIT_ON_CONST(void);
+#ifdef CONFIG_PRMEM
+void lkdtm_WRITE_RO_PMALLOC(void);
+void lkdtm_WRITE_AUTO_RO_PMALLOC(void);
+void lkdtm_WRITE_WR_PMALLOC(void);
+void lkdtm_WRITE_AUTO_WR_PMALLOC(void);
+void lkdtm_WRITE_START_WR_PMALLOC(void);
+void lkdtm_WRITE_WR_PMALLOC_ON_RO_PMALLOC(void);
+void lkdtm_WRITE_WR_PMALLOC_ON_CONST(void);
+void lkdtm_WRITE_WR_PMALLOC_ON_RO_AFT_INIT(void);
+#endif
 void lkdtm_WRITE_KERN(void);
 void lkdtm_EXEC_DATA(void);
 void lkdtm_EXEC_STACK(void);
diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 53b85c9d16b8..3c14fd4d90ac 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -9,6 +9,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mman.h>
 #include <linux/uaccess.h>
+#include <linux/prmemextra.h>
 #include <asm/cacheflush.h>
 
 /* Whether or not to fill the target memory area with do_nothing(). */
@@ -27,6 +28,10 @@ static const unsigned long rodata = 0xAA55AA55;
 /* This is marked __ro_after_init, so it should ultimately be .rodata. */
 static unsigned long ro_after_init __ro_after_init = 0x55AA5500;
 
+/* This is marked __wr_after_init, so it should be in .rodata. */
+static
+unsigned long wr_after_init __wr_after_init = 0x55AA5500;
+
 /*
  * This just returns to the caller. It is designed to be copied into
  * non-executable memory regions.
@@ -104,6 +109,247 @@ void lkdtm_WRITE_RO_AFTER_INIT(void)
 	*ptr ^= 0xabcd1234;
 }
 
+void lkdtm_WRITE_WR_AFTER_INIT(void)
+{
+	unsigned long *ptr = &wr_after_init;
+
+	/*
+	 * Verify we were written to during init. Since an Oops
+	 * is considered a "success", a failure is to just skip the
+	 * real test.
+	 */
+	if ((*ptr & 0xAA) != 0xAA) {
+		pr_info("%p was NOT written during init!?\n", ptr);
+		return;
+	}
+
+	pr_info("attempting bad wr_after_init write at %p\n", ptr);
+	*ptr ^= 0xabcd1234;
+}
+
+#define INIT_VAL 0x5A
+#define END_VAL 0xA5
+
+/* Verify that write rare will not work against read-only memory. */
+static int ro_after_init_data __ro_after_init = INIT_VAL;
+void lkdtm_WRITE_WR_AFTER_INIT_ON_RO_AFTER_INIT(void)
+{
+	pr_info("attempting illegal write rare to __ro_after_init");
+	if (wr_int(&ro_after_init_data, END_VAL) ||
+	     ro_after_init_data == END_VAL)
+		pr_info("Unexpected successful write to __ro_after_init");
+}
+
+/*
+ * "volatile" to force the compiler to not optimize away the reading back.
+ * Is there a better way to do it, than using volatile?
+ */
+static volatile const int const_data = INIT_VAL;
+void lkdtm_WRITE_WR_AFTER_INIT_ON_CONST(void)
+{
+	pr_info("attempting illegal write rare to const data");
+	if (wr_int((int *)&const_data, END_VAL) || const_data == END_VAL)
+		pr_info("Unexpected successful write to const memory");
+}
+
+#ifdef CONFIG_PRMEM
+
+#define MSG_NO_POOL "Cannot allocate memory for the pool."
+#define MSG_NO_PMEM "Cannot allocate memory from the pool."
+
+void lkdtm_WRITE_RO_PMALLOC(void)
+{
+	struct pmalloc_pool *pool;
+	int *i;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_RO);
+	if (!pool) {
+		pr_info(MSG_NO_POOL);
+		return;
+	}
+	i = pmalloc(pool, sizeof(int));
+	if (!i) {
+		pr_info(MSG_NO_PMEM);
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*i = INT_MAX;
+	pmalloc_protect_pool(pool);
+	pr_info("attempting bad pmalloc write at %p\n", i);
+	*i = 0; /* Note: this will crash and leak the pool memory. */
+}
+
+void lkdtm_WRITE_AUTO_RO_PMALLOC(void)
+{
+	struct pmalloc_pool *pool;
+	int *i;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_AUTO_RO);
+	if (!pool) {
+		pr_info(MSG_NO_POOL);
+		return;
+	}
+	i = pmalloc(pool, sizeof(int));
+	if (!i) {
+		pr_info(MSG_NO_PMEM);
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*i = INT_MAX;
+	pmalloc(pool, PMALLOC_DEFAULT_REFILL_SIZE);
+	pr_info("attempting bad pmalloc write at %p\n", i);
+	*i = 0; /* Note: this will crash and leak the pool memory. */
+}
+
+void lkdtm_WRITE_WR_PMALLOC(void)
+{
+	struct pmalloc_pool *pool;
+	int *i;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (!pool) {
+		pr_info(MSG_NO_POOL);
+		return;
+	}
+	i = pmalloc(pool, sizeof(int));
+	if (!i) {
+		pr_info(MSG_NO_PMEM);
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*i = INT_MAX;
+	pmalloc_protect_pool(pool);
+	pr_info("attempting bad pmalloc write at %p\n", i);
+	*i = 0; /* Note: this will crash and leak the pool memory. */
+}
+
+void lkdtm_WRITE_AUTO_WR_PMALLOC(void)
+{
+	struct pmalloc_pool *pool;
+	int *i;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_AUTO_WR);
+	if (!pool) {
+		pr_info(MSG_NO_POOL);
+		return;
+	}
+	i = pmalloc(pool, sizeof(int));
+	if (!i) {
+		pr_info(MSG_NO_PMEM);
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*i = INT_MAX;
+	pmalloc(pool, PMALLOC_DEFAULT_REFILL_SIZE);
+	pr_info("attempting bad pmalloc write at %p\n", i);
+	*i = 0; /* Note: this will crash and leak the pool memory. */
+}
+
+void lkdtm_WRITE_START_WR_PMALLOC(void)
+{
+	struct pmalloc_pool *pool;
+	int *i;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_START_WR);
+	if (!pool) {
+		pr_info(MSG_NO_POOL);
+		return;
+	}
+	i = pmalloc(pool, sizeof(int));
+	if (!i) {
+		pr_info(MSG_NO_PMEM);
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*i = INT_MAX;
+	pr_info("attempting bad pmalloc write at %p\n", i);
+	*i = 0; /* Note: this will crash and leak the pool memory. */
+}
+
+void lkdtm_WRITE_WR_PMALLOC_ON_RO_PMALLOC(void)
+{
+	struct pmalloc_pool *pool;
+	int *var_ptr;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_RO);
+	if (!pool) {
+		pr_info(MSG_NO_POOL);
+		return;
+	}
+	var_ptr = pmalloc(pool, sizeof(int));
+	if (!var_ptr) {
+		pr_info(MSG_NO_PMEM);
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*var_ptr = INIT_VAL;
+	pmalloc_protect_pool(pool);
+	pr_info("attempting illegal write rare to R/O pool");
+	if (wr_int(var_ptr, END_VAL))
+		pr_info("Unexpected successful write to R/O pool");
+	pmalloc_destroy_pool(pool);
+}
+
+void lkdtm_WRITE_WR_PMALLOC_ON_CONST(void)
+{
+	struct pmalloc_pool *pool;
+	int *dummy;
+	bool write_result;
+
+	/*
+	 * The pool operations are only meant to simulate an attacker
+	 * using a random pool as parameter for the attack against the
+	 * const.
+	 */
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (!pool) {
+		pr_info(MSG_NO_POOL);
+		return;
+	}
+	dummy = pmalloc(pool, sizeof(*dummy));
+	if (!dummy) {
+		pr_info(MSG_NO_PMEM);
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*dummy = 1;
+	pmalloc_protect_pool(pool);
+	pr_info("attempting illegal write rare to const data");
+	write_result = wr_int((int *)&const_data, END_VAL);
+	pmalloc_destroy_pool(pool);
+	if (write_result || const_data != INIT_VAL)
+		pr_info("Unexpected successful write to const memory");
+}
+
+void lkdtm_WRITE_WR_PMALLOC_ON_RO_AFT_INIT(void)
+{
+	struct pmalloc_pool *pool;
+	int *dummy;
+	bool write_result;
+
+	/*
+	 * The pool operations are only meant to simulate an attacker
+	 * using a random pool as parameter for the attack against the
+	 * const.
+	 */
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return;
+	dummy = pmalloc(pool, sizeof(*dummy));
+	if (WARN(!dummy, MSG_NO_PMEM)) {
+		pmalloc_destroy_pool(pool);
+		return;
+	}
+	*dummy = 1;
+	pmalloc_protect_pool(pool);
+	pr_info("attempting illegal write rare to ro_after_init");
+	write_result = wr_int(&ro_after_init_data, END_VAL);
+	pmalloc_destroy_pool(pool);
+	WARN(write_result || ro_after_init_data != INIT_VAL,
+	     "Unexpected successful write to ro_after_init memory");
+}
+#endif
+
 void lkdtm_WRITE_KERN(void)
 {
 	size_t size;
@@ -200,4 +446,6 @@ void __init lkdtm_perms_init(void)
 	/* Make sure we can write to __ro_after_init values during __init */
 	ro_after_init |= 0xAA;
 
+	/* Make sure we can write to __wr_after_init during __init */
+	wr_after_init |= 0xAA;
 }
-- 
2.17.1

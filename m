Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 05/12] __wr_after_init: x86_64: debug writes
Date: Wed, 19 Dec 2018 23:33:31 +0200
Message-Id: <20181219213338.26619-6-igor.stoppa@huawei.com>
In-Reply-To: <20181219213338.26619-1-igor.stoppa@huawei.com>
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

After each write operation, confirm that it was successful, otherwise
generate a warning.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/x86/mm/prmem.c | 9 ++++++++-
 mm/Kconfig.debug    | 8 ++++++++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/prmem.c b/arch/x86/mm/prmem.c
index fc367551e736..9d98525c687a 100644
--- a/arch/x86/mm/prmem.c
+++ b/arch/x86/mm/prmem.c
@@ -60,7 +60,14 @@ void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
 		copy_to_user((void __user *)wr_poking_addr, (void *)src, len);
 	else if (op == WR_MEMSET)
 		memset_user((void __user *)wr_poking_addr, (u8)src, len);
-
+#ifdef CONFIG_DEBUG_PRMEM
+	if (op == WR_MEMCPY)
+		VM_WARN_ONCE(memcmp((void *)dst, (void *)src, len),
+			     "Failed wr_memcpy()");
+	else if (op == WR_MEMSET)
+		VM_WARN_ONCE(memtst((void *)dst, (u8)src, len),
+			     "Failed wr_memset()");
+#endif
 	unuse_temporary_mm(prev);
 	local_irq_enable();
 	return (void *)dst;
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 9a7b8b049d04..b10305cfac3c 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -94,3 +94,11 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config DEBUG_PRMEM
+    bool "Verify each write rare operation."
+    depends on PRMEM
+    default n
+    help
+      After any write rare operation, compares the data written with the
+      value provided by the caller.
-- 
2.19.1

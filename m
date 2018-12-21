Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0092F8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:14:54 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id j24-v6so1889550lji.20
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:14:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w77sor6921307lff.36.2018.12.21.10.14.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 10:14:52 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 04/12] __wr_after_init: debug writes
Date: Fri, 21 Dec 2018 20:14:15 +0200
Message-Id: <20181221181423.20455-5-igor.stoppa@huawei.com>
In-Reply-To: <20181221181423.20455-1-igor.stoppa@huawei.com>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 mm/Kconfig.debug | 8 ++++++++
 mm/prmem.c       | 6 ++++++
 2 files changed, 14 insertions(+)

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
diff --git a/mm/prmem.c b/mm/prmem.c
index e1c1be3a1171..51f6776e2515 100644
--- a/mm/prmem.c
+++ b/mm/prmem.c
@@ -61,6 +61,9 @@ void *wr_memcpy(void *p, const void *q, __kernel_size_t size)
 	__wr_enable(&wr_state);
 	__wr_memcpy(wr_poking_addr, q, size);
 	__wr_disable(&wr_state);
+#ifdef CONFIG_DEBUG_PRMEM
+	VM_WARN_ONCE(memcmp(p, q, size), "Failed %s()", __func__);
+#endif
 	local_irq_enable();
 	return p;
 }
@@ -92,6 +95,9 @@ void *wr_memset(void *p, int c, __kernel_size_t len)
 	__wr_enable(&wr_state);
 	__wr_memset(wr_poking_addr, c, len);
 	__wr_disable(&wr_state);
+#ifdef CONFIG_DEBUG_PRMEM
+	VM_WARN_ONCE(memtst(p, c, len), "Failed %s()", __func__);
+#endif
 	local_irq_enable();
 	return p;
 }
-- 
2.19.1

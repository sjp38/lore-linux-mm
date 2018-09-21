Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26FE98E002A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:10:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g9-v6so5795633pgc.16
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:10:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g16-v6si2805450pgd.354.2018.09.21.08.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:10:29 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 3/9] x86/cet/ibt: Add IBT legacy code bitmap allocation function
Date: Fri, 21 Sep 2018 08:05:47 -0700
Message-Id: <20180921150553.21016-4-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150553.21016-1-yu-cheng.yu@intel.com>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Indirect branch tracking provides an optional legacy code bitmap
that indicates locations of non-IBT compatible code.  When set,
each bit in the bitmap represents a page in the linear address is
legacy code.

We allocate the bitmap only when the application requests it.
Most applications do not need the bitmap.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/kernel/cet.c | 45 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 6adfe795d692..a65d9745af08 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -314,3 +314,48 @@ void cet_disable_ibt(void)
 	wrmsrl(MSR_IA32_U_CET, r);
 	current->thread.cet.ibt_enabled = 0;
 }
+
+int cet_setup_ibt_bitmap(void)
+{
+	u64 r;
+	unsigned long bitmap;
+	unsigned long size;
+
+	if (!cpu_feature_enabled(X86_FEATURE_IBT))
+		return -EOPNOTSUPP;
+
+	if (!current->thread.cet.ibt_bitmap_addr) {
+		/*
+		 * Calculate size and put in thread header.
+		 * may_expand_vm() needs this information.
+		 */
+		size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
+		current->thread.cet.ibt_bitmap_size = size;
+		bitmap = do_mmap_locked(0, size, PROT_READ | PROT_WRITE,
+					MAP_ANONYMOUS | MAP_PRIVATE,
+					VM_DONTDUMP);
+
+		if (bitmap >= TASK_SIZE) {
+			current->thread.cet.ibt_bitmap_size = 0;
+			return -ENOMEM;
+		}
+
+		current->thread.cet.ibt_bitmap_addr = bitmap;
+	}
+
+	/*
+	 * Lower bits of MSR_IA32_CET_LEG_IW_EN are for IBT
+	 * settings.  Clear lower bits even bitmap is already
+	 * page-aligned.
+	 */
+	bitmap = current->thread.cet.ibt_bitmap_addr;
+	bitmap &= PAGE_MASK;
+
+	/*
+	 * Turn on IBT legacy bitmap.
+	 */
+	rdmsrl(MSR_IA32_U_CET, r);
+	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
+	wrmsrl(MSR_IA32_U_CET, r);
+	return 0;
+}
-- 
2.17.1

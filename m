Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21022C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9117208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9117208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 479246B02BD; Thu,  6 Jun 2019 16:15:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42D556B02BF; Thu,  6 Jun 2019 16:15:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 207F46B02C0; Thu,  6 Jun 2019 16:15:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6A606B02BD
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so2592131pfv.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=aXgEkBRX3/eV+3WwLvh+MpC5kBqOIXoZ+F2d27hK+18=;
        b=jPOe2n/al4JSOR/RpWhP3K2xbHlsRgAre7050qRpc42TUclrpBOyyYL5kLX83Eiz19
         qRzB1iso7O3YezXV0wso+zj1xBQVolAA6JIn8vLLIUjV7Fmz2Xq/ZN06dk14EF55xlw9
         rLiqITSj0HT1sy+ye6s/4PPLGzITrvp3A/Rhmli31AA7nhbFyZFvIFkPJ5xfbKUlRJNZ
         J38rfaYPZn+mpMZU3tJP+aT9caYg3off1KIARxBmxb1Jwn/+56nC0meDjgOLbujBjucT
         HGRsip6swC8KrXeCb/X1QifR9xRXyrHfohG615vBaR1Dl8Zrj5xbXw8zI+khT+JyOAPF
         569A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW8qTiIa2gOuSwmD5ANsxc5+eddqR4E3+7Go5ZwGPr4/4XYZEhG
	U12cRQwbUUIKN873E5AEseL5L9rw7/meJIIF8tVAVFQgMeiOrHe0cnJY+9Vlv70U0yBC5rUC6e7
	wjUPR7W0trDbjKpbSIQAswdIJ2V2MeScxZBsxTABzSHuFNRreuieGsGILacC52aCz/g==
X-Received: by 2002:a62:7656:: with SMTP id r83mr30872202pfc.56.1559852144536;
        Thu, 06 Jun 2019 13:15:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTYPOqMoCHOsty0W6NEZxRvEGAh7g7oS2zlBDbLbnq7Kvye+unQVydObwW00dgMGbet1zT
X-Received: by 2002:a62:7656:: with SMTP id r83mr30872102pfc.56.1559852143118;
        Thu, 06 Jun 2019 13:15:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852143; cv=none;
        d=google.com; s=arc-20160816;
        b=R8sU+lDaZcczuy+zpoWu2sFAYw3LC+0rOW7pK87/Fz0YFKgJw/tBzoT3l+v573sHAs
         0iqI2hRqS5EqmwTri5PvWvUpspUlqpRE30NH/BGlPbWF55jRV8aQXVRWDnBpEOuS4k11
         7edrJAiDdJ0uMVh7dCoNEyUYJBbOKLh61tOeLd2xI+rI7LwoQ/G+M9yJN9N3Qy8VVlJn
         z+utTCkw0L1FseuNRAlxwjV0OCtwK+/tB4IkXepYSNP9wgcGgqjLkZzi9UR62AOVC1TM
         Jc+nyIfdtuQZkPpPPhQkoasyx82v+kLASTb+ICMLYQaxzacxIXPAbrrsFzIMbbip1yKF
         UHPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=aXgEkBRX3/eV+3WwLvh+MpC5kBqOIXoZ+F2d27hK+18=;
        b=MZkkK8kMl8ELGe96hXzBhYoH5ucFZ2DVa07KfNb+cNVvoZjJVbYgHonlqbG6ONidHB
         sYOxxyVIMs851OmVmnJYpb52NHK5iKETys+Kv7ZfHF0Oe38KhTGGC2oRIvMhSrZjgGrX
         /k07EvYdYLC4L5A7XQKHkMpyds3ms8aYzbBA+g71MH5BpKn8uox6fltvtBiZZqQ6FUhq
         JxmqzBVtITmKJCIrtkqDl/2WFOvqFMuDKR4Yb+K3xts//7Ti0QGiiuEq+bXsfhirUvvl
         uCao4i0RBp2y/EmZPoKDM3JkaHue8SJJGJTY+MdSKPDKuZY9tr9LK3hMYLjSBvELP5xz
         OwZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:42 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:41 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 26/27] x86/cet/shstk: Add arch_prctl functions for Shadow Stack
Date: Thu,  6 Jun 2019 13:06:45 -0700
Message-Id: <20190606200646.3951-27-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

arch_prctl(ARCH_X86_CET_STATUS, unsigned long *addr)
    Return CET feature status.

    The parameter 'addr' is a pointer to a user buffer.
    On returning to the caller, the kernel fills the following
    information:

    *addr = SHSTK/IBT status
    *(addr + 1) = SHSTK base address
    *(addr + 2) = SHSTK size

arch_prctl(ARCH_X86_CET_DISABLE, unsigned long features)
    Disable CET features specified in 'features'.  Return
    -EPERM if CET is locked.

arch_prctl(ARCH_X86_CET_LOCK)
    Lock in CET feature.

arch_prctl(ARCH_X86_CET_ALLOC_SHSTK, unsigned long *addr)
    Allocate a new SHSTK.

    The parameter 'addr' is a pointer to a user buffer and indicates
    the desired SHSTK size to allocate.  On returning to the caller
    the buffer contains the address of the new SHSTK.

There is no CET enabling arch_prctl function.  By design, CET is
enabled automatically if the binary and the system can support it.

The parameters passed are always unsigned 64-bit.  When an ia32
application passing pointers, it should only use the lower 32 bits.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h        |  5 ++
 arch/x86/include/uapi/asm/prctl.h |  5 ++
 arch/x86/kernel/Makefile          |  2 +-
 arch/x86/kernel/cet.c             | 29 +++++++++++
 arch/x86/kernel/cet_prctl.c       | 85 +++++++++++++++++++++++++++++++
 arch/x86/kernel/process.c         |  4 +-
 6 files changed, 127 insertions(+), 3 deletions(-)
 create mode 100644 arch/x86/kernel/cet_prctl.c

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 52c506a68848..2df357dffd24 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -14,19 +14,24 @@ struct sc_ext;
 struct cet_status {
 	unsigned long	shstk_base;
 	unsigned long	shstk_size;
+	unsigned int	locked:1;
 	unsigned int	shstk_enabled:1;
 };
 
 #ifdef CONFIG_X86_INTEL_CET
+int prctl_cet(int option, unsigned long arg2);
 int cet_setup_shstk(void);
 int cet_setup_thread_shstk(struct task_struct *p);
+int cet_alloc_shstk(unsigned long *arg);
 void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(bool ia32, struct sc_ext *sc);
 int cet_setup_signal(bool ia32, unsigned long rstor, struct sc_ext *sc);
 #else
+static inline int prctl_cet(int option, unsigned long arg2) { return -EINVAL; }
 static inline int cet_setup_shstk(void) { return -EINVAL; }
 static inline int cet_setup_thread_shstk(struct task_struct *p) { return 0; }
+static inline int cet_alloc_shstk(unsigned long *arg) { return -EINVAL; }
 static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(bool ia32, struct sc_ext *sc) { return -EINVAL; }
diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index 5a6aac9fa41f..d962f0ec9ccf 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -14,4 +14,9 @@
 #define ARCH_MAP_VDSO_32	0x2002
 #define ARCH_MAP_VDSO_64	0x2003
 
+#define ARCH_X86_CET_STATUS		0x3001
+#define ARCH_X86_CET_DISABLE		0x3002
+#define ARCH_X86_CET_LOCK		0x3003
+#define ARCH_X86_CET_ALLOC_SHSTK	0x3004
+
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 584ed7e9a599..d908c95306fc 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -140,7 +140,7 @@ obj-$(CONFIG_UNWINDER_ORC)		+= unwind_orc.o
 obj-$(CONFIG_UNWINDER_FRAME_POINTER)	+= unwind_frame.o
 obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o
 
-obj-$(CONFIG_X86_INTEL_CET)		+= cet.o
+obj-$(CONFIG_X86_INTEL_CET)		+= cet.o cet_prctl.o
 
 ###
 # 64 bit specific files
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 9ef1af617d38..0004333f8373 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -127,6 +127,35 @@ static int create_rstor_token(bool ia32, unsigned long ssp,
 	return 0;
 }
 
+int cet_alloc_shstk(unsigned long *arg)
+{
+	unsigned long len = *arg;
+	unsigned long addr;
+	unsigned long token;
+	unsigned long ssp;
+
+	addr = do_mmap_locked(0, len, PROT_READ,
+			      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK);
+	if (addr >= TASK_SIZE_MAX)
+		return -ENOMEM;
+
+	/* Restore token is 8 bytes and aligned to 8 bytes */
+	ssp = addr + len;
+	token = ssp;
+
+	if (!in_ia32_syscall())
+		token |= TOKEN_MODE_64;
+	ssp -= 8;
+
+	if (write_user_shstk_64(ssp, token)) {
+		vm_munmap(addr, len);
+		return -EINVAL;
+	}
+
+	*arg = addr;
+	return 0;
+}
+
 int cet_setup_shstk(void)
 {
 	unsigned long addr, size;
diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
new file mode 100644
index 000000000000..9c9d4262b07e
--- /dev/null
+++ b/arch/x86/kernel/cet_prctl.c
@@ -0,0 +1,85 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#include <linux/errno.h>
+#include <linux/uaccess.h>
+#include <linux/prctl.h>
+#include <linux/compat.h>
+#include <linux/mman.h>
+#include <linux/elfcore.h>
+#include <asm/processor.h>
+#include <asm/prctl.h>
+#include <asm/cet.h>
+
+/* See Documentation/x86/intel_cet.rst. */
+
+static int handle_get_status(unsigned long arg2)
+{
+	unsigned int features = 0;
+	unsigned long shstk_base, shstk_size;
+	unsigned long buf[3];
+
+	if (current->thread.cet.shstk_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+
+	shstk_base = current->thread.cet.shstk_base;
+	shstk_size = current->thread.cet.shstk_size;
+
+	buf[0] = (unsigned long)features;
+	buf[1] = shstk_base;
+	buf[2] = shstk_size;
+	return copy_to_user((unsigned long __user *)arg2, buf,
+			    sizeof(buf));
+}
+
+static int handle_alloc_shstk(unsigned long arg2)
+{
+	int err = 0;
+	unsigned long arg;
+	unsigned long addr = 0;
+	unsigned long size = 0;
+
+	if (get_user(arg, (unsigned long __user *)arg2))
+		return -EFAULT;
+
+	size = arg;
+	err = cet_alloc_shstk(&arg);
+	if (err)
+		return err;
+
+	addr = arg;
+	if (put_user(addr, (unsigned long __user *)arg2)) {
+		vm_munmap(addr, size);
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+int prctl_cet(int option, unsigned long arg2)
+{
+	if (!cpu_x86_cet_enabled())
+		return -EINVAL;
+
+	switch (option) {
+	case ARCH_X86_CET_STATUS:
+		return handle_get_status(arg2);
+
+	case ARCH_X86_CET_DISABLE:
+		if (current->thread.cet.locked)
+			return -EPERM;
+		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
+			cet_disable_free_shstk(current);
+
+		return 0;
+
+	case ARCH_X86_CET_LOCK:
+		current->thread.cet.locked = 1;
+		return 0;
+
+	case ARCH_X86_CET_ALLOC_SHSTK:
+		return handle_alloc_shstk(arg2);
+
+	default:
+		return -EINVAL;
+	}
+}
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 58b1c52b38b5..e0090f2790df 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -873,7 +873,7 @@ long do_arch_prctl_common(struct task_struct *task, int option,
 		return get_cpuid_mode();
 	case ARCH_SET_CPUID:
 		return set_cpuid_mode(task, cpuid_enabled);
+	default:
+		return prctl_cet(option, cpuid_enabled);
 	}
-
-	return -EINVAL;
 }
-- 
2.17.1


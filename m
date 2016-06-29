Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 339836B0262
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:59:03 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id at7so95964463obd.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:59:03 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0132.outbound.protection.outlook.com. [104.47.0.132])
        by mx.google.com with ESMTPS id l39si2526277ote.168.2016.06.29.03.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Jun 2016 03:59:02 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Date: Wed, 29 Jun 2016 13:57:33 +0300
Message-ID: <20160629105736.15017-4-dsafonov@virtuozzo.com>
In-Reply-To: <20160629105736.15017-1-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, linux-mm@kvack.org, mingo@redhat.com, luto@amacapital.net, gorcunov@openvz.org, xemul@virtuozzo.com, oleg@redhat.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Add API to change vdso blob type with arch_prctl.
As this is usefull only by needs of CRIU, expose
this interface under CONFIG_CHECKPOINT_RESTORE.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: x86@kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/uapi/asm/prctl.h |  6 ++++++
 arch/x86/kernel/process_64.c      | 10 ++++++++++
 2 files changed, 16 insertions(+)

diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index 3ac5032fae09..ae135de547f5 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -6,4 +6,10 @@
 #define ARCH_GET_FS 0x1003
 #define ARCH_GET_GS 0x1004
 
+#ifdef CONFIG_CHECKPOINT_RESTORE
+# define ARCH_MAP_VDSO_X32	0x2001
+# define ARCH_MAP_VDSO_32	0x2002
+# define ARCH_MAP_VDSO_64	0x2003
+#endif
+
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 6e789ca1f841..64459c88b3d9 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -49,6 +49,7 @@
 #include <asm/debugreg.h>
 #include <asm/switch_to.h>
 #include <asm/xen/hypervisor.h>
+#include <asm/vdso.h>
 
 asmlinkage extern void ret_from_fork(void);
 
@@ -577,6 +578,15 @@ long do_arch_prctl(struct task_struct *task, int code, unsigned long addr)
 		break;
 	}
 
+#ifdef CONFIG_CHECKPOINT_RESTORE
+	case ARCH_MAP_VDSO_X32:
+		return do_map_vdso(VDSO_X32, addr, false);
+	case ARCH_MAP_VDSO_32:
+		return do_map_vdso(VDSO_32, addr, false);
+	case ARCH_MAP_VDSO_64:
+		return do_map_vdso(VDSO_64, addr, false);
+#endif
+
 	default:
 		ret = -EINVAL;
 		break;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

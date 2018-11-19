Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA5D6B1CB4
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:55:00 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so18932668pgc.3
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:55:00 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s8si4586261plq.345.2018.11.19.13.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 13:54:59 -0800 (PST)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v6 05/11] x86/cet/ibt: ELF header parsing for IBT
Date: Mon, 19 Nov 2018 13:49:28 -0800
Message-Id: <20181119214934.6174-6-yu-cheng.yu@intel.com>
In-Reply-To: <20181119214934.6174-1-yu-cheng.yu@intel.com>
References: <20181119214934.6174-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Look in .note.gnu.property of an ELF file and check if Indirect
Branch Tracking needs to be enabled for the task.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/uapi/asm/elf_property.h | 1 +
 arch/x86/kernel/elf.c                    | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/arch/x86/include/uapi/asm/elf_property.h b/arch/x86/include/uapi/asm/elf_property.h
index af361207718c..343a871b8fc1 100644
--- a/arch/x86/include/uapi/asm/elf_property.h
+++ b/arch/x86/include/uapi/asm/elf_property.h
@@ -11,5 +11,6 @@
  * Bits for GNU_PROPERTY_X86_FEATURE_1_AND
  */
 #define GNU_PROPERTY_X86_FEATURE_1_SHSTK	(0x00000002)
+#define GNU_PROPERTY_X86_FEATURE_1_IBT		(0x00000001)
 
 #endif /* _UAPI_ASM_X86_ELF_PROPERTY_H */
diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
index 60e396e2abe9..7727b9332097 100644
--- a/arch/x86/kernel/elf.c
+++ b/arch/x86/kernel/elf.c
@@ -353,6 +353,11 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 		}
 	}
 
+	if (cpu_feature_enabled(X86_FEATURE_IBT)) {
+		if (feature & GNU_PROPERTY_X86_FEATURE_1_IBT)
+			err = cet_setup_ibt();
+	}
+
 out:
 	return err;
 }
-- 
2.17.1

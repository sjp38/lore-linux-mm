Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F37D6B0293
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 26so15838609pfs.22
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:27 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p89si16145686pfj.113.2017.11.22.16.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:26 -0800 (PST)
Subject: [PATCH 20/23] x86, kaiser: add a function to check for KAISER being enabled
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:35:18 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003518.B7D81B14@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Currently, all of the checks for KAISER are compile-time checks.

Runtime checks are needed for turning it on/off at runtime.

Add a function to do that.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/kaiser.h |    5 +++++
 b/include/linux/kaiser.h        |    5 +++++
 2 files changed, 10 insertions(+)

diff -puN arch/x86/include/asm/kaiser.h~kaiser-dynamic-check-func arch/x86/include/asm/kaiser.h
--- a/arch/x86/include/asm/kaiser.h~kaiser-dynamic-check-func	2017-11-22 15:45:55.262619723 -0800
+++ b/arch/x86/include/asm/kaiser.h	2017-11-22 15:45:55.267619723 -0800
@@ -56,6 +56,11 @@ extern void kaiser_remove_mapping(unsign
  */
 extern void kaiser_init(void);
 
+static inline bool kaiser_active(void)
+{
+	extern int kaiser_enabled;
+	return kaiser_enabled;
+}
 #endif
 
 #endif /* __ASSEMBLY__ */
diff -puN include/linux/kaiser.h~kaiser-dynamic-check-func include/linux/kaiser.h
--- a/include/linux/kaiser.h~kaiser-dynamic-check-func	2017-11-22 15:45:55.264619723 -0800
+++ b/include/linux/kaiser.h	2017-11-22 15:45:55.268619723 -0800
@@ -28,5 +28,10 @@ static inline int kaiser_add_mapping(uns
 static inline void kaiser_add_mapping_cpu_entry(int cpu)
 {
 }
+
+static inline bool kaiser_active(void)
+{
+	return 0;
+}
 #endif /* !CONFIG_KAISER */
 #endif /* _INCLUDE_KAISER_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E2860828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:46 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so15916589pff.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:46 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id tj2si14588153pab.76.2016.01.08.15.15.46
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:46 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 07/13] x86/mm: Add nopcid to turn off PCID
Date: Fri,  8 Jan 2016 15:15:25 -0800
Message-Id: <7752daf506becd3b36e768bd2561f562f64d9d16.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

The parameter is only present on x86_64 systems to save a few bytes,
as PCID is always disabled on x86_32.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 Documentation/kernel-parameters.txt |  2 ++
 arch/x86/kernel/cpu/common.c        | 18 ++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index b34e55e00bae..2f61809706c5 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2544,6 +2544,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	nopat		[X86] Disable PAT (page attribute table extension of
 			pagetables) support.
 
+	nopcid		[X86-64] Disable the PCID cpu feature.
+
 	norandmaps	Don't use address space randomization.  Equivalent to
 			echo 0 > /proc/sys/kernel/randomize_va_space
 
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 48196980c1c7..7e1fc53a4ba5 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -162,6 +162,24 @@ static int __init x86_mpx_setup(char *s)
 }
 __setup("nompx", x86_mpx_setup);
 
+#ifdef CONFIG_X86_64
+static int __init x86_pcid_setup(char *s)
+{
+	/* require an exact match without trailing characters */
+	if (strlen(s))
+		return 0;
+
+	/* do not emit a message if the feature is not present */
+	if (!boot_cpu_has(X86_FEATURE_PCID))
+		return 1;
+
+	setup_clear_cpu_cap(X86_FEATURE_PCID);
+	pr_info("nopcid: PCID feature disabled\n");
+	return 1;
+}
+__setup("nopcid", x86_pcid_setup);
+#endif
+
 static int __init x86_noinvpcid_setup(char *s)
 {
 	/* noinvpcid doesn't accept parameters */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

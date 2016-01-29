Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CB5036B025E
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:43:06 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so46072695pac.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:43:06 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id x9si5089817pas.214.2016.01.29.11.43.05
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 11:43:06 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 2/3] x86/mm: Add a noinvpcid option to turn off INVPCID
Date: Fri, 29 Jan 2016 11:42:58 -0800
Message-Id: <f586317ed1bc2b87aee652267e515b90051af385.1454096309.git.luto@kernel.org>
In-Reply-To: <cover.1454096309.git.luto@kernel.org>
References: <cover.1454096309.git.luto@kernel.org>
In-Reply-To: <cover.1454096309.git.luto@kernel.org>
References: <cover.1454096309.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>

This adds a chicken bit to turn off INVPCID in case something goes
wrong.  It's an early_param because we do TLB flushes before we
parse __setup parameters.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 Documentation/kernel-parameters.txt |  2 ++
 arch/x86/kernel/cpu/common.c        | 16 ++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 742f69d18fc8..b34e55e00bae 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2508,6 +2508,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	nointroute	[IA-64]
 
+	noinvpcid	[X86] Disable the INVPCID cpu feature.
+
 	nojitter	[IA-64] Disables jitter checking for ITC timers.
 
 	no-kvmclock	[X86,KVM] Disable paravirtualized KVM clock driver
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index c2b7522cbf35..48196980c1c7 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -162,6 +162,22 @@ static int __init x86_mpx_setup(char *s)
 }
 __setup("nompx", x86_mpx_setup);
 
+static int __init x86_noinvpcid_setup(char *s)
+{
+	/* noinvpcid doesn't accept parameters */
+	if (s)
+		return -EINVAL;
+
+	/* do not emit a message if the feature is not present */
+	if (!boot_cpu_has(X86_FEATURE_INVPCID))
+		return 0;
+
+	setup_clear_cpu_cap(X86_FEATURE_INVPCID);
+	pr_info("noinvpcid: INVPCID feature disabled\n");
+	return 0;
+}
+early_param("noinvpcid", x86_noinvpcid_setup);
+
 #ifdef CONFIG_X86_32
 static int cachesize_override = -1;
 static int disable_x86_serial_nr = 1;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEFF06B0313
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:37:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id n188so174048841oig.3
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:37:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k103si13603981otk.169.2017.06.05.15.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:37:11 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 08/11] x86/mm: Add nopcid to turn off PCID
Date: Mon,  5 Jun 2017 15:36:32 -0700
Message-Id: <d4eafd524ee51d003d7f7302d5e4e44dc4919e08.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

The parameter is only present on x86_64 systems to save a few bytes,
as PCID is always disabled on x86_32.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 Documentation/admin-guide/kernel-parameters.txt |  2 ++
 arch/x86/kernel/cpu/common.c                    | 18 ++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 15f79c27748d..9e2ec142dc7e 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2639,6 +2639,8 @@
 	nopat		[X86] Disable PAT (page attribute table extension of
 			pagetables) support.
 
+	nopcid		[X86-64] Disable the PCID cpu feature.
+
 	norandmaps	Don't use address space randomization.  Equivalent to
 			echo 0 > /proc/sys/kernel/randomize_va_space
 
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index c8b39870f33e..904485e7b230 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -168,6 +168,24 @@ static int __init x86_mpx_setup(char *s)
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

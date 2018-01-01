Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 417A56B0261
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 09:28:44 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so13747055wmd.0
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 06:28:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j32si26076816wre.435.2018.01.01.06.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 06:28:43 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 30/63] x86/mm: Add the nopcid boot option to turn off PCID
Date: Mon,  1 Jan 2018 15:24:48 +0100
Message-Id: <20180101140047.694473930@linuxfoundation.org>
In-Reply-To: <20180101140042.456380281@linuxfoundation.org>
References: <20180101140042.456380281@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit 0790c9aad84901ca1bdc14746175549c8b5da215 upstream.

The parameter is only present on x86_64 systems to save a few bytes,
as PCID is always disabled on x86_32.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/8bbb2e65bcd249a5f18bfb8128b4689f08ac2b60.1498751203.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 Documentation/kernel-parameters.txt |    2 ++
 arch/x86/kernel/cpu/common.c        |   18 ++++++++++++++++++
 2 files changed, 20 insertions(+)

--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2555,6 +2555,8 @@ bytes respectively. Such letter suffixes
 	nopat		[X86] Disable PAT (page attribute table extension of
 			pagetables) support.
 
+	nopcid		[X86-64] Disable the PCID cpu feature.
+
 	norandmaps	Don't use address space randomization.  Equivalent to
 			echo 0 > /proc/sys/kernel/randomize_va_space
 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

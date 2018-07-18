Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC566B02AF
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d5-v6so1699856edq.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:42 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p5-v6si2761541eda.158.2018.07.18.02.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:41 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 38/39] x86/mm/pti: Add Warning when booting on a PCID capable CPU
Date: Wed, 18 Jul 2018 11:41:15 +0200
Message-Id: <1531906876-13451-39-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Warn the user in case the performance can be significantly
improved by switching to a 64-bit kernel.

Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index b879ccd..be8d2cd 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -517,6 +517,28 @@ void __init pti_init(void)
 
 	pr_info("enabled\n");
 
+#ifdef CONFIG_X86_32
+	/*
+	 * We check for X86_FEATURE_PCID here. But the init-code will
+	 * clear the feature flag on 32 bit because the feature is not
+	 * supported on 32 bit anyway. To print the warning we need to
+	 * check with cpuid directly again.
+	 */
+	if (cpuid_ecx(0x1) && BIT(17)) {
+		/* Use printk to work around pr_fmt() */
+		printk(KERN_WARNING "\n");
+		printk(KERN_WARNING "************************************************************\n");
+		printk(KERN_WARNING "** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!  **\n");
+		printk(KERN_WARNING "**                                                        **\n");
+		printk(KERN_WARNING "** You are using 32-bit PTI on a 64-bit PCID-capable CPU. **\n");
+		printk(KERN_WARNING "** Your performance will increase dramatically if you     **\n");
+		printk(KERN_WARNING "** switch to a 64-bit kernel!                             **\n");
+		printk(KERN_WARNING "**                                                        **\n");
+		printk(KERN_WARNING "** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!  **\n");
+		printk(KERN_WARNING "************************************************************\n");
+	}
+#endif
+
 	pti_clone_user_shared();
 
 	/* Undo all global bits from the init pagetables in head_64.S: */
-- 
2.7.4

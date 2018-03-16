Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13E996B025F
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:30:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j28so5916578wrd.17
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:30:14 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id y62si707056eda.304.2018.03.16.12.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:30:12 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 34/35] x86/mm/pti: Add Warning when booting on a PCID capable CPU
Date: Fri, 16 Mar 2018 20:29:52 +0100
Message-Id: <1521228593-3820-35-git-send-email-joro@8bytes.org>
In-Reply-To: <1521228593-3820-1-git-send-email-joro@8bytes.org>
References: <1521228593-3820-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Warn the user in case the performance can be significantly
improved by switching to a 64-bit kernel.

Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 3ffd923..8f5aa0d 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -385,6 +385,22 @@ void __init pti_init(void)
 
 	pr_info("enabled\n");
 
+#ifdef CONFIG_X86_32
+	if (boot_cpu_has(X86_FEATURE_PCID)) {
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
 	pti_clone_entry_text();
 	pti_setup_espfix64();
-- 
2.7.4

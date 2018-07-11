Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C44976B0291
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:30:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n2-v6so9876590edr.5
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:30:21 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id x17-v6si2934371edl.345.2018.07.11.04.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 04:30:20 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 30/39] x86/mm/pti: Clone entry-text again in pti_finalize()
Date: Wed, 11 Jul 2018 13:29:37 +0200
Message-Id: <1531308586-29340-31-git-send-email-joro@8bytes.org>
In-Reply-To: <1531308586-29340-1-git-send-email-joro@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The mapping for entry-text might have changed in the kernel
after it was cloned to the user page-table. Clone again
to update the user page-table to bring the mapping in sync
with the kernel again.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 1825f30..b879ccd 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -404,7 +404,7 @@ static void __init pti_setup_espfix64(void)
 /*
  * Clone the populated PMDs of the entry and irqentry text and force it RO.
  */
-static void __init pti_clone_entry_text(void)
+static void pti_clone_entry_text(void)
 {
 	pti_clone_pmds((unsigned long) __entry_text_start,
 			(unsigned long) __irqentry_text_end,
@@ -528,13 +528,18 @@ void __init pti_init(void)
 }
 
 /*
- * Finalize the kernel mappings in the userspace page-table.
+ * Finalize the kernel mappings in the userspace page-table. Some of the
+ * mappings for the kernel image might have changed since pti_init()
+ * cloned them. This is because parts of the kernel image have been
+ * mapped RO and/or NX.  These changes need to be cloned again to the
+ * userspace page-table.
  */
 void pti_finalize(void)
 {
 	/*
-	 * Do this after all of the manipulation of the
-	 * kernel text page tables are complete.
+	 * We need to clone everything (again) that maps parts of the
+	 * kernel image.
 	 */
+	pti_clone_entry_text();
 	pti_clone_kernel_text();
 }
-- 
2.7.4

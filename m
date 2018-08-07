Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10A446B0010
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 06:24:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h26-v6so5231716eds.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 03:24:41 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id e17-v6si1142776edd.409.2018.08.07.03.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 03:24:39 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 1/3] x86/mm/pti: Fix 32 bit PCID check
Date: Tue,  7 Aug 2018 12:24:29 +0200
Message-Id: <1533637471-30953-2-git-send-email-joro@8bytes.org>
In-Reply-To: <1533637471-30953-1-git-send-email-joro@8bytes.org>
References: <1533637471-30953-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The check uses the wrong operator and causes false positive
warnings in the kernel log on some systems.

Fixes: 5e8105950a8b3 ('x86/mm/pti: Add Warning when booting on a PCID capable CPU')
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index ef8db6f..113ba14 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -549,7 +549,7 @@ void __init pti_init(void)
 	 * supported on 32 bit anyway. To print the warning we need to
 	 * check with cpuid directly again.
 	 */
-	if (cpuid_ecx(0x1) && BIT(17)) {
+	if (cpuid_ecx(0x1) & BIT(17)) {
 		/* Use printk to work around pr_fmt() */
 		printk(KERN_WARNING "\n");
 		printk(KERN_WARNING "************************************************************\n");
-- 
2.7.4

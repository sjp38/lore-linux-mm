Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6350A6B0286
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d30-v6so1705376edd.0
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:35 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id g10-v6si2611753edi.309.2018.07.18.02.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:34 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 24/39] x86/mm/pti: Add an overflow check to pti_clone_pmds()
Date: Wed, 18 Jul 2018 11:41:01 +0200
Message-Id: <1531906876-13451-25-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The addr counter will overflow if we clone the last PMD of
the address space, resulting in an endless loop.

Check for that and bail out of the loop when it happens.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index f512222..dc02fd4 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -297,6 +297,10 @@ pti_clone_pmds(unsigned long start, unsigned long end, pmdval_t clear)
 		p4d_t *p4d;
 		pud_t *pud;
 
+		/* Overflow check */
+		if (addr < start)
+			break;
+
 		pgd = pgd_offset_k(addr);
 		if (WARN_ON(pgd_none(*pgd)))
 			return;
-- 
2.7.4

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6EF6B000A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 11:48:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r9-v6so3276194edh.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:48:23 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id f20-v6si4976447eda.234.2018.07.25.08.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 08:48:22 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 3/3] x86/kexec: Allocate 8k PGDs for PTI
Date: Wed, 25 Jul 2018 17:48:03 +0200
Message-Id: <1532533683-5988-4-git-send-email-joro@8bytes.org>
In-Reply-To: <1532533683-5988-1-git-send-email-joro@8bytes.org>
References: <1532533683-5988-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Fuzzing the PTI-x86-32 code with trinity showed unhandled
kernel paging request oops-messages that looked a lot like
silent data corruption.

Lot's of debugging and testing lead to the kexec-32bit code,
which is still allocating 4k PGDs when PTI is enabled. But
since it uses native_set_pud() to build the page-table, it
will unevitably call into __pti_set_user_pgtbl(), which
writes beyond the allocated 4k page.

Use PGD_ALLOCATION_ORDER to allocate PGDs in the kexec code
to fix the issue.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/kernel/machine_kexec_32.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/machine_kexec_32.c b/arch/x86/kernel/machine_kexec_32.c
index d1ab07e..5409c28 100644
--- a/arch/x86/kernel/machine_kexec_32.c
+++ b/arch/x86/kernel/machine_kexec_32.c
@@ -56,7 +56,7 @@ static void load_segments(void)
 
 static void machine_kexec_free_page_tables(struct kimage *image)
 {
-	free_page((unsigned long)image->arch.pgd);
+	free_pages((unsigned long)image->arch.pgd, PGD_ALLOCATION_ORDER);
 	image->arch.pgd = NULL;
 #ifdef CONFIG_X86_PAE
 	free_page((unsigned long)image->arch.pmd0);
@@ -72,7 +72,8 @@ static void machine_kexec_free_page_tables(struct kimage *image)
 
 static int machine_kexec_alloc_page_tables(struct kimage *image)
 {
-	image->arch.pgd = (pgd_t *)get_zeroed_page(GFP_KERNEL);
+	image->arch.pgd = (pgd_t *)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
+						    PGD_ALLOCATION_ORDER);
 #ifdef CONFIG_X86_PAE
 	image->arch.pmd0 = (pmd_t *)get_zeroed_page(GFP_KERNEL);
 	image->arch.pmd1 = (pmd_t *)get_zeroed_page(GFP_KERNEL);
-- 
2.7.4

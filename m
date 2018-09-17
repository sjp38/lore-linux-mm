Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC9338E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 06:17:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e15-v6so8392801pfi.5
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 03:17:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l138-v6si16540014pfd.258.2018.09.17.03.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 03:17:40 -0700 (PDT)
Subject: Patch "x86/kexec: Allocate 8k PGDs for PTI" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 17 Sep 2018 12:15:38 +0200
Message-ID: <1537179338141229@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 1532533683-5988-4-git-send-email-joro@8bytes.org, David.Laight@aculab.com, aarcange@redhat.com, acme@kernel.org, alexander.levin@microsoft.com, alexander.shishkin@linux.intel.com, aliguori@amazon.com, boris.ostrovsky@oracle.com, bp@alien8.de, brgerst@gmail.com, daniel.gruss@iaik.tugraz.at, dave.hansen@intel.com, dhgutteridge@sympatico.ca, dvlasenk@redhat.com, eduval@amazon.com, gregkh@linuxfoundation.org, hpa@zytor.com, hughd@google.com, jgross@suse.com, jkosina@suse.cz, jolsa@redhat.comjoro@8bytes.org, jpoimboe@redhat.com, jroedel@suse.de, keescook@google.com, linux-mm@kvack.org, llong@redhat.com, luto@kernel.org, namhyung@kernel.org, pavel@ucw.cz, peterz@infradead.org, tglx@linutronix.de, torvalds@linux-foundation.org, will.deacon@arm.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/kexec: Allocate 8k PGDs for PTI

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-kexec-allocate-8k-pgds-for-pti.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Mon Sep 17 12:15:09 CEST 2018
From: Joerg Roedel <jroedel@suse.de>
Date: Wed, 25 Jul 2018 17:48:03 +0200
Subject: x86/kexec: Allocate 8k PGDs for PTI

From: Joerg Roedel <jroedel@suse.de>

[ Upstream commit ca38dc8f2724d101038b1205122c93a1c7f38f11 ]

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
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: David H. Gutteridge <dhgutteridge@sympatico.ca>
Cc: "H . Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Waiman Long <llong@redhat.com>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: joro@8bytes.org
Link: https://lkml.kernel.org/r/1532533683-5988-4-git-send-email-joro@8bytes.org
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/kernel/machine_kexec_32.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/arch/x86/kernel/machine_kexec_32.c
+++ b/arch/x86/kernel/machine_kexec_32.c
@@ -70,7 +70,7 @@ static void load_segments(void)
 
 static void machine_kexec_free_page_tables(struct kimage *image)
 {
-	free_page((unsigned long)image->arch.pgd);
+	free_pages((unsigned long)image->arch.pgd, PGD_ALLOCATION_ORDER);
 	image->arch.pgd = NULL;
 #ifdef CONFIG_X86_PAE
 	free_page((unsigned long)image->arch.pmd0);
@@ -86,7 +86,8 @@ static void machine_kexec_free_page_tabl
 
 static int machine_kexec_alloc_page_tables(struct kimage *image)
 {
-	image->arch.pgd = (pgd_t *)get_zeroed_page(GFP_KERNEL);
+	image->arch.pgd = (pgd_t *)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
+						    PGD_ALLOCATION_ORDER);
 #ifdef CONFIG_X86_PAE
 	image->arch.pmd0 = (pmd_t *)get_zeroed_page(GFP_KERNEL);
 	image->arch.pmd1 = (pmd_t *)get_zeroed_page(GFP_KERNEL);


Patches currently in stable-queue which might be from jroedel@suse.de are

queue-4.4/x86-kexec-allocate-8k-pgds-for-pti.patch
queue-4.4/iommu-ipmmu-vmsa-fix-allocation-in-atomic-context.patch
queue-4.4/x86-mm-remove-in_nmi-warning-from-vmalloc_fault.patch

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0A56B0007
	for <linux-mm@kvack.org>; Sun, 27 May 2018 10:43:21 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q16-v6so6092092pls.15
        for <linux-mm@kvack.org>; Sun, 27 May 2018 07:43:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m26-v6si27940638pfa.45.2018.05.27.07.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 07:43:19 -0700 (PDT)
Subject: Patch "x86/mm: Do not forbid _PAGE_RW before init for __ro_after_init" has been added to the 4.16-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 27 May 2018 16:33:02 +0200
Message-ID: <1527431582235146@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180406205514.8D898241@viggo.jf.intel.com, aarcange@redhat.com, alexander.levin@microsoft.com, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jgross@suse.com, jpoimboe@redhat.com, keescook@chromium.org, linux-mm@kvack.org, luto@kernel.org, mingo@kernel.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Do not forbid _PAGE_RW before init for __ro_after_init

to the 4.16-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-do-not-forbid-_page_rw-before-init-for-__ro_after_init.patch
and it can be found in the queue-4.16 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun May 27 16:10:02 CEST 2018
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 6 Apr 2018 13:55:14 -0700
Subject: x86/mm: Do not forbid _PAGE_RW before init for __ro_after_init

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit 639d6aafe437a7464399d2a77d006049053df06f ]

__ro_after_init data gets stuck in the .rodata section.  That's normally
fine because the kernel itself manages the R/W properties.

But, if we run __change_page_attr() on an area which is __ro_after_init,
the .rodata checks will trigger and force the area to be immediately
read-only, even if it is early-ish in boot.  This caused problems when
trying to clear the _PAGE_GLOBAL bit for these area in the PTI code:
it cleared _PAGE_GLOBAL like I asked, but also took it up on itself
to clear _PAGE_RW.  The kernel then oopses the next time it wrote to
a __ro_after_init data structure.

To fix this, add the kernel_set_to_readonly check, just like we have
for kernel text, just a few lines below in this function.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20180406205514.8D898241@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/mm/pageattr.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -298,9 +298,11 @@ static inline pgprot_t static_protection
 
 	/*
 	 * The .rodata section needs to be read-only. Using the pfn
-	 * catches all aliases.
+	 * catches all aliases.  This also includes __ro_after_init,
+	 * so do not enforce until kernel_set_to_readonly is true.
 	 */
-	if (within(pfn, __pa_symbol(__start_rodata) >> PAGE_SHIFT,
+	if (kernel_set_to_readonly &&
+	    within(pfn, __pa_symbol(__start_rodata) >> PAGE_SHIFT,
 		   __pa_symbol(__end_rodata) >> PAGE_SHIFT))
 		pgprot_val(forbidden) |= _PAGE_RW;
 


Patches currently in stable-queue which might be from dave.hansen@linux.intel.com are

queue-4.16/x86-mm-do-not-forbid-_page_rw-before-init-for-__ro_after_init.patch

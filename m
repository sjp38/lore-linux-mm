Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E72DA6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 09:22:37 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id b34so2299844plc.2
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:22:37 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e71si1430101pgc.571.2018.02.09.06.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 06:22:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 0/4] x86: 5-level related changes into decompression code
Date: Fri,  9 Feb 2018 17:22:24 +0300
Message-Id: <20180209142228.21231-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

These patcheset is a preparation for boot-time switching between paging
modes. Please apply.

The first patch is pure cosmetic change: it gives file with KASLR helpers
a proper name.

The last three patches bring support of booting into 5-level paging mode if
a bootloader put the kernel above 4G.

Patch 2/4 Renames l5_paging_required() into paging_prepare() and change
interface of the function.
Patch 3/4 Handles allocation of space for trampoline and gets it prepared.
Patch 4/4 Gets trampoline used.

v9:
 - Patch 3 now saves and restores lowmem used for trampoline.

   There was report the patch causes issue on a machine. I suspect it's
   BIOS issue that doesn't report proper bounds of usable lowmem.

   Restoring memory back to oringinal state makes problem go away.
v8:
 - Support switching from 5- to 4-level paging.
v7:
 - Fix booting when 5-level paging is enabled before handing off boot to
   the kernel, like in kexec() case.

Kirill A. Shutemov (4):
  x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
  x86/boot/compressed/64: Introduce paging_prepare()
  x86/boot/compressed/64: Prepare trampoline memory
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
    4G

 arch/x86/boot/compressed/Makefile                  |   2 +-
 arch/x86/boot/compressed/head_64.S                 | 178 ++++++++++++++-------
 .../boot/compressed/{pagetable.c => kaslr_64.c}    |   0
 arch/x86/boot/compressed/pgtable.h                 |  18 +++
 arch/x86/boot/compressed/pgtable_64.c              | 100 ++++++++++--
 5 files changed, 232 insertions(+), 66 deletions(-)
 rename arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} (100%)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

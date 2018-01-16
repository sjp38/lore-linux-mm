Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1766B026A
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:29:03 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v14so1266695wmd.3
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:29:03 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id l25si2317683edf.456.2018.01.16.08.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:39:18 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [RFC PATCH 00/16] PTI support for x86-32
Date: Tue, 16 Jan 2018 17:36:43 +0100
Message-Id: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Hi,

here is my current WIP code to enable PTI on x86-32. It is
still in a pretty early state, but it successfully boots my
KVM guest with PAE and with legacy paging. The existing PTI
code for x86-64 already prepares a lot of the stuff needed
for 32 bit too, thanks for that to all the people involved
in its development :)

The patches are split as follows:

	- 1-3 contain the entry-code changes to enter and
	  exit the kernel via the sysenter trampoline stack.

	- 4-7 are fixes to get the code compile on 32 bit
	  with CONFIG_PAGE_TABLE_ISOLATION=y.

	- 8-14 adapt the existing PTI code to work properly
	  on 32 bit and add the needed parts to 32 bit
	  page-table code.

	- 15 switches PTI on by adding the CR3 switches to
	  kernel entry/exit.

	- 16 enables the Kconfig for all of X86

The code has not run on bare-metal yet, I'll test that in
the next days once I setup a 32 bit box again. I also havn't
tested Wine and DosEMU yet, so this might also be broken.

With that post I'd like to ask for all kinds of constructive
feedback on the approaches I have taken and of course the
many things I broke with it :)

One of the things that are surely broken is XEN_PV support.
I'd appreciate any help with testing and bugfixing on that
front.

So please review and let me know your thoughts.

Thanks,

	Joerg

Joerg Roedel (16):
  x86/entry/32: Rename TSS_sysenter_sp0 to TSS_sysenter_stack
  x86/entry/32: Enter the kernel via trampoline stack
  x86/entry/32: Leave the kernel via the trampoline stack
  x86/pti: Define X86_CR3_PTI_PCID_USER_BIT on x86_32
  x86/pgtable: Move pgdp kernel/user conversion functions to pgtable.h
  x86/mm/ldt: Reserve high address-space range for the LDT
  x86/mm: Move two more functions from pgtable_64.h to pgtable.h
  x86/pgtable/32: Allocate 8k page-tables when PTI is enabled
  x86/mm/pti: Clone CPU_ENTRY_AREA on PMD level on x86_32
  x86/mm/pti: Populate valid user pud entries
  x86/mm/pgtable: Move pti_set_user_pgd() to pgtable.h
  x86/mm/pae: Populate the user page-table with user pgd's
  x86/mm/pti: Add an overflow check to pti_clone_pmds()
  x86/mm/legacy: Populate the user page-table with user pgd's
  x86/entry/32: Switch between kernel and user cr3 on entry/exit
  x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32

 arch/x86/entry/entry_32.S               | 170 +++++++++++++++++++++++++++++---
 arch/x86/include/asm/pgtable-2level.h   |   3 +
 arch/x86/include/asm/pgtable-3level.h   |   3 +
 arch/x86/include/asm/pgtable.h          |  88 +++++++++++++++++
 arch/x86/include/asm/pgtable_32_types.h |   5 +-
 arch/x86/include/asm/pgtable_64.h       |  85 ----------------
 arch/x86/include/asm/processor-flags.h  |   8 +-
 arch/x86/include/asm/switch_to.h        |   6 +-
 arch/x86/kernel/asm-offsets_32.c        |   5 +-
 arch/x86/kernel/cpu/common.c            |   5 +-
 arch/x86/kernel/head_32.S               |  23 ++++-
 arch/x86/kernel/process.c               |   2 -
 arch/x86/kernel/process_32.c            |   6 ++
 arch/x86/mm/pgtable.c                   |  11 ++-
 arch/x86/mm/pti.c                       |  34 ++++++-
 security/Kconfig                        |   2 +-
 16 files changed, 333 insertions(+), 123 deletions(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

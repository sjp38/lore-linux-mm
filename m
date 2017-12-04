Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 722536B0278
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:52:31 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s41so10445402wrc.22
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:52:31 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u33si10455064wrc.46.2017.12.04.08.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:52:30 -0800 (PST)
Message-Id: <20171204150609.416845605@linutronix.de>
Date: Mon, 04 Dec 2017 15:08:02 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 56/60] x86/mm/kpti: Disable native VSYSCALL
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm-kpti--Disable_native_VSYSCALL.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

From: Dave Hansen <dave.hansen@linux.intel.com>

The KERNEL_PAGE_TABLE_ISOLATION code attempts to "poison" the user
portion of the kernel page tables. It detects entries that it wants that it
wants to poison in two ways:

 * Looking for addresses >= PAGE_OFFSET

 * Looking for entries without _PAGE_USER set

But, to allow the _PAGE_USER check to work, it must never be set on
init_mm entries, and an earlier patch in this series ensured that it
will never be set.

The VDSO is at a address >= PAGE_OFFSET and it is also mapped by init_mm.
Because of the earlier, KERNEL_PAGE_TABLE_ISOLATION-enforced restriction,
_PAGE_USER is never set which makes the VDSO unreadable to userspace.

This makes the "NATIVE" case totally unusable since userspace can not even
see the memory any more.  Disable it whenever KERNEL_PAGE_TABLE_ISOLATION
is enabled.

Also add some help text about how KERNEL_PAGE_TABLE_ISOLATION might
affect the emulation case as well.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: keescook@google.com
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: moritz.lipp@iaik.tugraz.at
Cc: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: hughd@google.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: michael.schwarz@iaik.tugraz.at
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: richard.fellner@student.tugraz.at
Link: https://lkml.kernel.org/r/20171123003513.10CAD896@viggo.jf.intel.com

---
 arch/x86/Kconfig |    8 ++++++++
 1 file changed, 8 insertions(+)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2249,6 +2249,9 @@ choice
 
 	config LEGACY_VSYSCALL_NATIVE
 		bool "Native"
+		# The VSYSCALL page comes from the kernel page tables
+		# and is not available when KERNEL_PAGE_TABLE_ISOLATION is enabled.
+		depends on !KERNEL_PAGE_TABLE_ISOLATION
 		help
 		  Actual executable code is located in the fixed vsyscall
 		  address mapping, implementing time() efficiently. Since
@@ -2266,6 +2269,11 @@ choice
 		  exploits. This configuration is recommended when userspace
 		  still uses the vsyscall area.
 
+		  When KERNEL_PAGE_TABLE_ISOLATION is enabled, the vsyscall area will become
+		  unreadable.  This emulation option still works, but KERNEL_PAGE_TABLE_ISOLATION
+		  will make it harder to do things like trace code using the
+		  emulation.
+
 	config LEGACY_VSYSCALL_NONE
 		bool "None"
 		help


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

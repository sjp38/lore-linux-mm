Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D231B440D41
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:32:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id c123so120908pga.17
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:32:37 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a61si9345050plc.406.2017.11.10.11.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:32:36 -0800 (PST)
Subject: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:52 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193152.3F73EABA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The KAISER code attempts to "poison" the user portion of the kernel page
tables.  It detects entries that it wants that it wants to poison in two
ways:
 * Looking for addresses >= PAGE_OFFSET
 * Looking for entries without _PAGE_USER set

But, to allow the _PAGE_USER check to work, it must never be set on
init_mm entries, and an earlier patch in this series ensured that it
will never be set.

The VDSO is at a address >= PAGE_OFFSET and it is also mapped by init_mm.
Because of the earlier, KAISER-enforced restriction, _PAGE_USER is never
set which makes the VDSO unreadable to userspace.

This makes the "NATIVE" case totally unusable since userspace can not
even see the memory any more.  Disable it whenever KAISER is enabled.

Also add some help text about how KAISER might affect the emulation
case as well.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org

---

 b/arch/x86/Kconfig |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -puN arch/x86/Kconfig~kaiser-no-vsyscall arch/x86/Kconfig
--- a/arch/x86/Kconfig~kaiser-no-vsyscall	2017-11-10 11:22:18.366244926 -0800
+++ b/arch/x86/Kconfig	2017-11-10 11:22:18.370244926 -0800
@@ -2231,6 +2231,9 @@ choice
 
 	config LEGACY_VSYSCALL_NATIVE
 		bool "Native"
+		# The VSYSCALL page comes from the kernel page tables
+		# and is not available when KAISER is enabled.
+		depends on ! KAISER
 		help
 		  Actual executable code is located in the fixed vsyscall
 		  address mapping, implementing time() efficiently. Since
@@ -2248,6 +2251,11 @@ choice
 		  exploits. This configuration is recommended when userspace
 		  still uses the vsyscall area.
 
+		  When KAISER is enabled, the vsyscall area will become
+		  unreadable.  This emulation option still works, but KAISER
+		  will make it harder to do things like trace code using the
+		  emulation.
+
 	config LEGACY_VSYSCALL_NONE
 		bool "None"
 		help
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

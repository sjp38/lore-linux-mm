Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76A7F6B028D
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:23 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i89so15857895pfj.9
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:23 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q62si16172571pfd.99.2017.11.22.16.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:22 -0800 (PST)
Subject: [PATCH 18/23] x86, kaiser: disable native VSYSCALL
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:35:13 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003513.10CAD896@viggo.jf.intel.com>
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
--- a/arch/x86/Kconfig~kaiser-no-vsyscall	2017-11-22 15:45:54.196619726 -0800
+++ b/arch/x86/Kconfig	2017-11-22 15:45:54.200619726 -0800
@@ -2249,6 +2249,9 @@ choice
 
 	config LEGACY_VSYSCALL_NATIVE
 		bool "Native"
+		# The VSYSCALL page comes from the kernel page tables
+		# and is not available when KAISER is enabled.
+		depends on ! KAISER
 		help
 		  Actual executable code is located in the fixed vsyscall
 		  address mapping, implementing time() efficiently. Since
@@ -2266,6 +2269,11 @@ choice
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

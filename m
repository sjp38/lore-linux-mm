Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42A776B0304
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g6so3553804pgn.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:44 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id o3si4359313pld.135.2017.11.08.11.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:43 -0800 (PST)
Subject: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:31 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194731.AB5BDA01@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The VSYSCALL page is mapped by kernel page tables at a kernel address.
It is troublesome to support with KAISER in place, so disable the
native case.

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
--- a/arch/x86/Kconfig~kaiser-no-vsyscall	2017-11-08 10:45:39.157681370 -0800
+++ b/arch/x86/Kconfig	2017-11-08 10:45:39.162681370 -0800
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

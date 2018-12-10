Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7C48E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:31:26 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id w4so4747743otj.2
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 06:31:26 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 10si3666053ois.229.2018.12.10.06.31.25
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 06:31:25 -0800 (PST)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Subject: [RFC][PATCH 1/3] elf: Make AT_FLAGS arch configurable
Date: Mon, 10 Dec 2018 14:30:42 +0000
Message-Id: <20181210143044.12714-2-vincenzo.frascino@arm.com>
In-Reply-To: <20181210143044.12714-1-vincenzo.frascino@arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgeniy Stepanov <eugenis@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>

Currently, the AT_FLAGS in the elf auxiliary vector are set to 0
by default by the kernel.
Some architectures might need to expose to the userspace a non-zero
value to advertise some platform specific ABI functionalities.

This patch makes AT_FLAGS configurable by the architectures that
require it.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
---
 fs/binfmt_elf.c        | 6 +++++-
 fs/binfmt_elf_fdpic.c  | 6 +++++-
 fs/compat_binfmt_elf.c | 5 +++++
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 54207327f98f..9fa20cc4a437 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -86,6 +86,10 @@ static int elf_core_dump(struct coredump_params *cprm);
 #define ELF_CORE_EFLAGS	0
 #endif
 
+#ifndef ELF_AT_FLAGS
+#define ELF_AT_FLAGS	0
+#endif
+
 #define ELF_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_MIN_ALIGN-1))
 #define ELF_PAGEOFFSET(_v) ((_v) & (ELF_MIN_ALIGN-1))
 #define ELF_PAGEALIGN(_v) (((_v) + ELF_MIN_ALIGN - 1) & ~(ELF_MIN_ALIGN - 1))
@@ -251,7 +255,7 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	NEW_AUX_ENT(AT_PHENT, sizeof(struct elf_phdr));
 	NEW_AUX_ENT(AT_PHNUM, exec->e_phnum);
 	NEW_AUX_ENT(AT_BASE, interp_load_addr);
-	NEW_AUX_ENT(AT_FLAGS, 0);
+	NEW_AUX_ENT(AT_FLAGS, ELF_AT_FLAGS);
 	NEW_AUX_ENT(AT_ENTRY, exec->e_entry);
 	NEW_AUX_ENT(AT_UID, from_kuid_munged(cred->user_ns, cred->uid));
 	NEW_AUX_ENT(AT_EUID, from_kuid_munged(cred->user_ns, cred->euid));
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index b53bb3729ac1..cf1e680a6b88 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -82,6 +82,10 @@ static int elf_fdpic_map_file_by_direct_mmap(struct elf_fdpic_params *,
 static int elf_fdpic_core_dump(struct coredump_params *cprm);
 #endif
 
+#ifndef ELF_AT_FLAGS
+#define ELF_AT_FLAGS	0
+#endif
+
 static struct linux_binfmt elf_fdpic_format = {
 	.module		= THIS_MODULE,
 	.load_binary	= load_elf_fdpic_binary,
@@ -651,7 +655,7 @@ static int create_elf_fdpic_tables(struct linux_binprm *bprm,
 	NEW_AUX_ENT(AT_PHENT,	sizeof(struct elf_phdr));
 	NEW_AUX_ENT(AT_PHNUM,	exec_params->hdr.e_phnum);
 	NEW_AUX_ENT(AT_BASE,	interp_params->elfhdr_addr);
-	NEW_AUX_ENT(AT_FLAGS,	0);
+	NEW_AUX_ENT(AT_FLAGS,	ELF_AT_FLAGS);
 	NEW_AUX_ENT(AT_ENTRY,	exec_params->entry_addr);
 	NEW_AUX_ENT(AT_UID,	(elf_addr_t) from_kuid_munged(cred->user_ns, cred->uid));
 	NEW_AUX_ENT(AT_EUID,	(elf_addr_t) from_kuid_munged(cred->user_ns, cred->euid));
diff --git a/fs/compat_binfmt_elf.c b/fs/compat_binfmt_elf.c
index 15f6e96b3bd9..a21cf99701ae 100644
--- a/fs/compat_binfmt_elf.c
+++ b/fs/compat_binfmt_elf.c
@@ -79,6 +79,11 @@
 #define	ELF_HWCAP2		COMPAT_ELF_HWCAP2
 #endif
 
+#ifdef	COMPAT_ELF_AT_FLAGS
+#undef	ELF_AT_FLAGS
+#define	ELF_AT_FLAGS		COMPAT_ELF_AT_FLAGS
+#endif
+
 #ifdef	COMPAT_ARCH_DLINFO
 #undef	ARCH_DLINFO
 #define	ARCH_DLINFO		COMPAT_ARCH_DLINFO
-- 
2.19.2

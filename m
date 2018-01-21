Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2377F6B0003
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 18:46:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o16so7019505pgv.3
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 15:46:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor3108058pgp.230.2018.01.21.15.46.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jan 2018 15:46:28 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
Date: Sun, 21 Jan 2018 15:46:24 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com>
 <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

I wanted to see whether segments protection can be a replacement for PTI
(yes, excluding SMEP emulation), or whether speculative execution =
=E2=80=9Cignores=E2=80=9D
limit checks, similarly to the way paging protection is skipped.

It does seem that segmentation provides sufficient protection from =
Meltdown.
The =E2=80=9Creliability=E2=80=9D test of Gratz PoC fails if the segment =
limit is set to
prevent access to the kernel memory. [ It passes if the limit is not =
set,
even if the DS is reloaded. ] My test is enclosed below.

So my question: wouldn=E2=80=99t it be much more efficient to use =
segmentation
protection for x86-32, and allow users to choose whether they want =
SMEP-like
protection if needed (and then enable PTI)?

[ There might be some corner cases in which setting a segment limit
introduces a problem, for example when modify_ldt() is used to set =
invalid
limit, but I presume that these are relatively uncommon, can be detected =
on
runtime, and PTI can then be used as a fallback mechanism. ]

Thanks,
Nadav

-- >8 --
Subject: [PATCH] Test segmentation protection

---
 libkdump/libkdump.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/libkdump/libkdump.c b/libkdump/libkdump.c
index c590391..db5bac3 100644
--- a/libkdump/libkdump.c
+++ b/libkdump/libkdump.c
@@ -10,6 +10,9 @@
 #include <stdarg.h>
 #include <stdlib.h>
 #include <unistd.h>
+#include <assert.h>
+#include <sys/types.h>
+#include <asm/ldt.h>
=20
 libkdump_config_t libkdump_auto_config =3D {0};
=20
@@ -500,6 +503,31 @@ int __attribute__((optimize("-Os"), noinline)) =
libkdump_read_tsx() {
   return 0;
 }
=20
+extern int modify_ldt(int, void*, unsigned long);
+
+void change_ds(void)
+{
+	int r;
+	struct user_desc desc =3D {
+		.entry_number =3D 1,
+		.base_addr =3D 0,
+#ifdef NO_SEGMENTS
+		.limit =3D 0xffffeu,
+#else
+		.limit =3D 0xbffffu,
+#endif
+		.seg_32bit =3D 1,
+		.contents =3D 0,
+		.read_exec_only =3D 0,
+		.limit_in_pages =3D 1,
+		.seg_not_present =3D 0,
+	};
+
+	r =3D modify_ldt(1 /* write */, &desc, sizeof(desc));
+	assert(r =3D=3D 0);
+	asm volatile ("mov %0, %%ds\n\t" : : "r"((1 << 3) | (1 << 2) | =
3));
+}
+
 // =
--------------------------------------------------------------------------=
-
 int __attribute__((optimize("-Os"), noinline)) =
libkdump_read_signal_handler() {
   size_t retries =3D config.retries + 1;
@@ -507,6 +535,9 @@ int __attribute__((optimize("-Os"), noinline)) =
libkdump_read_signal_handler() {
=20
   while (retries--) {
     if (!setjmp(buf)) {
+      /* longjmp reloads the original DS... */
+      change_ds();
+
       MELTDOWN;
     }

Nadav Amit <nadav.amit@gmail.com> wrote:

> Please ignore my previous email. I got it working=E2=80=A6 Sorry for =
the spam.
>=20
>=20
> Nadav Amit <nadav.amit@gmail.com> wrote:
>=20
>> I am looking on PTI on x86-32, but I did not mange to get the PoC to =
work on
>> this setup (kaslr disabled, similar setup works on 64-bit).
>>=20
>> Did you use any PoC to =E2=80=9Ctest=E2=80=9D the protection?
>>=20
>> Thanks,
>> Nadav
>>=20
>>=20
>> Joerg Roedel <joro@8bytes.org> wrote:
>>=20
>>> From: Joerg Roedel <jroedel@suse.de>
>>>=20
>>> Hi,
>>>=20
>>> here is my current WIP code to enable PTI on x86-32. It is
>>> still in a pretty early state, but it successfully boots my
>>> KVM guest with PAE and with legacy paging. The existing PTI
>>> code for x86-64 already prepares a lot of the stuff needed
>>> for 32 bit too, thanks for that to all the people involved
>>> in its development :)
>>>=20
>>> The patches are split as follows:
>>>=20
>>> 	- 1-3 contain the entry-code changes to enter and
>>> 	  exit the kernel via the sysenter trampoline stack.
>>>=20
>>> 	- 4-7 are fixes to get the code compile on 32 bit
>>> 	  with CONFIG_PAGE_TABLE_ISOLATION=3Dy.
>>>=20
>>> 	- 8-14 adapt the existing PTI code to work properly
>>> 	  on 32 bit and add the needed parts to 32 bit
>>> 	  page-table code.
>>>=20
>>> 	- 15 switches PTI on by adding the CR3 switches to
>>> 	  kernel entry/exit.
>>>=20
>>> 	- 16 enables the Kconfig for all of X86
>>>=20
>>> The code has not run on bare-metal yet, I'll test that in
>>> the next days once I setup a 32 bit box again. I also havn't
>>> tested Wine and DosEMU yet, so this might also be broken.
>>>=20
>>> With that post I'd like to ask for all kinds of constructive
>>> feedback on the approaches I have taken and of course the
>>> many things I broke with it :)
>>>=20
>>> One of the things that are surely broken is XEN_PV support.
>>> I'd appreciate any help with testing and bugfixing on that
>>> front.
>>>=20
>>> So please review and let me know your thoughts.
>>>=20
>>> Thanks,
>>>=20
>>> 	Joerg
>>>=20
>>> Joerg Roedel (16):
>>> x86/entry/32: Rename TSS_sysenter_sp0 to TSS_sysenter_stack
>>> x86/entry/32: Enter the kernel via trampoline stack
>>> x86/entry/32: Leave the kernel via the trampoline stack
>>> x86/pti: Define X86_CR3_PTI_PCID_USER_BIT on x86_32
>>> x86/pgtable: Move pgdp kernel/user conversion functions to pgtable.h
>>> x86/mm/ldt: Reserve high address-space range for the LDT
>>> x86/mm: Move two more functions from pgtable_64.h to pgtable.h
>>> x86/pgtable/32: Allocate 8k page-tables when PTI is enabled
>>> x86/mm/pti: Clone CPU_ENTRY_AREA on PMD level on x86_32
>>> x86/mm/pti: Populate valid user pud entries
>>> x86/mm/pgtable: Move pti_set_user_pgd() to pgtable.h
>>> x86/mm/pae: Populate the user page-table with user pgd's
>>> x86/mm/pti: Add an overflow check to pti_clone_pmds()
>>> x86/mm/legacy: Populate the user page-table with user pgd's
>>> x86/entry/32: Switch between kernel and user cr3 on entry/exit
>>> x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32
>>>=20
>>> arch/x86/entry/entry_32.S               | 170 =
+++++++++++++++++++++++++++++---
>>> arch/x86/include/asm/pgtable-2level.h   |   3 +
>>> arch/x86/include/asm/pgtable-3level.h   |   3 +
>>> arch/x86/include/asm/pgtable.h          |  88 +++++++++++++++++
>>> arch/x86/include/asm/pgtable_32_types.h |   5 +-
>>> arch/x86/include/asm/pgtable_64.h       |  85 ----------------
>>> arch/x86/include/asm/processor-flags.h  |   8 +-
>>> arch/x86/include/asm/switch_to.h        |   6 +-
>>> arch/x86/kernel/asm-offsets_32.c        |   5 +-
>>> arch/x86/kernel/cpu/common.c            |   5 +-
>>> arch/x86/kernel/head_32.S               |  23 ++++-
>>> arch/x86/kernel/process.c               |   2 -
>>> arch/x86/kernel/process_32.c            |   6 ++
>>> arch/x86/mm/pgtable.c                   |  11 ++-
>>> arch/x86/mm/pti.c                       |  34 ++++++-
>>> security/Kconfig                        |   2 +-
>>> 16 files changed, 333 insertions(+), 123 deletions(-)
>>>=20
>>> --=20
>>> 2.13.6
>>>=20
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

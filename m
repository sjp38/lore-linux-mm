Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0666B0376
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:27:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 21so185837951pgg.4
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:27:51 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id l1si22036727pld.15.2017.03.21.10.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 10:27:50 -0700 (PDT)
Date: Tue, 21 Mar 2017 10:27:16 -0700
In-Reply-To: <20170321163712.20334-1-dsafonov@virtuozzo.com>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
From: hpa@zytor.com
Message-ID: <43DEF3C4-B248-4720-8088-415C043B74BF@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On March 21, 2017 9:37:12 AM PDT, Dmitry Safonov <dsafonov@virtuozzo=2Ecom>=
 wrote:
>After my changes to mmap(), its code now relies on the bitness of
>performing syscall=2E According to that, it chooses the base of
>allocation:
>mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall=2E
>It was done by:
>  commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>32-bit mmap()")=2E
>
>The code afterwards relies on in_compat_syscall() returning true for
>32-bit syscalls=2E It's usually so while we're in context of application
>that does 32-bit syscalls=2E But during exec() it is not valid for x32
>ELF=2E
>The reason is that the application hasn't yet done any syscall, so x32
>bit has not being set=2E
>That results in -ENOMEM for x32 ELF files as there fired BAD_ADDR()
>in elf_map(), that is called from do_execve()->load_elf_binary()=2E
>For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag=2E
>
>I suggest to set x32 bit before first return to userspace, during
>setting personality at exec()=2E This way we can rely on
>in_compat_syscall() during exec()=2E
>
>Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>32-bit mmap()")
>Cc: 0x7f454c46@gmail=2Ecom
>Cc: linux-mm@kvack=2Eorg
>Cc: Andrei Vagin <avagin@gmail=2Ecom>
>Cc: Cyrill Gorcunov <gorcunov@openvz=2Eorg>
>Cc: Borislav Petkov <bp@suse=2Ede>
>Cc: "Kirill A=2E Shutemov" <kirill=2Eshutemov@linux=2Eintel=2Ecom>
>Cc: x86@kernel=2Eorg
>Cc: H=2E Peter Anvin <hpa@zytor=2Ecom>
>Cc: Andy Lutomirski <luto@kernel=2Eorg>
>Cc: Ingo Molnar <mingo@redhat=2Ecom>
>Cc: Thomas Gleixner <tglx@linutronix=2Ede>
>Reported-by: Adam Borowski <kilobyte@angband=2Epl>
>Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo=2Ecom>
>---
>v2:
>- specifying mmap() allocation path which failed during exec()
>- fix comment style
>
> arch/x86/kernel/process_64=2Ec | 10 ++++++++--
> 1 file changed, 8 insertions(+), 2 deletions(-)
>
>diff --git a/arch/x86/kernel/process_64=2Ec
>b/arch/x86/kernel/process_64=2Ec
>index d6b784a5520d=2E=2Ed3d4d9abcaf8 100644
>--- a/arch/x86/kernel/process_64=2Ec
>+++ b/arch/x86/kernel/process_64=2Ec
>@@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
> 		if (current->mm)
> 			current->mm->context=2Eia32_compat =3D TIF_X32;
> 		current->personality &=3D ~READ_IMPLIES_EXEC;
>-		/* in_compat_syscall() uses the presence of the x32
>-		   syscall bit flag to determine compat status */
>+		/*
>+		 * in_compat_syscall() uses the presence of the x32
>+		 * syscall bit flag to determine compat status=2E
>+		 * On the bitness of syscall relies x86 mmap() code,
>+		 * so set x32 syscall bit right here to make
>+		 * in_compat_syscall() work during exec()=2E
>+		 */
>+		task_pt_regs(current)->orig_ax |=3D __X32_SYSCALL_BIT;
> 		current->thread=2Estatus &=3D ~TS_COMPAT;
> 	} else {
> 		set_thread_flag(TIF_IA32);

You also need to clear the bit for an x32 -> x86-64 exec=2E  Otherwise it =
seems okay to me=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

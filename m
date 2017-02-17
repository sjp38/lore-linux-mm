Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1514405EE
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:50:53 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id 23so26161698vkc.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:50:53 -0800 (PST)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id b22si3363498uag.203.2017.02.17.08.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 08:50:52 -0800 (PST)
Received: by mail-ua0-x22f.google.com with SMTP id x12so33579453uax.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:50:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com> <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 17 Feb 2017 08:50:31 -0800
Message-ID: <CALCETrVKKU_eJVH3scF=89z98dba8iHwuNfdUPE9Hx=-3b_+Pg@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Feb 17, 2017 at 6:13 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> This patch introduces two new prctl(2) handles to manage maximum virtual
> address available to userspace to map.
>
> On x86, 5-level paging enables 56-bit userspace virtual address space.
> Not all user space is ready to handle wide addresses. It's known that
> at least some JIT compilers use higher bits in pointers to encode their
> information. It collides with valid pointers with 5-level paging and
> leads to crashes.
>
> The patch aims to address this compatibility issue.
>
> MM would use the address as upper limit of virtual address available to
> map by userspace, instead of TASK_SIZE.
>
> The limit will be equal to TASK_SIZE everywhere, but the machine
> with 5-level paging enabled. In this case, the default limit would be
> (1UL << 47) - PAGE_SIZE. It=E2=80=99s current x86-64 TASK_SIZE_MAX with 4=
-level
> paging which known to be safe.


I think this patch need to be split up.  In particular, the addition
and use of mmap_max_addr() should be its own patch that doesn't change
any semantics.

> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mm=
u_context.h
> index 306c7e12af55..50bdfd6ab866 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -117,6 +117,7 @@ static inline int init_new_context(struct task_struct=
 *tsk,
>         }
>         #endif
>         init_new_context_ldt(tsk, mm);
> +       mm->context.max_vaddr =3D MAX_VADDR_DEFAULT;

Is this actually correct for 32-bit binaries?  Although, given the
stuff Dmitry is working on, it might pay to separately track the
32-bit and 64-bit limits per mm.  If you haven't been following it,
Dmitry is trying to fix a bug in which an explicit 32-bit syscall
(int80 or similar) in an otherwise 64-bit process can allocate a VMA
above 4GB that gets truncated.

Also, why the macro?  Why not just put the number in here?

> -#define TASK_SIZE_MAX  ((1UL << 47) - PAGE_SIZE)
> +#define TASK_SIZE_MAX  ((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)

This should be in the

> -#define STACK_TOP              TASK_SIZE
> +#define STACK_TOP              mmap_max_addr()

Off the top of my head, this looks wrong.  The 32-bit check got lost, I thi=
nk.

> +unsigned long set_max_vaddr(unsigned long addr)
> +{

Perhaps this function could set a different field depending on
is_compat_syscall().


Anyway, can you and Dmitry try to reconcile your patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

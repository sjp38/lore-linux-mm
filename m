Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E402800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 05:36:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c11so2092302wrb.23
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 02:36:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b36sor4275917ede.7.2018.01.24.02.36.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 02:36:39 -0800 (PST)
Date: Wed, 24 Jan 2018 13:36:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] x86/mm/encrypt: Move sme_populate_pgd*() into
 separate translation unit
Message-ID: <20180124103636.y5udfksagk2ndlzp@node.shutemov.name>
References: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
 <20180123171910.55841-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123171910.55841-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 23, 2018 at 08:19:08PM +0300, Kirill A. Shutemov wrote:
> sme_populate_pgd() and sme_populate_pgd_large() operate on the identity
> mapping, which means they want virtual addresses to be equal to physical
> one, without PAGE_OFFSET shift.
> 
> We also need to avoid paravirtualizaion call there.
> 
> Getting this done is tricky. We cannot use usual page table helpers.
> It forces us to open-code a lot of things. It makes code ugly and hard
> to modify.
> 
> We can get it work with the page table helpers, but it requires few
> preprocessor tricks. These tricks may have side effects for the rest of
> the file.
> 
> Let's isolate sme_populate_pgd() and sme_populate_pgd_large() into own
> translation unit.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/Makefile               |  13 ++--
>  arch/x86/mm/mem_encrypt.c          | 129 -----------------------------------
>  arch/x86/mm/mem_encrypt_identity.c | 134 +++++++++++++++++++++++++++++++++++++
>  arch/x86/mm/mm_internal.h          |  14 ++++
>  4 files changed, 156 insertions(+), 134 deletions(-)
>  create mode 100644 arch/x86/mm/mem_encrypt_identity.c
> 
> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index 27e9e90a8d35..51e364ef12d9 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -1,12 +1,14 @@
>  # SPDX-License-Identifier: GPL-2.0
> -# Kernel does not boot with instrumentation of tlb.c and mem_encrypt.c
> -KCOV_INSTRUMENT_tlb.o		:= n
> -KCOV_INSTRUMENT_mem_encrypt.o	:= n
> +# Kernel does not boot with instrumentation of tlb.c and mem_encrypt*.c
> +KCOV_INSTRUMENT_tlb.o			:= n
> +KCOV_INSTRUMENT_mem_encrypt.o		:= n
> +KCOV_INSTRUMENT_mem_encrypt_identity.o	:= n
>  
> -KASAN_SANITIZE_mem_encrypt.o	:= n
> +KASAN_SANITIZE_mem_encrypt.o		:= n
> +KASAN_SANITIZE_mem_encrypt_identity.o	:= n
>  
>  ifdef CONFIG_FUNCTION_TRACER
> -CFLAGS_REMOVE_mem_encrypt.o	= -pg
> +CFLAGS_REMOVE_mem_encrypt_identity.o	= -pg
>  endif

0day found a boot issue with the commit.

We need to add line on mem_encrypt_identity.o, not replace existing one.

Fixup is below.

diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 51e364ef12d9..03c6c8561623 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -8,6 +8,7 @@ KASAN_SANITIZE_mem_encrypt.o		:= n
 KASAN_SANITIZE_mem_encrypt_identity.o	:= n
 
 ifdef CONFIG_FUNCTION_TRACER
+CFLAGS_REMOVE_mem_encrypt.o		= -pg
 CFLAGS_REMOVE_mem_encrypt_identity.o	= -pg
 endif
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

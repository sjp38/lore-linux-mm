Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5270F2803BB
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 07:29:33 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d202so4668597lfd.11
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 04:29:33 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id z6si4497606lfa.306.2017.08.27.04.29.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Aug 2017 04:29:31 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id g77so2282863lfg.2
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 04:29:31 -0700 (PDT)
Date: Sun, 27 Aug 2017 14:29:26 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCHv5 06/19] x86/boot/compressed/64: Detect and handle
 5-level paging at boot-time
Message-ID: <20170827112926.GA1942@uranus.lan>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
 <20170821152916.40124-7-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170821152916.40124-7-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 21, 2017 at 06:29:03PM +0300, Kirill A. Shutemov wrote:
> This patch prepare decompression code to boot-time switching between 4-
> and 5-level paging.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> index fbf4c32d0b62..2e362aea3319 100644
> --- a/arch/x86/boot/compressed/head_64.S
> +++ b/arch/x86/boot/compressed/head_64.S
> @@ -347,6 +347,28 @@ preferred_addr:
>  	leaq	boot_stack_end(%rbx), %rsp
>  
>  #ifdef CONFIG_X86_5LEVEL
> +	/* Preserve rbx across cpuid */
> +	movq	%rbx, %r8
> +
> +	/* Check if leaf 7 is supported */
> +	movl	$0, %eax

Use xor instead, it should be shorter

> +	cpuid
> +	cmpl	$7, %eax
> +	jb	lvl5
> +
> +	/*
> +	 * Check if la57 is supported.
> +	 * The feature is enumerated with CPUID.(EAX=07H, ECX=0):ECX[bit 16]
> +	 */
> +	movl	$7, %eax
> +	movl	$0, %ecx

same

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

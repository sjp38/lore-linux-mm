Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3923F6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 12:29:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h26-v6so289037eds.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:29:31 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id g8-v6si3759019edg.399.2018.07.30.09.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 09:29:29 -0700 (PDT)
Date: Mon, 30 Jul 2018 18:29:27 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] RFC: clear 1G pages with streaming stores on x86
Message-ID: <20180730162926.GD11890@nazgul.tnic>
References: <20180724210923.GA20168@bombadil.infradead.org>
 <20180725023728.44630-1-cannonmatthews@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180725023728.44630-1-cannonmatthews@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>

On Tue, Jul 24, 2018 at 07:37:28PM -0700, Cannon Matthews wrote:
> diff --git a/arch/x86/lib/clear_page_64.S b/arch/x86/lib/clear_page_64.S
> index 88acd349911b..81a39804ac72 100644
> --- a/arch/x86/lib/clear_page_64.S
> +++ b/arch/x86/lib/clear_page_64.S
> @@ -49,3 +49,23 @@ ENTRY(clear_page_erms)
>  	ret
>  ENDPROC(clear_page_erms)
>  EXPORT_SYMBOL_GPL(clear_page_erms)
> +
> +/*
> + * Zero memory using non temporal stores, bypassing the cache.
> + * Requires an `sfence` (wmb()) afterwards.
> + * %rdi - destination.
> + * %rsi - page size. Must be 64 bit aligned.
> +*/
> +ENTRY(__clear_page_nt)
> +	leaq	(%rdi,%rsi), %rdx
> +	xorl	%eax, %eax
> +	.p2align 4,,10
> +	.p2align 3
> +.L2:
> +	movnti	%rax, (%rdi)
> +	addq	$8, %rdi
> +	cmpq	%rdx, %rdi
> +	jne	.L2
> +	ret
> +ENDPROC(__clear_page_nt)
> +EXPORT_SYMBOL(__clear_page_nt)

EXPORT_SYMBOL_GPL like the other functions in that file.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

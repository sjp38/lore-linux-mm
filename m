Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 09A91828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:56:00 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id yy13so197168082pab.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:56:00 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id p28si8181471pfi.217.2016.01.08.15.55.53
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:55:53 -0800 (PST)
Subject: Re: [RFC 11/13] x86/mm: Build arch/x86/mm/tlb.c even on !SMP
References: <cover.1452294700.git.luto@kernel.org>
 <a6eab8f94f1c6e0134246e4a21aa8af1cb7155fd.1452294700.git.luto@kernel.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <56904C89.8050205@linux.intel.com>
Date: Fri, 8 Jan 2016 15:55:53 -0800
MIME-Version: 1.0
In-Reply-To: <a6eab8f94f1c6e0134246e4a21aa8af1cb7155fd.1452294700.git.luto@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/08/2016 03:15 PM, Andy Lutomirski wrote:
> @@ -352,3 +354,5 @@ static int __init create_tlb_single_page_flush_ceiling(void)
>  	return 0;
>  }
>  late_initcall(create_tlb_single_page_flush_ceiling);
> +
> +#endif /* CONFIG_SMP */

Heh, I was about to complain that you #ifdef'd out my lovely INVLPG
tunable.  But I guess on UP you just get flush_tlb_mm_range() from:

> static inline void flush_tlb_mm_range(struct mm_struct *mm,
>            unsigned long start, unsigned long end, unsigned long vmflag)
> {
>         if (mm == current->active_mm)
>                 __flush_tlb_up();
> }

which doesn't even do INVLPG.  How sad.  Poor UP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

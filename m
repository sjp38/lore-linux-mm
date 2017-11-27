Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F01096B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:15:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s9so11192109pfe.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:15:36 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b59si12964195plb.636.2017.11.27.10.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 10:15:35 -0800 (PST)
Subject: Re: [patch V2 2/5] x86/kaiser: Simplify disabling of global pages
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.393912629@linutronix.de>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <0b5a64f1-9979-ae56-99f8-72c3802a9c60@linux.intel.com>
Date: Mon, 27 Nov 2017 10:15:33 -0800
MIME-Version: 1.0
In-Reply-To: <20171126232414.393912629@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/26/2017 03:14 PM, Thomas Gleixner wrote:
> +static void enable_global_pages(void)
> +{
> +#ifndef CONFIG_KAISER
> +	__supported_pte_mask |= _PAGE_GLOBAL;
> +#endif
> +}
> +
>  static void __init probe_page_size_mask(void)
>  {
>  	/*
> @@ -179,11 +186,11 @@ static void __init probe_page_size_mask(
>  		cr4_set_bits_and_update_boot(X86_CR4_PSE);
>  
>  	/* Enable PGE if available */
> +	__supported_pte_mask |= _PAGE_GLOBAL;
>  	if (boot_cpu_has(X86_FEATURE_PGE)) {
>  		cr4_set_bits_and_update_boot(X86_CR4_PGE);
> -		__supported_pte_mask |= _PAGE_GLOBAL;
> -	} else
> -		__supported_pte_mask &= ~_PAGE_GLOBAL;
> +		enable_global_pages();
> +	}

This looks a little funky.  Doesn't this or _PAGE_GLOBAL into
__supported_pte_mask twice?  Once before the if(), and then a second
time via enable_global_pages() inside the if?

Did you intend for it to be masked *out* in the first one and then or'd
back in via enable_global_pages()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

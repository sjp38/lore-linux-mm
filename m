Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7735B6B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:53:46 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 82so25845613pfp.5
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:53:46 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a33si16049335pla.546.2017.11.27.14.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:53:45 -0800 (PST)
Subject: Re: [PATCH 5/5] x86/mm/kaiser: Disable the SYSCALL-64 trampoline
 along with KAISER
References: <20171127223110.479550152@infradead.org>
 <20171127223405.381212307@infradead.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <dffd1146-5cc5-ae14-ec10-3df312703790@linux.intel.com>
Date: Mon, 27 Nov 2017 14:53:43 -0800
MIME-Version: 1.0
In-Reply-To: <20171127223405.381212307@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/27/2017 02:31 PM, Peter Zijlstra wrote:
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -1442,7 +1442,10 @@ void syscall_init(void)
>  		(entry_SYSCALL_64_trampoline - _entry_trampoline);
>  
>  	wrmsr(MSR_STAR, 0, (__USER32_CS << 16) | __KERNEL_CS);
> -	wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
> +	if (kaiser_enabled)
> +		wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
> +	else
> +		wrmsrl(MSR_LSTAR, (unsigned long)entry_SYSCALL_64);

Heh, ask and ye shall receive, I guess.

We do need a Documentation/ update now.  For this, and other things.
I'll put something together.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

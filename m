Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C60E16B026F
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:03:11 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so3593627plr.14
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:03:11 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v127si452568pgv.669.2018.01.16.10.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 10:03:10 -0800 (PST)
Subject: Re: [PATCH 07/16] x86/mm: Move two more functions from pgtable_64.h
 to pgtable.h
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-8-git-send-email-joro@8bytes.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <727a7eba-41a0-d5bb-df54-8e58b33fde76@intel.com>
Date: Tue, 16 Jan 2018 10:03:09 -0800
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-8-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On 01/16/2018 08:36 AM, Joerg Roedel wrote:
> +/*
> + * Page table pages are page-aligned.  The lower half of the top
> + * level is used for userspace and the top half for the kernel.
> + *
> + * Returns true for parts of the PGD that map userspace and
> + * false for the parts that map the kernel.
> + */
> +static inline bool pgdp_maps_userspace(void *__ptr)
> +{
> +	unsigned long ptr = (unsigned long)__ptr;
> +
> +	return (((ptr & ~PAGE_MASK) / sizeof(pgd_t)) < KERNEL_PGD_BOUNDARY);
> +}

One of the reasons to implement it the other way:

-	return (ptr & ~PAGE_MASK) < (PAGE_SIZE / 2);

is that the compiler can do this all quickly.  KERNEL_PGD_BOUNDARY
depends on PAGE_OFFSET which depends on a variable.  IOW, the compiler
can't do it.

How much worse is the code that this generates?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

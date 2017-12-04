Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B04506B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 17:33:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h18so14311235pfi.2
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 14:33:55 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h124si9937467pgc.824.2017.12.04.14.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 14:33:54 -0800 (PST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AD3A1219AA
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 22:33:53 +0000 (UTC)
Received: by mail-it0-f43.google.com with SMTP id b5so16806163itc.3
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 14:33:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171204150609.416845605@linutronix.de>
References: <20171204140706.296109558@linutronix.de> <20171204150609.416845605@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 4 Dec 2017 14:33:31 -0800
Message-ID: <CALCETrV8b0JB5DogXb1qj-7kEpioJhm13KSTYtDeJnQYvr+oQQ@mail.gmail.com>
Subject: Re: [patch 56/60] x86/mm/kpti: Disable native VSYSCALL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Dec 4, 2017 at 6:08 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> The KERNEL_PAGE_TABLE_ISOLATION code attempts to "poison" the user
> portion of the kernel page tables. It detects entries that it wants that it
> wants to poison in two ways:
>
>  * Looking for addresses >= PAGE_OFFSET
>
>  * Looking for entries without _PAGE_USER set
>
> But, to allow the _PAGE_USER check to work, it must never be set on
> init_mm entries, and an earlier patch in this series ensured that it
> will never be set.
>
> The VDSO is at a address >= PAGE_OFFSET and it is also mapped by init_mm.
> Because of the earlier, KERNEL_PAGE_TABLE_ISOLATION-enforced restriction,
> _PAGE_USER is never set which makes the VDSO unreadable to userspace.
>
> This makes the "NATIVE" case totally unusable since userspace can not even
> see the memory any more.  Disable it whenever KERNEL_PAGE_TABLE_ISOLATION
> is enabled.
>
> Also add some help text about how KERNEL_PAGE_TABLE_ISOLATION might
> affect the emulation case as well.
>

I think my other suggestion may obsolete this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

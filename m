Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B18F6B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:22:47 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 8so5685244pfv.12
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:22:47 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j5si3427151pgp.568.2017.12.14.13.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 13:22:46 -0800 (PST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6C4FA2190A
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 21:22:45 +0000 (UTC)
Received: by mail-it0-f49.google.com with SMTP id f190so14317117ita.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:22:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org>
 <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com> <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 13:22:23 -0800
Message-ID: <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 11:43 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Dec 14, 2017 at 8:20 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> If this turns out to need reverting because it breaks Wine or
>> something, we're really going to regret it.
>
> I really don't see that as very likely. We already play other (much
> more fundamental) games with segments.
>

I dunno.  Maybe Wine or DOSEMU apps expect to be able to create a
non-accessed segment and then read out the accessed bit using LAR or
modify_ldt() later.

> But I do agree that it would be good to consider this "turn LDT
> read-only" a separate series just in case.

Which kind of kills the whole thing.  There's no way the idea of
putting the LDT in a VMA is okay if it's RW.  You just get the kernel
to put_user() a call gate into it and it's game over.

I have a competing patch that just aliases the LDT high up in kernel
land and shares it in the user tables.  I like a lot of the cleanups
in this series, but I don't like the actual LDT-in-a-VMA part.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

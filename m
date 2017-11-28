Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E85326B0275
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 00:23:40 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 70so30978377pgf.5
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 21:23:40 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f3si14939186plb.92.2017.11.27.21.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 21:23:39 -0800 (PST)
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4257F218A4
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:23:39 +0000 (UTC)
Received: by mail-io0-f169.google.com with SMTP id s37so28080210ioe.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 21:23:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171128050322.f2mgrapew3illscm@treble>
References: <20171127223110.479550152@infradead.org> <20171127223405.231444600@infradead.org>
 <CALCETrV-vk-49HkOXi6EW0zxzDrCj2DM4N2i33AuX-vGNb0SHg@mail.gmail.com> <20171128050322.f2mgrapew3illscm@treble>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 27 Nov 2017 21:23:18 -0800
Message-ID: <CALCETrX7Bw_VU-muN60qnECZP7Qes9E0Sv5WbSjrni=RG07uZA@mail.gmail.com>
Subject: Re: [PATCH 2/5] x86/mm/kaiser: Add a banner
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 9:03 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> On Mon, Nov 27, 2017 at 07:36:40PM -0800, Andy Lutomirski wrote:
>> On Mon, Nov 27, 2017 at 2:31 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > So we can more easily see if the shiny got enabled.
>> >
>> > Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>> > ---
>> >  arch/x86/mm/kaiser.c |    2 ++
>> >  1 file changed, 2 insertions(+)
>> >
>> > --- a/arch/x86/mm/kaiser.c
>> > +++ b/arch/x86/mm/kaiser.c
>> > @@ -425,6 +425,8 @@ void __init kaiser_init(void)
>> >         if (!kaiser_enabled)
>> >                 return;
>> >
>> > +       printk("All your KAISER are belong to us\n");
>> > +
>>
>> All your incomprehensible academic names are belong to us.
>>
>> On a serious note, can we please banish the name KAISER from all the
>> user-facing bits?  No one should be setting a boot option that has a
>> name based on an academic project called "Kernel Address Isolation to
>> have Side-channels Efficiently Removed".  We're not efficiently
>> removing side channels.  The side channels are still very much there.
>> Heck, the series as currently presented doesn't even rescue kASLR.  It
>> could*, if we were to finish the work that I mostly started and
>> completely banish all the normal kernel mappings from the shadow**
>> tables.  We're rather inefficiently (and partially!) mitigating the
>> fact that certain CPU designers have had their heads up their
>> collective arses for *years* and have failed to pay attention to
>> numerous academic papers documenting that fact.
>>
>> Let's call the user facing bits "separate user pagetables".  If we
>> want to make it conditioned on a future cpu cap called
>> X86_BUG_REALLY_DUMB_SIDE_CHANNELS, great, assuming a better CPU ever
>> shows up.  But please let's not make users look up WTF "KAISER" means.
>>
>> * No one ever documented the %*!& side channels AFAIK, so everything
>> we're talking about here is mostly speculation.
>>
>> ** The word "shadow" needs to die, too.  I know what shadow page
>> tables are, and they have *nothing* to do with KAISER.
>
> +1.  Somebody please rename KAISER and shadow page tables for more
> clarity.
>
> To fix KASLR I think we need to move (at least parts of) .entry.text,
> .irqentry.text, and .entry_trampoline into their own fixed section(s).
> Is there anything else missing?

We need to completely eliminate anything that maps normal kernel
addresses into the usermode tables.

>
> --
> Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

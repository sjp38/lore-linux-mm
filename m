Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBA536B0007
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 20:28:50 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v2-v6so10777479wrr.10
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 17:28:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o25-v6sor236698wmh.74.2018.07.30.17.28.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 17:28:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180724210923.GA20168@bombadil.infradead.org>
 <20180725023728.44630-1-cannonmatthews@google.com> <20180730162926.GD11890@nazgul.tnic>
In-Reply-To: <20180730162926.GD11890@nazgul.tnic>
From: Cannon Matthews <cannonmatthews@google.com>
Date: Mon, 30 Jul 2018 17:28:37 -0700
Message-ID: <CAJfu=UcafhF4EEXxFAT+1v8F4i7GJ99z2wKc2Z5PJ8THst2VKw@mail.gmail.com>
Subject: Re: [PATCH v2] RFC: clear 1G pages with streaming stores on x86
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, akpm@linux-foundation.org, willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>

Thanks for all the feedback from everyone.

I am going to try to fix this up, and do some more robust benchmarking,
including the 2MB case, and try to have an updated/non-RFC patch(es) in
a few days.

Thanks!
Cannon
On Mon, Jul 30, 2018 at 9:29 AM Borislav Petkov <bp@alien8.de> wrote:
>
> On Tue, Jul 24, 2018 at 07:37:28PM -0700, Cannon Matthews wrote:
> > diff --git a/arch/x86/lib/clear_page_64.S b/arch/x86/lib/clear_page_64.S
> > index 88acd349911b..81a39804ac72 100644
> > --- a/arch/x86/lib/clear_page_64.S
> > +++ b/arch/x86/lib/clear_page_64.S
> > @@ -49,3 +49,23 @@ ENTRY(clear_page_erms)
> >       ret
> >  ENDPROC(clear_page_erms)
> >  EXPORT_SYMBOL_GPL(clear_page_erms)
> > +
> > +/*
> > + * Zero memory using non temporal stores, bypassing the cache.
> > + * Requires an `sfence` (wmb()) afterwards.
> > + * %rdi - destination.
> > + * %rsi - page size. Must be 64 bit aligned.
> > +*/
> > +ENTRY(__clear_page_nt)
> > +     leaq    (%rdi,%rsi), %rdx
> > +     xorl    %eax, %eax
> > +     .p2align 4,,10
> > +     .p2align 3
> > +.L2:
> > +     movnti  %rax, (%rdi)
> > +     addq    $8, %rdi
> > +     cmpq    %rdx, %rdi
> > +     jne     .L2
> > +     ret
> > +ENDPROC(__clear_page_nt)
> > +EXPORT_SYMBOL(__clear_page_nt)
>
> EXPORT_SYMBOL_GPL like the other functions in that file.
>
> --
> Regards/Gruss,
>     Boris.
>
> ECO tip #101: Trim your mails when you reply.
> --

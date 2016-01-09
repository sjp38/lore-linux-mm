Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 70FF1828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 19:18:28 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id p187so3840967oia.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 16:18:28 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id j16si2851600oes.38.2016.01.08.16.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 16:18:27 -0800 (PST)
Received: by mail-ob0-x22d.google.com with SMTP id ba1so367783664obb.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 16:18:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
References: <cover.1452294700.git.luto@kernel.org> <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
 <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 8 Jan 2016 16:18:08 -0800
Message-ID: <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>

On Jan 8, 2016 3:41 PM, "Linus Torvalds" <torvalds@linux-foundation.org> wrote:
>
> On Fri, Jan 8, 2016 at 3:15 PM, Andy Lutomirski <luto@kernel.org> wrote:
> > +       /*
> > +        * We mustn't be preempted or handle an IPI while reading and
> > +        * writing CR3.  Preemption could switch mms and switch back, and
> > +        * an IPI could call leave_mm.  Either of those could cause our
> > +        * PCID to change asynchronously.
> > +        */
> > +       raw_local_irq_save(flags);
> >         native_write_cr3(native_read_cr3());
> > +       raw_local_irq_restore(flags);
>
> This seems sad for two reasons:
>
>  - it adds unnecessary overhead on non-pcid setups (32-bit being an
> example of that)

I can certainly skip the flag saving on !PCID.

>
>  - on pcid setups, wouldn't invpcid_flush_single_context() be better?
>

I played with that and it was slower.  I don't pretend that makes any sense.

> So on the whole I hate it.
>
> Why isn't this something like
>
>         if (static_cpu_has_safe(X86_FEATURE_INVPCID)) {
>                 invpcid_flush_single_context();
>                 return;
>         }
>         native_write_cr3(native_read_cr3());
>
> *without* any flag saving crud?
>
> And yes, that means that we'd require X86_FEATURE_INVPCID in order to
> use X86_FEATURE_PCID, but that seems fine.

I have an SNB "Extreme" with PCID but not INVPCID, and there could be
a whole generation of servers like that.  I think we should fully
support them.

We might be able to get away with just disabling preemption instead of
IRQs, at least if mm == active_mm.

>
> Or is there some reason you wanted the odd flags version? If so, that
> should be documented.

What do you mean "odd"?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

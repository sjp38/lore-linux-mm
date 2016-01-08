Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 35567828ED
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:41:11 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id g73so104441571ioe.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:41:11 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id tg1si2294908igb.83.2016.01.08.15.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:41:10 -0800 (PST)
Received: by mail-ig0-x22a.google.com with SMTP id z14so86055408igp.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:41:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
	<a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
Date: Fri, 8 Jan 2016 15:41:10 -0800
Message-ID: <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 8, 2016 at 3:15 PM, Andy Lutomirski <luto@kernel.org> wrote:
> +       /*
> +        * We mustn't be preempted or handle an IPI while reading and
> +        * writing CR3.  Preemption could switch mms and switch back, and
> +        * an IPI could call leave_mm.  Either of those could cause our
> +        * PCID to change asynchronously.
> +        */
> +       raw_local_irq_save(flags);
>         native_write_cr3(native_read_cr3());
> +       raw_local_irq_restore(flags);

This seems sad for two reasons:

 - it adds unnecessary overhead on non-pcid setups (32-bit being an
example of that)

 - on pcid setups, wouldn't invpcid_flush_single_context() be better?

So on the whole I hate it.

Why isn't this something like

        if (static_cpu_has_safe(X86_FEATURE_INVPCID)) {
                invpcid_flush_single_context();
                return;
        }
        native_write_cr3(native_read_cr3());

*without* any flag saving crud?

And yes, that means that we'd require X86_FEATURE_INVPCID in order to
use X86_FEATURE_PCID, but that seems fine.

Or is there some reason you wanted the odd flags version? If so, that
should be documented.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

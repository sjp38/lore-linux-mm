Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 218AA6B0253
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:05:52 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id js8so15055549lbc.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:05:52 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id ki4si17194920lbc.135.2016.06.15.10.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 10:05:50 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id l188so19066187lfe.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:05:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrWMh0+_RKV1OwwqE6s8P=fLFUYcAxvSNwDK_qB6BOBs9w@mail.gmail.com>
References: <CALCETrWMh0+_RKV1OwwqE6s8P=fLFUYcAxvSNwDK_qB6BOBs9w@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 15 Jun 2016 10:05:49 -0700
Message-ID: <CAGXu5jJ64qCGuMCt+hTpwiVT+pu76b+g8QA=vtVgEv=a4ca9mQ@mail.gmail.com>
Subject: Re: Playing with virtually mapped stacks (with guard pages!)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jun 14, 2016 at 11:01 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> Hi all-
>
> If you want to play with virtually mapped stacks, I have it more or
> less working on x86 in a branch here:
>
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/vmap_stack
>
> The core bit (virtually map the stack and fix the accounting) is just
> a config option, but it needs the arch to opt-in.  I suspect that
> every arch will have its own set of silly issues to address to make it
> work well.  For x86, the silly issues are getting the OOPS to work
> right and handling some vmalloc_fault oddities to avoid panicing at
> random.

Awesome! Some notes/questions:

- there are a number of typos in commit messages and comments, just FYI

- where is the guard page added? I don't see anything leaving a hole at the end?

- where is thread_info? I understand there to be two benefits from
vmalloc stack: 1) thread_info can live elsewhere, 2) guard page can
exist easily

- this seems like it should Oops not warn:
WARN_ON_ONCE(vm->nr_pages != THREAD_SIZE / PAGE_SIZE);
that being wrong seems like a very bad state to continue from

- bikeshed: I think the CONFIG should live in arch/Kconfig (with a
description of what an arch needs to support for it) and be called
HAVE_ARCH_VMAP_STACK so that archs can select it instead of having
multiple definitions of CONFIG_VMAP_STACK in each arch.

Thanks for digging into this!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

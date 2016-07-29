Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA3006B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 13:30:18 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u66so122062175qkf.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:30:18 -0700 (PDT)
Received: from mail-ua0-x235.google.com (mail-ua0-x235.google.com. [2607:f8b0:400c:c08::235])
        by mx.google.com with ESMTPS id c53si4245057uaa.249.2016.07.29.10.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 10:30:17 -0700 (PDT)
Received: by mail-ua0-x235.google.com with SMTP id k90so66605669uak.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:30:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160729163021.F3C25D4A@viggo.jf.intel.com>
References: <20160729163009.5EC1D38C@viggo.jf.intel.com> <20160729163021.F3C25D4A@viggo.jf.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 29 Jul 2016 10:29:58 -0700
Message-ID: <CALCETrWMg=+YSi7Az+gw9B59OoAEkOd=znpr7+++5=UUg6DThw@mail.gmail.com>
Subject: Re: [PATCH 08/10] x86, pkeys: default to a restrictive init PKRU
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>

On Fri, Jul 29, 2016 at 9:30 AM, Dave Hansen <dave@sr71.net> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> PKRU is the register that lets you disallow writes or all access
> to a given protection key.
>
> The XSAVE hardware defines an "init state" of 0 for PKRU: its
> most permissive state, allowing access/writes to everything.
> Since we start off all new processes with the init state, we
> start all processes off with the most permissive possible PKRU.
>
> This is unfortunate.  If a thread is clone()'d [1] before a
> program has time to set PKRU to a restrictive value, that thread
> will be able to write to all data, no matter what pkey is set on
> it.  This weakens any integrity guarantees that we want pkeys to
> provide.
>
> To fix this, we define a very restrictive PKRU to override the
> XSAVE-provided value when we create a new FPU context.  We choose
> a value that only allows access to pkey 0, which is as
> restrictive as we can practically make it.
>
> This does not cause any practical problems with applications
> using protection keys because we require them to specify initial
> permissions for each key when it is allocated, which override the
> restrictive default.
>
> In the end, this ensures that threads which do not know how to
> manage their own pkey rights can not do damage to data which is
> pkey-protected.

I think you missed the fpu__clear() caller in kernel/fpu/signal.c.

ISTM it might be more comprehensible to change fpu__clear in general
and then special case things you want to behave differently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

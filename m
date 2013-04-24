Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6B4B56B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 03:31:42 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id c10so7052571wiw.0
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 00:31:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130422141621.384eb93a6a8f3d441cd1a991@linux-foundation.org>
References: <1366225776.8817.28.camel@pippen.local.home>
	<alpine.DEB.2.02.1304171702380.24494@chino.kir.corp.google.com>
	<20130422134415.32c7f2cac07c924bff3017a4@linux-foundation.org>
	<1366664301.9609.140.camel@gandalf.local.home>
	<20130422141621.384eb93a6a8f3d441cd1a991@linux-foundation.org>
Date: Wed, 24 Apr 2013 10:31:40 +0300
Message-ID: <CAOJsxLEFaAtKEvN4cRSDj7Pao5gbHv7K9fO0REhhhbsmUbgbmg@mail.gmail.com>
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>

Hello,

On Tue, Apr 23, 2013 at 12:16 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> The patch made index_of() weaker!
>
> It's probably all a bit academic, given that linux-next does
>
> -/*
> - * This function must be completely optimized away if a constant is passed to
> - * it.  Mostly the same as what is in linux/slab.h except it returns an index.
> - */
> -static __always_inline int index_of(const size_t size)
> -{
> -       extern void __bad_size(void);
> -
> -       if (__builtin_constant_p(size)) {
> -               int i = 0;
> -
> -#define CACHE(x) \
> -       if (size <=x) \
> -               return i; \
> -       else \
> -               i++;
> -#include <linux/kmalloc_sizes.h>
> -#undef CACHE
> -               __bad_size();
> -       } else
> -               __bad_size();
> -       return 0;
> -}
> -

Yup, Christoph nuked it in the following commit:

https://git.kernel.org/cgit/linux/kernel/git/penberg/linux.git/commit/?h=slab/next&id=2c59dd6544212faa5ce761920d2251f4152f408d

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

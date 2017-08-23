Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1991F280396
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:33:02 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 4so433281oie.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:33:02 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id c127si1429008oif.540.2017.08.23.08.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 08:33:01 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id k77so435092oib.4
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:33:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170823152542.5150-1-boqun.feng@gmail.com>
References: <20170823152542.5150-1-boqun.feng@gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 23 Aug 2017 17:33:00 +0200
Message-ID: <CAK8P3a1FN8FoRNn8GYiPNTzAxGg_x+qkw5Z7eARTBirUkug2gQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] completion: Reduce stack usage caused by COMPLETION_INITIALIZER_ONSTACK()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michel Lespinasse <walken@google.com>, Byungchul Park <byungchul.park@lge.com>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com

On Wed, Aug 23, 2017 at 5:25 PM, Boqun Feng <boqun.feng@gmail.com> wrote:
> With LOCKDEP_CROSSRELEASE and LOCKDEP_COMPLETIONS introduced, the growth
> in kernel stack usage of several functions were reported:
>
>         https://marc.info/?l=linux-kernel&m=150270063231284&w=2
>
> The root cause of this is in COMPLETION_INITIALIZER_ONSTACK(), we use
>
>         ({init_completion(&work); work})
>
> , which will create a temporary object when returned. However this
> temporary object is unnecessary. And this patch fixes it by making the
> statement expression in COMPLETION_INITIALIZER_ONSTACK() return a
> pointer rather than a whole structure. This will reduce the stack usage
> even if !LOCKDEP.
>
> However, such a change does make one COMPLETION_INITIALIZER_ONSTACK()
> callsite invalid, so we fix this first via converting to
> init_completion().

Both patches

Acked-by: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

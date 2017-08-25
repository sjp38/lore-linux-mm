Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B22A44088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:36:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l19so934703oib.15
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:36:24 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id t4si4257049oig.398.2017.08.24.17.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 17:36:23 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id j144so9463754oib.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:36:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170824142239.15178-1-boqun.feng@gmail.com>
References: <20170823152542.5150-2-boqun.feng@gmail.com> <20170824142239.15178-1-boqun.feng@gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Aug 2017 17:36:22 -0700
Message-ID: <CAPcyv4gHgdpyqbv8gs5MiEtEHSdC-JLhutdfn81fhQ1woQSh_Q@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] nfit: Fix the abuse of COMPLETION_INITIALIZER_ONSTACK()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michel Lespinasse <walken@google.com>, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>

On Thu, Aug 24, 2017 at 7:22 AM, Boqun Feng <boqun.feng@gmail.com> wrote:
> COMPLETION_INITIALIZER_ONSTACK() is supposed to used as an initializer,
> in other words, it should only be used in assignment expressions or
> compound literals. So the usage in drivers/acpi/nfit/core.c:
>
>         COMPLETION_INITIALIZER_ONSTACK(flush.cmp);
>
> , is inappropriate.
>
> Besides, this usage could also break compilations for another fix to
> reduce stack sizes caused by COMPLETION_INITIALIZER_ONSTACK(), because
> that fix changes COMPLETION_INITIALIZER_ONSTACK() from rvalue to lvalue,
> and usage as above will report error:
>
>         drivers/acpi/nfit/core.c: In function 'acpi_nfit_flush_probe':
>         include/linux/completion.h:77:3: error: value computed is not used [-Werror=unused-value]
>           (*({ init_completion(&work); &work; }))
>
> This patch fixes this by replacing COMPLETION_INITIALIZER_ONSTACK() with
> init_completion() in acpi_nfit_flush_probe(), which does the same
> initialization without any other problem.
>
> Signed-off-by: Boqun Feng <boqun.feng@gmail.com>

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

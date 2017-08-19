Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2836B04BE
	for <linux-mm@kvack.org>; Sat, 19 Aug 2017 09:34:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id g131so15746751oic.10
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 06:34:03 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id y79si6512276oia.515.2017.08.19.06.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Aug 2017 06:34:02 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id e124so11824098oig.0
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 06:34:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAK8P3a2+OdPX-uvRjhycX1NYNC_cBPv_bxJHcoh1ue2y7UX+Tg@mail.gmail.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
 <CAK8P3a3ABsxTaS7ZdcWNbTx7j5wFRc0h=ZVWAC_h-E+XbFv+8Q@mail.gmail.com>
 <20170818234348.GE11771@tardis> <CAK8P3a2+OdPX-uvRjhycX1NYNC_cBPv_bxJHcoh1ue2y7UX+Tg@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 19 Aug 2017 15:34:01 +0200
Message-ID: <CAK8P3a3TfZ=_tm0CUC5aKtf5PDwscLYsAN9Tbs2v0iJN5Jz-Rw@mail.gmail.com>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michel Lespinasse <walken@google.com>, kirill@shutemov.name, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com

On Sat, Aug 19, 2017 at 2:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:

>> --- a/include/linux/completion.h
>> +++ b/include/linux/completion.h
>> @@ -74,7 +74,7 @@ static inline void complete_release_commit(struct completion *x) {}
>>  #endif
>>
>>  #define COMPLETION_INITIALIZER_ONSTACK(work) \
>> -       ({ init_completion(&work); work; })
>> +       (*({ init_completion(&work); &work; }))
>>
>>  /**
>>   * DECLARE_COMPLETION - declare and initialize a completion structure
>
> Nice hack. Any idea why that's different to the compiler?
>
> I've applied that one to my test tree now, and reverted my own patch,
> will let you know if anything else shows up. I think we probably want
> to merge both patches to mainline.

There is apparently one user of COMPLETION_INITIALIZER_ONSTACK
that causes a regression with the patch above:

drivers/acpi/nfit/core.c: In function 'acpi_nfit_flush_probe':
include/linux/completion.h:77:3: error: value computed is not used
[-Werror=unused-value]
  (*({ init_completion(&work); &work; }))

It would be trivial to convert to init_completion(), which seems to be
what was intended there.

        Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

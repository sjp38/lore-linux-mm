Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0686C6B0261
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 04:18:35 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b75so95563872lfg.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:18:34 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id g18si3756421lfe.201.2016.10.17.01.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 01:18:33 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id l131so232383530lfl.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:18:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2b39f90e-2c67-fafb-dc48-f642c62bead6@virtuozzo.com>
References: <1476465002-2728-1-git-send-email-dvyukov@google.com> <2b39f90e-2c67-fafb-dc48-f642c62bead6@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 17 Oct 2016 10:18:11 +0200
Message-ID: <CACT4Y+acug4QfzUBvxHoSR-K7FFAy1dDJ0eY4qgmF6+7dpv=Jg@mail.gmail.com>
Subject: Re: [PATCH] kasan: support panic_on_warn
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 17, 2016 at 10:13 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 10/14/2016 08:10 PM, Dmitry Vyukov wrote:
>> If user sets panic_on_warn, he wants kernel to panic if there is
>> anything barely wrong with the kernel. KASAN-detected errors
>> are definitely not less benign than an arbitrary kernel WARNING.
>>
>> Panic after KASAN errors if panic_on_warn is set.
>>
>> We use this for continuous fuzzing where we want kernel to stop
>> and reboot on any error.
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: kasan-dev@googlegroups.com
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Alexander Potapenko <glider@google.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>  mm/kasan/report.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index 24c1211..ca0bd48 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -133,6 +133,10 @@ static void kasan_end_report(unsigned long *flags)
>>       pr_err("==================================================================\n");
>>       add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>>       spin_unlock_irqrestore(&report_lock, *flags);
>> +     if (panic_on_warn) {
>> +             panic_on_warn = 0;
>
> Why we need to reset panic_on_warn?
> I assume this was copied from __warn(). AFAIU in __warn() this protects from recursion:
>  __warn() -> painc() ->__warn() -> panic() -> ...
> which is possible if WARN_ON() triggered in panic().
> But KASAN is protected from such recursion via kasan_disable_current().

But we have recursion into panic via kasan->panic->warning->panic. Am
I missing something?


>> +             panic("panic_on_warn set ...\n");
>> +     }
>>       kasan_enable_current();
>>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

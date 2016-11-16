Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2417D6B0260
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 02:24:08 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id d45so53661697qta.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 23:24:08 -0800 (PST)
Received: from mail-qk0-x231.google.com (mail-qk0-x231.google.com. [2607:f8b0:400d:c09::231])
        by mx.google.com with ESMTPS id i4si14411885qkf.212.2016.11.15.23.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 23:24:07 -0800 (PST)
Received: by mail-qk0-x231.google.com with SMTP id q130so164960729qke.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 23:24:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161115154002.0c4c7a5e1fd23f12474fc80e@linux-foundation.org>
References: <1479226045-145148-1-git-send-email-dvyukov@google.com> <20161115154002.0c4c7a5e1fd23f12474fc80e@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 16 Nov 2016 08:23:46 +0100
Message-ID: <CACT4Y+ZBhPhV+DjGKuFUprq87aexz2RpCH_Fn2NYkYzsCzWF8w@mail.gmail.com>
Subject: Re: [PATCH] kasan: support use-after-scope detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 16, 2016 at 12:40 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 15 Nov 2016 17:07:25 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
>
>> Gcc revision 241896 implements use-after-scope detection.
>> Will be available in gcc 7. Support it in KASAN.
>>
>> Gcc emits 2 new callbacks to poison/unpoison large stack
>> objects when they go in/out of scope.
>> Implement the callbacks and add a test.
>>
>> ...
>>
>> --- a/lib/test_kasan.c
>> +++ b/lib/test_kasan.c
>> @@ -411,6 +411,29 @@ static noinline void __init copy_user_test(void)
>>       kfree(kmem);
>>  }
>>
>> +static noinline void __init use_after_scope_test(void)
>
> This reader has no idea why this code uses noinline, and I expect
> others will have the same issue.
>
> Can we please get a code comment in there to reveal the reason?

Mailed v2 with a comment re noinline.

Taking the opportunity also fixed a type in the new comment:

- /* Emitted by compiler to unpoison large objects when they go into
of scope. */
+ /* Emitted by compiler to unpoison large objects when they go into scope. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

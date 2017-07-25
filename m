Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5CC6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 03:17:34 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b130so8140632oii.4
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 00:17:34 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id a84si6445425oif.270.2017.07.25.00.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 00:17:33 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id s21so4429168oie.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 00:17:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UzULc1oRfF5BVHXgfKOC6eoGuwwT1cJ9oHJO7hCNzscQ@mail.gmail.com>
References: <20170721210251.3378996-1-arnd@arndb.de> <CAG_fn=UzULc1oRfF5BVHXgfKOC6eoGuwwT1cJ9oHJO7hCNzscQ@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 25 Jul 2017 09:17:32 +0200
Message-ID: <CAK8P3a0prDzKW=yoosY0oPQagDkfpmKy7jny6CUaA9Xi_U0e4A@mail.gmail.com>
Subject: Re: [PATCH] [v2] kasan: avoid -Wmaybe-uninitialized warning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 24, 2017 at 1:35 PM, Alexander Potapenko <glider@google.com> wrote:
> On Fri, Jul 21, 2017 at 11:02 PM, Arnd Bergmann <arnd@arndb.de> wrote:

>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index 04bb1d3eb9ec..28fb222ab149 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -111,6 +111,9 @@ static const char *get_wild_bug_type(struct kasan_access_info *info)
>>  {
>>         const char *bug_type = "unknown-crash";
>>
>> +       /* shut up spurious -Wmaybe-uninitialized warning */
>> +       info->first_bad_addr = (void *)(-1ul);
>> +
> Why don't we initialize info.first_bad_addr in kasan_report(), where
> info is allocated?

I'm just trying to shut up a particular warning here where gcc can't figure out
by itself that it is initialized. Setting an invalid address at
allocation time would
prevent gcc from warning even for any trivial bug where we use the incorrect
value in the normal code path, in case someone later wants to modify the
code further and makes a mistake.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

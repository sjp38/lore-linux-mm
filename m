Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31A9C6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:03:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v62so155459044pfd.10
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:03:59 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0137.outbound.protection.outlook.com. [104.47.0.137])
        by mx.google.com with ESMTPS id m8si1000797pgc.153.2017.07.25.05.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 05:03:58 -0700 (PDT)
Subject: Re: [PATCH] [v2] kasan: avoid -Wmaybe-uninitialized warning
References: <20170721210251.3378996-1-arnd@arndb.de>
 <CAG_fn=UzULc1oRfF5BVHXgfKOC6eoGuwwT1cJ9oHJO7hCNzscQ@mail.gmail.com>
 <CAK8P3a0prDzKW=yoosY0oPQagDkfpmKy7jny6CUaA9Xi_U0e4A@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b56efb52-2458-4d2d-f9d9-4bb2907e52dc@virtuozzo.com>
Date: Tue, 25 Jul 2017 15:06:18 +0300
MIME-Version: 1.0
In-Reply-To: <CAK8P3a0prDzKW=yoosY0oPQagDkfpmKy7jny6CUaA9Xi_U0e4A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/25/2017 10:17 AM, Arnd Bergmann wrote:
> On Mon, Jul 24, 2017 at 1:35 PM, Alexander Potapenko <glider@google.com> wrote:
>> On Fri, Jul 21, 2017 at 11:02 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> 
>>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>>> index 04bb1d3eb9ec..28fb222ab149 100644
>>> --- a/mm/kasan/report.c
>>> +++ b/mm/kasan/report.c
>>> @@ -111,6 +111,9 @@ static const char *get_wild_bug_type(struct kasan_access_info *info)
>>>  {
>>>         const char *bug_type = "unknown-crash";
>>>
>>> +       /* shut up spurious -Wmaybe-uninitialized warning */
>>> +       info->first_bad_addr = (void *)(-1ul);
>>> +
>> Why don't we initialize info.first_bad_addr in kasan_report(), where
>> info is allocated?
> 
> I'm just trying to shut up a particular warning here where gcc can't figure out
> by itself that it is initialized. Setting an invalid address at
> allocation time would
> prevent gcc from warning even for any trivial bug where we use the incorrect
> value in the normal code path, in case someone later wants to modify the
> code further and makes a mistake.
> 

'info->first_bad_addr' could be initialized to the correct value. That would be 'addr' itself
for 'wild' type of bugs.
Initialization in get_wild_bug_type() looks a bit odd and off-place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

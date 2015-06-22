Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 81C576B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 06:43:47 -0400 (EDT)
Received: by wiga1 with SMTP id a1so72593285wig.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 03:43:47 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id q20si19077962wiv.60.2015.06.22.03.43.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 03:43:45 -0700 (PDT)
Received: by wiga1 with SMTP id a1so72592652wig.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 03:43:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5587C9DA.7090909@arm.com>
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
 <1434725914-14300-2-git-send-email-vladimir.murzin@arm.com>
 <CALq1K=J6ZKvBM5aqFGeE_hcZTrLxwuaP=N_8xb_no_LCjjTT9g@mail.gmail.com> <5587C9DA.7090909@arm.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 22 Jun 2015 13:43:25 +0300
Message-ID: <CALq1K=KeOEh4PRU9ZUiKsWnqkRZZTR2jz2oVUzLMjB1WyHPrpg@mail.gmail.com>
Subject: Re: [PATCH 1/3] memtest: use kstrtouint instead of simple_strtoul
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 22, 2015 at 11:39 AM, Vladimir Murzin
<vladimir.murzin@arm.com> wrote:
> On 20/06/15 07:55, Leon Romanovsky wrote:
>> On Fri, Jun 19, 2015 at 5:58 PM, Vladimir Murzin
>> <vladimir.murzin@arm.com> wrote:
>>> Since simple_strtoul is obsolete and memtest_pattern is type of int, use
>>> kstrtouint instead.
>>>
>>> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
>>> ---
>>>  mm/memtest.c |   14 +++++++++-----
>>>  1 file changed, 9 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/mm/memtest.c b/mm/memtest.c
>>> index 1997d93..895a43c 100644
>>> --- a/mm/memtest.c
>>> +++ b/mm/memtest.c
>>> @@ -88,14 +88,18 @@ static void __init do_one_pass(u64 pattern, phys_addr_t start, phys_addr_t end)
>>>  }
>>>
>>>  /* default is disabled */
>>> -static int memtest_pattern __initdata;
>>> +static unsigned int memtest_pattern __initdata;
>>>
>>>  static int __init parse_memtest(char *arg)
>>>  {
>>> -       if (arg)
>>> -               memtest_pattern = simple_strtoul(arg, NULL, 0);
>>> -       else
>>> -               memtest_pattern = ARRAY_SIZE(patterns);
>>> +       if (arg) {
>>> +               int err = kstrtouint(arg, 0, &memtest_pattern);
>>> +
>>> +               if (!err)
>>> +                       return 0;
>> kstrtouint returns 0 for success, in case of error you will fallback
>> and execute following line. It is definetely change of behaviour.
>
> I'd be glad if you can elaborate more on use cases dependent on this
> change? I can only imagine providing garbage to the memtest option with
> only intention to shut it up... but it looks like the interface abuse
> since "memtest=0" does exactly the same.
>
> Since memtest is debugging option and numeric parameter is optional I
> thought it was not harmful to fallback to default in case something is
> wrong with the parameter.
I would like to suggest you, in case of error, print warning and set
memtest_pattern to be zero and return back to if(arg)..else
construction.

>
> Thanks
> Vladimir
>
>>> +       }
>>> +
>>> +       memtest_pattern = ARRAY_SIZE(patterns);
>>>
>>>         return 0;
>>>  }
>>> --
>>> 1.7.9.5
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>>
>>
>



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

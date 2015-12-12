Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id E4EE26B0038
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 18:17:13 -0500 (EST)
Received: by qkfb125 with SMTP id b125so89390984qkf.2
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 15:17:13 -0800 (PST)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id w202si27393203qka.86.2015.12.12.15.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 15:17:12 -0800 (PST)
Received: by qkck189 with SMTP id k189so54081924qkc.0
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 15:17:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151207142621.GA7012@mtj.duckdns.org>
References: <566594E2.3050306@odin.com>
	<20151207142621.GA7012@mtj.duckdns.org>
Date: Sun, 13 Dec 2015 01:17:12 +0200
Message-ID: <CAHp75VdHCSmw9tgd7ZC_n=N09wQHMHk8T5oK7jS7cM+zqBQ-_Q@mail.gmail.com>
Subject: Re: undefined shift in wb_update_dirty_ratelimit()
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrey Ryabinin <aryabinin@odin.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Mon, Dec 7, 2015 at 4:26 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Andrey.
> On Mon, Dec 07, 2015 at 05:17:06PM +0300, Andrey Ryabinin wrote:
>> I've hit undefined shift in wb_update_dirty_ratelimit() which does some
>> mysterious 'step' calculations:
>>
>>       /*
>>        * Don't pursue 100% rate matching. It's impossible since the balanced
>>        * rate itself is constantly fluctuating. So decrease the track speed
>>        * when it gets close to the target. Helps eliminate pointless tremors.
>>        */
>>       step >>= dirty_ratelimit / (2 * step + 1);
>>
>>
>> dirty_ratelimit = INIT_BW and step = 0 results in this:
>>
>> [ 5006.957366] ================================================================================
>> [ 5006.957798] UBSAN: Undefined behaviour in ../mm/page-writeback.c:1286:7
>> [ 5006.958091] shift exponent 25600 is too large for 64-bit type 'long unsigned int'
>
> We prolly should do sth like
>
>         shift = dirty_ratelimit / (2 * step = 1);

>         if (shift < BITS_PER_LONG) {
>                 step = (step >> shift) + 7 / 8;

7/8 = 0. Missed parens?
In that case it's DIV_ROUND_UP(step >> shift, 8)


>         } else {
>                 step = 0;
>         }


-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

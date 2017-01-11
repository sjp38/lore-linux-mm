Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 566426B0260
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:43:15 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 7so81557465uas.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:43:15 -0800 (PST)
Received: from mail-vk0-x242.google.com (mail-vk0-x242.google.com. [2607:f8b0:400c:c05::242])
        by mx.google.com with ESMTPS id 30si1673110uae.125.2017.01.11.08.43.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:43:14 -0800 (PST)
Received: by mail-vk0-x242.google.com with SMTP id r136so6083745vke.1
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:43:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONDmfWaJ2u-dO4BGnK0jztOGMEKb8WxEZ1iEurAdkMoxGA@mail.gmail.com>
References: <20170111155948.aa61c5b995b6523caf87d862@gmail.com>
 <20170111160622.44ac261b12ed4778556c56dc@gmail.com> <CALZtONDmfWaJ2u-dO4BGnK0jztOGMEKb8WxEZ1iEurAdkMoxGA@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Wed, 11 Jan 2017 17:43:13 +0100
Message-ID: <CAMJBoFNyo2KRvECFNwd9_5nVtLaQ3gP86aHAP3tud+3i33AXXg@mail.gmail.com>
Subject: Re: [PATCH/RESEND v2 3/5] z3fold: extend compaction function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 11, 2017 at 5:28 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Wed, Jan 11, 2017 at 10:06 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>> z3fold_compact_page() currently only handles the situation when
>> there's a single middle chunk within the z3fold page. However it
>> may be worth it to move middle chunk closer to either first or
>> last chunk, whichever is there, if the gap between them is big
>> enough.
>>
>> This patch adds the relevant code, using BIG_CHUNK_GAP define as
>> a threshold for middle chunk to be worth moving.
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>> ---
>>  mm/z3fold.c | 26 +++++++++++++++++++++++++-
>>  1 file changed, 25 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> index 98ab01f..fca3310 100644
>> --- a/mm/z3fold.c
>> +++ b/mm/z3fold.c
>> @@ -268,6 +268,7 @@ static inline void *mchunk_memmove(struct z3fold_header *zhdr,
>>                        zhdr->middle_chunks << CHUNK_SHIFT);
>>  }
>>
>> +#define BIG_CHUNK_GAP  3
>>  /* Has to be called with lock held */
>>  static int z3fold_compact_page(struct z3fold_header *zhdr)
>>  {
>> @@ -286,8 +287,31 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
>>                 zhdr->middle_chunks = 0;
>>                 zhdr->start_middle = 0;
>>                 zhdr->first_num++;
>> +               return 1;
>>         }
>> -       return 1;
>> +
>> +       /*
>> +        * moving data is expensive, so let's only do that if
>> +        * there's substantial gain (at least BIG_CHUNK_GAP chunks)
>> +        */
>> +       if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
>> +           zhdr->start_middle - (zhdr->first_chunks + ZHDR_CHUNKS) >=
>> +                       BIG_CHUNK_GAP) {
>> +               mchunk_memmove(zhdr, zhdr->first_chunks + 1);
>> +               zhdr->start_middle = zhdr->first_chunks + 1;
>
> this should be first_chunks + ZHDR_CHUNKS, not + 1.
>
>> +               return 1;
>> +       } else if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
>> +                  TOTAL_CHUNKS - (zhdr->last_chunks + zhdr->start_middle
>> +                                       + zhdr->middle_chunks) >=
>> +                       BIG_CHUNK_GAP) {
>> +               unsigned short new_start = NCHUNKS - zhdr->last_chunks -
>
> this should be TOTAL_CHUNKS, not NCHUNKS.

Right :/

>> +                       zhdr->middle_chunks;
>> +               mchunk_memmove(zhdr, new_start);
>> +               zhdr->start_middle = new_start;
>> +               return 1;
>> +       }
>> +
>> +       return 0;
>>  }
>>
>>  /**
>> --
>> 2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

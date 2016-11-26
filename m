Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 723DC6B0069
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 04:09:29 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 23so93075226uat.4
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 01:09:29 -0800 (PST)
Received: from mail-ua0-x242.google.com (mail-ua0-x242.google.com. [2607:f8b0:400c:c08::242])
        by mx.google.com with ESMTPS id 3si9869614uap.118.2016.11.26.01.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Nov 2016 01:09:28 -0800 (PST)
Received: by mail-ua0-x242.google.com with SMTP id 20so5416394uak.0
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 01:09:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONAJLTJikY1Nr0GUa9MPkfWcnaygXKzvy-RwJ_7dp2-sWw@mail.gmail.com>
References: <20161103220428.984a8d09d0c9569e6bc6b8cc@gmail.com>
 <CALZtONBA5sSJ_tzF1D=seDdryCn8zu=UWwF=k5RxnJQMr1vfSA@mail.gmail.com> <CALZtONAJLTJikY1Nr0GUa9MPkfWcnaygXKzvy-RwJ_7dp2-sWw@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sat, 26 Nov 2016 10:09:27 +0100
Message-ID: <CAMJBoFMaytBR1JwdbsoZ5Q6DzFd40q81Gfi93kiG302us2qRbQ@mail.gmail.com>
Subject: Re: [PATH] z3fold: extend compaction function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Nov 25, 2016 at 10:17 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Fri, Nov 25, 2016 at 9:43 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> On Thu, Nov 3, 2016 at 5:04 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
>>> z3fold_compact_page() currently only handles the situation when
>>> there's a single middle chunk within the z3fold page. However it
>>> may be worth it to move middle chunk closer to either first or
>>> last chunk, whichever is there, if the gap between them is big
>>> enough.
>>>
>>> This patch adds the relevant code, using BIG_CHUNK_GAP define as
>>> a threshold for middle chunk to be worth moving.
>>>
>>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>>
>> with the bikeshedding comments below, looks good.
>>
>> Acked-by: Dan Streetman <ddstreet@ieee.org>
>>
>>> ---
>>>  mm/z3fold.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++-------------
>>>  1 file changed, 47 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>>> index 4d02280..fea6791 100644
>>> --- a/mm/z3fold.c
>>> +++ b/mm/z3fold.c
>>> @@ -250,26 +250,60 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
>>>         kfree(pool);
>>>  }
>>>
>>> +static inline void *mchunk_memmove(struct z3fold_header *zhdr,
>>> +                               unsigned short dst_chunk)
>>> +{
>>> +       void *beg = zhdr;
>>> +       return memmove(beg + (dst_chunk << CHUNK_SHIFT),
>>> +                      beg + (zhdr->start_middle << CHUNK_SHIFT),
>>> +                      zhdr->middle_chunks << CHUNK_SHIFT);
>>> +}
>>> +
>>> +#define BIG_CHUNK_GAP  3
>>>  /* Has to be called with lock held */
>>>  static int z3fold_compact_page(struct z3fold_header *zhdr)
>>>  {
>>>         struct page *page = virt_to_page(zhdr);
>>> -       void *beg = zhdr;
>>> +       int ret = 0;
>>> +
>>> +       if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
>>> +               goto out;
>>>
>>> +       if (zhdr->middle_chunks != 0) {
>>
>> bikeshed: this check could be moved up also, as if there's no middle
>> chunk there is no compacting to do and we can just return 0.  saves a
>> tab in all the code below.
>>
>>> +               if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>>> +                       mchunk_memmove(zhdr, 1); /* move to the beginning */
>>> +                       zhdr->first_chunks = zhdr->middle_chunks;
>>> +                       zhdr->middle_chunks = 0;
>>> +                       zhdr->start_middle = 0;
>>> +                       zhdr->first_num++;
>>> +                       ret = 1;
>>> +                       goto out;
>>> +               }
>>>
>>> -       if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
>>> -           zhdr->middle_chunks != 0 &&
>>> -           zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>>> -               memmove(beg + ZHDR_SIZE_ALIGNED,
>>> -                       beg + (zhdr->start_middle << CHUNK_SHIFT),
>>> -                       zhdr->middle_chunks << CHUNK_SHIFT);
>>> -               zhdr->first_chunks = zhdr->middle_chunks;
>>> -               zhdr->middle_chunks = 0;
>>> -               zhdr->start_middle = 0;
>>> -               zhdr->first_num++;
>>> -               return 1;
>>> +               /*
>>> +                * moving data is expensive, so let's only do that if
>>> +                * there's substantial gain (at least BIG_CHUNK_GAP chunks)
>>> +                */
>>> +               if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
>>> +                   zhdr->start_middle > zhdr->first_chunks + BIG_CHUNK_GAP) {
>>> +                       mchunk_memmove(zhdr, zhdr->first_chunks + 1);
>>> +                       zhdr->start_middle = zhdr->first_chunks + 1;
>>> +                       ret = 1;
>>> +                       goto out;
>>> +               }
>>> +               if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
>>> +                   zhdr->middle_chunks + zhdr->last_chunks <=
>>> +                   NCHUNKS - zhdr->start_middle - BIG_CHUNK_GAP) {
>>> +                       unsigned short new_start = NCHUNKS - zhdr->last_chunks -
>>> +                               zhdr->middle_chunks;
>
> after closer review, I see that this is wrong.  NCHUNKS isn't the
> total number of page chunks, it's the total number of chunks minus the
> header chunk(s).  so that calculation of where the new start is, is
> wrong.  it should use the total page chunks, not the NCHUNKS, because
> start_middle already accounts for the header chunk(s).  Probably a new
> macro would help.
>
> Also, the num_free_chunks() function makes the same mistake:
>
> int nfree_after = zhdr->last_chunks ?
>   0 : NCHUNKS - zhdr->start_middle - zhdr->middle_chunks;
>
> that's wrong, it should be something like:
>
> #define TOTAL_CHUNKS (PAGE_SIZE >> CHUNK_SHIFT)
> ...
> int nfree_after = zhdr->last_chunks ?
>   0 : TOTAL_CHUNKS - zhdr->start_middle - zhdr->middle_chunks;

Right, will fix.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79FF66B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 22:55:03 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so1261101lfg.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 19:55:03 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id g97si20803695lfi.224.2016.10.17.19.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 19:55:02 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l131so187341lfl.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 19:55:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONCfJ_NQAmekyQQTY9umfKMR1DK5aycQZ5fOohAJ69L9Xg@mail.gmail.com>
References: <20161015135632.541010b55bec496e2cae056e@gmail.com>
 <20161015135947.5adf02bae01986ea8b79edd9@gmail.com> <CALZtONCfJ_NQAmekyQQTY9umfKMR1DK5aycQZ5fOohAJ69L9Xg@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 18 Oct 2016 04:55:01 +0200
Message-ID: <CAMJBoFNGO=ZwoVDAbEyJKRP3ojdohSLJUbxJe9c6tD_MFuiMfQ@mail.gmail.com>
Subject: Re: [PATCH v5 2/3] z3fold: remove redundant locking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>

On Mon, Oct 17, 2016 at 10:48 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Sat, Oct 15, 2016 at 7:59 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>> The per-pool z3fold spinlock should generally be taken only when
>> a non-atomic pool variable is modified. There's no need to take it
>> to map/unmap an object.
>
> no.  it absolutely needs to be taken, because z3fold_compact_page
> could move the middle bud's contents to the first bud, and if the
> middle bud gets mapped while it's being moved really bad things will
> happen.
>
> you can change that to a per-page lock in the z3fold_header, but some
> locking needs to happen between mapping and middle bud moving (and
> handle encoding/decoding and first_num access).

Yep, probably per-page lock is the way to go. I was thinking of making
first_num atomic but that obviously creates more problems than it solves.

~vitaly

>
>
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>> ---
>>  mm/z3fold.c | 17 +++++------------
>>  1 file changed, 5 insertions(+), 12 deletions(-)
>>
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> index 5197d7b..10513b5 100644
>> --- a/mm/z3fold.c
>> +++ b/mm/z3fold.c
>> @@ -580,6 +580,7 @@ next:
>>                 if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
>>                     (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
>>                      zhdr->middle_chunks == 0)) {
>> +                       spin_unlock(&pool->lock);
>>                         /*
>>                          * All buddies are now free, free the z3fold page and
>>                          * return success.
>> @@ -587,7 +588,6 @@ next:
>>                         clear_bit(PAGE_HEADLESS, &page->private);
>>                         free_z3fold_page(zhdr);
>>                         atomic64_dec(&pool->pages_nr);
>> -                       spin_unlock(&pool->lock);
>>                         return 0;
>>                 }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
>>                         if (zhdr->first_chunks != 0 &&
>> @@ -629,7 +629,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>>         void *addr;
>>         enum buddy buddy;
>>
>> -       spin_lock(&pool->lock);
>>         zhdr = handle_to_z3fold_header(handle);
>>         addr = zhdr;
>>         page = virt_to_page(zhdr);
>> @@ -656,7 +655,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>>                 break;
>>         }
>>  out:
>> -       spin_unlock(&pool->lock);
>>         return addr;
>>  }
>>
>> @@ -671,19 +669,14 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
>>         struct page *page;
>>         enum buddy buddy;
>>
>> -       spin_lock(&pool->lock);
>>         zhdr = handle_to_z3fold_header(handle);
>>         page = virt_to_page(zhdr);
>>
>> -       if (test_bit(PAGE_HEADLESS, &page->private)) {
>> -               spin_unlock(&pool->lock);
>> -               return;
>> +       if (!test_bit(PAGE_HEADLESS, &page->private)) {
>> +               buddy = handle_to_buddy(handle);
>> +               if (buddy == MIDDLE)
>> +                       clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>>         }
>> -
>> -       buddy = handle_to_buddy(handle);
>> -       if (buddy == MIDDLE)
>> -               clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>> -       spin_unlock(&pool->lock);
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

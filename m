Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id A60C66B0253
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 11:25:43 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id b35so76740622uaa.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:25:43 -0800 (PST)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id 73si10273275uat.14.2016.11.25.08.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 08:25:42 -0800 (PST)
Received: by mail-vk0-x241.google.com with SMTP id x186so1999869vkd.2
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:25:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONDVC+9s7G0MsXTYB8ZRjO1jJrT64F+O4i5t_dpV-6UCbQ@mail.gmail.com>
References: <20161115165538.878698352bd45e212751b57a@gmail.com>
 <20161115170030.f0396011fa00423ff711a3b4@gmail.com> <CALZtONDVC+9s7G0MsXTYB8ZRjO1jJrT64F+O4i5t_dpV-6UCbQ@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 25 Nov 2016 17:25:42 +0100
Message-ID: <CAMJBoFPBsWvBXjTtrNzCysC+UwYQi+Ld31pdJCHw0SR+geCVdg@mail.gmail.com>
Subject: Re: [PATCH 2/3] z3fold: don't fail kernel build if z3fold_header is
 too big
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>

On Fri, Nov 25, 2016 at 4:59 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Tue, Nov 15, 2016 at 11:00 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>> Currently the whole kernel build will be stopped if the size of
>> struct z3fold_header is greater than the size of one chunk, which
>> is 64 bytes by default. This may stand in the way of automated
>> test/debug builds so let's remove that and just fail the z3fold
>> initialization in such case instead.
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>> ---
>>  mm/z3fold.c | 11 ++++++++---
>>  1 file changed, 8 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> index 7ad70fa..ffd9353 100644
>> --- a/mm/z3fold.c
>> +++ b/mm/z3fold.c
>> @@ -870,10 +870,15 @@ MODULE_ALIAS("zpool-z3fold");
>>
>>  static int __init init_z3fold(void)
>>  {
>> -       /* Make sure the z3fold header will fit in one chunk */
>> -       BUILD_BUG_ON(sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED);
>
> Nak.  this is the wrong way to handle this.  The build bug is there to
> indicate to you that your patch makes the header too large, not as a
> runtime check to disable everything.

Okay, let's agree to drop it.

> The right way to handle it is to change the hardcoded assumption that
> the header fits into a single chunk; e.g.:
>
> #define ZHDR_SIZE_ALIGNED round_up(sizeof(struct z3fold_header), CHUNK_SIZE)
> #define ZHDR_CHUNKS (ZHDR_SIZE_ALIGNED >> CHUNK_SHIFT)
>
> then use ZHDR_CHUNKS in all places where it's currently assumed the
> header is 1 chunk, e.g. in num_free_chunks:
>
>   if (zhdr->middle_chunks != 0) {
>     int nfree_before = zhdr->first_chunks ?
> -      0 : zhdr->start_middle - 1;
> +      0 : zhdr->start_middle - ZHDR_CHUNKS;
>
> after changing all needed places like that, the build bug isn't needed
> anymore (unless we want to make sure the header isn't larger than some
> arbitrary number N chunks)

That sounds overly complicated to me. I would rather use bit_spin_lock
as Arnd suggested. What would you say?

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

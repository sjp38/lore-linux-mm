Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25D726B0038
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 10:51:05 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id q13so32464830vkd.3
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:51:05 -0800 (PST)
Received: from mail-ua0-x244.google.com (mail-ua0-x244.google.com. [2607:f8b0:400c:c08::244])
        by mx.google.com with ESMTPS id i64si10232852vkh.2.2016.11.25.07.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 07:51:04 -0800 (PST)
Received: by mail-ua0-x244.google.com with SMTP id b35so3701034uaa.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:51:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3177176.drX8hSSUx4@wuerfel>
References: <20161124163158.3939337-1-arnd@arndb.de> <1480007330.19726.11.camel@perches.com>
 <CAMJBoFN=32B3aaU2XyJO7dNmZ3gMxmOYboVoWH3z7ALosSdmUQ@mail.gmail.com> <3177176.drX8hSSUx4@wuerfel>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 25 Nov 2016 16:51:03 +0100
Message-ID: <CAMJBoFOo5e9N-2KqtjU=oRm24YO3gSG-zdT-z8XKw3USOwVvpw@mail.gmail.com>
Subject: Re: [PATCH] z3fold: use %z modifier for format string
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, zhong jiang <zhongjiang@huawei.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 25, 2016 at 9:41 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Friday, November 25, 2016 8:38:25 AM CET Vitaly Wool wrote:
>> >> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> >> index e282ba073e77..66ac7a7dc934 100644
>> >> --- a/mm/z3fold.c
>> >> +++ b/mm/z3fold.c
>> >> @@ -884,7 +884,7 @@ static int __init init_z3fold(void)
>> >>  {
>> >>       /* Fail the initialization if z3fold header won't fit in one chunk */
>> >>       if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
>> >> -             pr_err("z3fold: z3fold_header size (%d) is bigger than "
>> >> +             pr_err("z3fold: z3fold_header size (%zd) is bigger than "
>> >>                       "the chunk size (%d), can't proceed\n",
>> >>                       sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
>> >>               return -E2BIG;
>> >
>> > The embedded "z3fold: " prefix here should be removed
>> > as there's a pr_fmt that also adds it.
>> >
>> > The test looks like it should be a BUILD_BUG_ON rather
>> > than any runtime test too.
>>
>> It used to be BUILD_BUG_ON but we deliberately changed that because
>> sizeof(spinlock_t) gets bloated in debug builds, so it just won't
>> build with default CHUNK_SIZE.
>
> Could this be improved by making the CHUNK_SIZE bigger depending on
> the debug options?

I don't see how silently enforcing a suboptimal configuration is
better than failing the initialization (so that you can adjust
CHUNK_SIZE yourself). I can add something descriptive to
Documentation/vm/z3fold.txt for that matter.

> Alternatively, how about using a bit_spin_lock instead of raw_spin_lock?
> That would guarantee a fixed size for the lock and make z3fold_header
> always 24 bytes (on 32-bit architectures) or 40 bytes
> (on 64-bit architectures). You could even play some tricks with the
> first_num field to make it fit in the same word as the lock and make the
> structure fit into 32 bytes if you care about that.

That is interesting. Actually I can have that bit in page->private and
then I don't need to handle headless pages in a special way, that
sounds appealing. However, there is a warning about bit_spin_lock
performance penalty. Do you know how big it is?

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

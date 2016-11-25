Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2FC56B0261
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 02:38:26 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id 34so65663793uac.6
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:38:26 -0800 (PST)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id k189si9797459vkb.176.2016.11.24.23.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 23:38:26 -0800 (PST)
Received: by mail-ua0-x243.google.com with SMTP id b35so3109823uaa.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:38:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1480007330.19726.11.camel@perches.com>
References: <20161124163158.3939337-1-arnd@arndb.de> <1480007330.19726.11.camel@perches.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 25 Nov 2016 08:38:25 +0100
Message-ID: <CAMJBoFN=32B3aaU2XyJO7dNmZ3gMxmOYboVoWH3z7ALosSdmUQ@mail.gmail.com>
Subject: Re: [PATCH] z3fold: use %z modifier for format string
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, zhong jiang <zhongjiang@huawei.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Joe,

On Thu, Nov 24, 2016 at 6:08 PM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2016-11-24 at 17:31 +0100, Arnd Bergmann wrote:
>> Printing a size_t requires the %zd format rather than %d:
>>
>> mm/z3fold.c: In function =E2=80=98init_z3fold=E2=80=99:
>> include/linux/kern_levels.h:4:18: error: format =E2=80=98%d=E2=80=99 exp=
ects argument of type =E2=80=98int=E2=80=99, but argument 2 has type =E2=80=
=98long unsigned int=E2=80=99 [-Werror=3Dformat=3D]
>>
>> Fixes: 50a50d2676c4 ("z3fold: don't fail kernel build if z3fold_header i=
s too big")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>  mm/z3fold.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> index e282ba073e77..66ac7a7dc934 100644
>> --- a/mm/z3fold.c
>> +++ b/mm/z3fold.c
>> @@ -884,7 +884,7 @@ static int __init init_z3fold(void)
>>  {
>>       /* Fail the initialization if z3fold header won't fit in one chunk=
 */
>>       if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
>> -             pr_err("z3fold: z3fold_header size (%d) is bigger than "
>> +             pr_err("z3fold: z3fold_header size (%zd) is bigger than "
>>                       "the chunk size (%d), can't proceed\n",
>>                       sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
>>               return -E2BIG;
>
> The embedded "z3fold: " prefix here should be removed
> as there's a pr_fmt that also adds it.
>
> The test looks like it should be a BUILD_BUG_ON rather
> than any runtime test too.

It used to be BUILD_BUG_ON but we deliberately changed that because
sizeof(spinlock_t) gets bloated in debug builds, so it just won't
build with default CHUNK_SIZE.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

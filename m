Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id A35196B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 15:04:11 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id hy4so2458490vcb.14
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:04:11 -0700 (PDT)
Received: from mail-vc0-x233.google.com (mail-vc0-x233.google.com. [2607:f8b0:400c:c03::233])
        by mx.google.com with ESMTPS id aa4si10765307vdc.56.2014.10.22.12.04.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 12:04:10 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so2451818vcb.10
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:04:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141022114437.72eb61ce3e2348c52ab3d1db@linux-foundation.org>
References: <1413915307-20536-1-git-send-email-sasha.levin@oracle.com>
	<544743D6.6040103@samsung.com>
	<20141022114437.72eb61ce3e2348c52ab3d1db@linux-foundation.org>
Date: Wed, 22 Oct 2014 23:04:10 +0400
Message-ID: <CAPAsAGxELx7+A=dujXeo4gqA+DUvQHgKw=gp8iLHvvQwCy2VNw@mail.gmail.com>
Subject: Re: [PATCH] mm, hugetlb: correct bit shift in hstate_sizelog
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2014-10-22 22:44 GMT+04:00 Andrew Morton <akpm@linux-foundation.org>:
> On Wed, 22 Oct 2014 09:42:46 +0400 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>
>> On 10/21/2014 10:15 PM, Sasha Levin wrote:
>> > hstate_sizelog() would shift left an int rather than long, triggering
>> > undefined behaviour and passing an incorrect value when the requested
>> > page size was more than 4GB, thus breaking >4GB pages.
>>
>> >
>> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> > ---
>> >  include/linux/hugetlb.h |    3 ++-
>> >  1 file changed, 2 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> > index 65e12a2..57e0dfd 100644
>> > --- a/include/linux/hugetlb.h
>> > +++ b/include/linux/hugetlb.h
>> > @@ -312,7 +312,8 @@ static inline struct hstate *hstate_sizelog(int page_size_log)
>> >  {
>> >     if (!page_size_log)
>> >             return &default_hstate;
>> > -   return size_to_hstate(1 << page_size_log);
>> > +
>> > +   return size_to_hstate(1UL << page_size_log);
>>
>> That still could be undefined on 32-bits. Either use 1ULL or reduce SHM_HUGE_MASK on 32bits.
>>
>
> But
>
> struct hstate *size_to_hstate(unsigned long size)
>

What's wrong? On 32 bits, if page_size_log >= 32, then  (unsingned
long)(1ULL << page_size_log) will be truncated to 0. I guess it's ok.
size_to_hstate will just return NULL in that case.


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

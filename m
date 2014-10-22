Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id DA7C16B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 16:26:54 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id hy4so2562470vcb.14
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 13:26:54 -0700 (PDT)
Received: from mail-vc0-x22f.google.com (mail-vc0-x22f.google.com. [2607:f8b0:400c:c03::22f])
        by mx.google.com with ESMTPS id az6si10893790vdd.39.2014.10.22.13.26.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 13:26:54 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id id10so2487149vcb.6
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 13:26:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141022131308.361a72ba7c6fbf1bd778445a@linux-foundation.org>
References: <1413915307-20536-1-git-send-email-sasha.levin@oracle.com>
	<544743D6.6040103@samsung.com>
	<20141022114437.72eb61ce3e2348c52ab3d1db@linux-foundation.org>
	<5447FC6E.2000207@oracle.com>
	<20141022131308.361a72ba7c6fbf1bd778445a@linux-foundation.org>
Date: Thu, 23 Oct 2014 00:26:53 +0400
Message-ID: <CAPAsAGw2cTF39KbnNb0Ug21KRmnkJrXobYYGPiVhzTCg=BCh0w@mail.gmail.com>
Subject: Re: [PATCH] mm, hugetlb: correct bit shift in hstate_sizelog
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2014-10-23 0:13 GMT+04:00 Andrew Morton <akpm@linux-foundation.org>:
> On Wed, 22 Oct 2014 14:50:22 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>
>> On 10/22/2014 02:44 PM, Andrew Morton wrote:
>> > On Wed, 22 Oct 2014 09:42:46 +0400 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>> >
>> >> > On 10/21/2014 10:15 PM, Sasha Levin wrote:
>> >>> > > hstate_sizelog() would shift left an int rather than long, triggering
>> >>> > > undefined behaviour and passing an incorrect value when the requested
>> >>> > > page size was more than 4GB, thus breaking >4GB pages.
>> >> >
>> >>> > >
>> >>> > > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> >>> > > ---
>> >>> > >  include/linux/hugetlb.h |    3 ++-
>> >>> > >  1 file changed, 2 insertions(+), 1 deletion(-)
>> >>> > >
>> >>> > > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> >>> > > index 65e12a2..57e0dfd 100644
>> >>> > > --- a/include/linux/hugetlb.h
>> >>> > > +++ b/include/linux/hugetlb.h
>> >>> > > @@ -312,7 +312,8 @@ static inline struct hstate *hstate_sizelog(int page_size_log)
>> >>> > >  {
>> >>> > >       if (!page_size_log)
>> >>> > >               return &default_hstate;
>> >>> > > -     return size_to_hstate(1 << page_size_log);
>> >>> > > +
>> >>> > > +     return size_to_hstate(1UL << page_size_log);
>> >> >
>> >> > That still could be undefined on 32-bits. Either use 1ULL or reduce SHM_HUGE_MASK on 32bits.
>> >> >
>> > But
>> >
>> > struct hstate *size_to_hstate(unsigned long size)
>>
>> True, but "(1 << page_size_log)" produces an integer rather than long because "1"
>> is an int and not long.
>
> My point is that there's no point in using 1ULL because
> size_to_hstate() will truncate it anyway.
>

There is a point to use 1ULL
On 32-bit with size >= 32
(1UL << size) - undefined, so size_to_hstate() will truncate it to
undefined as well. E.g. It definitely won't be zero on x86.
While (1ULL << size) - is defined and size_to_hstate() will truncate it to zero.


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

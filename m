Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F013C4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 08:33:53 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id q99so604901ota.6
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 05:33:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 36sor1422654ots.149.2017.11.08.05.33.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 05:33:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171108075242.GB18747@js1304-P5Q-DELUXE>
References: <CGME20171107094311epcas1p4a5dd975d6e9f3618a26a0a5d68c68b55@epcas1p4.samsung.com>
 <20171107094447.14763-1-jaewon31.kim@samsung.com> <20171108075242.GB18747@js1304-P5Q-DELUXE>
From: Jaewon Kim <jaewon31.kim@gmail.com>
Date: Wed, 8 Nov 2017 22:33:51 +0900
Message-ID: <CAJrd-UtqWQiqgtfZQDxt18BnqYFgOZOw9pqNJY6UUp71POLOpQ@mail.gmail.com>
Subject: Re: [PATCH] mm: page_ext: allocate page extension though first PFN is invalid
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2017-11-08 16:52 GMT+09:00 Joonsoo Kim <iamjoonsoo.kim@lge.com>:
> On Tue, Nov 07, 2017 at 06:44:47PM +0900, Jaewon Kim wrote:
>> online_page_ext and page_ext_init allocate page_ext for each section, but
>> they do not allocate if the first PFN is !pfn_present(pfn) or
>> !pfn_valid(pfn).
>>
>> Though the first page is not valid, page_ext could be useful for other
>> pages in the section. But checking all PFNs in a section may be time
>> consuming job. Let's check each (section count / 16) PFN, then prepare
>> page_ext if any PFN is present or valid.
>
> I guess that this kind of section is not so many. And, this is for
> debugging so completeness would be important. It's better to check
> all pfn in the section.
Thank you for your comment.

AFAIK physical memory address depends on HW SoC.
Sometimes a SoC remains few GB address region hole between few GB DRAM
and other few GB DRAM
such as 2GB under 4GB address and 2GB beyond 4GB address and holes between them.
If SoC designs so big hole between actual mapping, I thought too much
time will be spent on just checking all the PFNs.

Anyway if we decide to check all PFNs, I can change patch to t_pfn++ like below.
Please give me comment again.


while (t_pfn <  ALIGN(pfn + 1, PAGES_PER_SECTION)) {
        if (pfn_valid(t_pfn)) {
                valid = true;
                break;
        }
-        t_pfn = ALIGN(pfn + 1, PAGES_PER_SECTION >> 4);
+        t_pfn++;


Thank you
Jaewon Kim

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

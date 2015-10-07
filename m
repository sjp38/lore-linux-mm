Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 99EF36B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 00:44:53 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so9930907ioi.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 21:44:53 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id x10si896458igl.47.2015.10.06.21.44.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 21:44:53 -0700 (PDT)
Received: by ioiz6 with SMTP id z6so9930784ioi.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 21:44:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151006135303.GA31853@blaptop>
References: <1444033381-5726-1-git-send-email-zhuhui@xiaomi.com> <20151006135303.GA31853@blaptop>
From: Hui Zhu <teawater@gmail.com>
Date: Wed, 7 Oct 2015 12:44:13 +0800
Message-ID: <CANFwon0vdedkwe=dKiV2B833QeQ_kaDxvoi306gAQ=HJhsY5Bw@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: fix obj_to_head use page_private(page) as value
 but not pointer
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hui Zhu <zhuhui@xiaomi.com>, ngupta@vflare.org, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Oct 6, 2015 at 9:54 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hello,
>
> On Mon, Oct 05, 2015 at 04:23:01PM +0800, Hui Zhu wrote:
>> In function obj_malloc:
>>       if (!class->huge)
>>               /* record handle in the header of allocated chunk */
>>               link->handle = handle;
>>       else
>>               /* record handle in first_page->private */
>>               set_page_private(first_page, handle);
>> The huge's page save handle to private directly.
>>
>> But in obj_to_head:
>>       if (class->huge) {
>>               VM_BUG_ON(!is_first_page(page));
>>               return page_private(page);
>
> Typo.
>                 return *(unsigned long*)page_private(page);
>
> Please fix the description.
>
>>       } else
>>               return *(unsigned long *)obj;
>> It is used as a pointer.
>>
>> So change obj_to_head use page_private(page) as value but not pointer
>> in obj_to_head.
>
> The reason why there is no problem until now is huge-class page is
> born with ZS_FULL so it couldn't be migrated.
> Therefore, it shouldn't be real bug in practice.
> However, we need this patch for future-work "VM-aware zsmalloced
> page migration" to reduce external fragmentation.
>
>>
>> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
>
> With fixing the comment,
>
> Acked-by: Minchan Kim <minchan@kernel.org>
>
> Thanks for the fix, Hui.
>

Thanks!  I will post a new version.

Best,
Hui

> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

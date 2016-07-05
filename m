Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95B176B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 21:39:30 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j185so197354671ith.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:39:30 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id w200si401447oie.103.2016.07.04.18.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 18:39:29 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id u201so211612148oie.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:39:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160630123443.GA18789@dhcp22.suse.cz>
References: <CAOVJa8EPGfWwLtAY8YNOzBqG99J7xL0dMrRmvXs0d8GaXJF9Xw@mail.gmail.com>
 <20160630123443.GA18789@dhcp22.suse.cz>
From: pierre kuo <vichy.kuo@gmail.com>
Date: Tue, 5 Jul 2016 09:39:28 +0800
Message-ID: <CAOVJa8FF-1Gc=j52KePWOfe3WMFZ9De5BA4wDEJu0F5Nmehh+A@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: allocate order 0 page from pcb before zone_watermark_ok
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

hi Michal
2016-06-30 20:35 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 29-06-16 22:44:19, vichy wrote:
>> hi all:
>> In normal case, the allocation of any order page started after
>> zone_watermark_ok. But if so far pcp->count of this zone is not 0,
>> why don't we just let order-0-page allocation before zone_watermark_ok.
>> That mean the order-0-page will be successfully allocated even
>> free_pages is beneath zone->watermark.
>
> The watermark check has a good reason. It protects the memory reserves
> which are used for important users or emergency situations. The mere
> fact that there are pages available for the pcp usage doesn't mean that
> we should break this protection. Note that those emergency users might
> want order 0 pages as well.
Got it.
And due to your friendly reminder I found the "emergency users" you
mean, the cases in gfp_to_alloc_flags that will return with
ALLOC_NO_WATERMARKS as below
    if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
        if (gfp_mask & __GFP_MEMALLOC)
            alloc_flags |= ALLOC_NO_WATERMARKS;
        else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
            alloc_flags |= ALLOC_NO_WATERMARKS;
        else if (!in_interrupt() &&
                ((current->flags & PF_MEMALLOC) ||
                 unlikely(test_thread_flag(TIF_MEMDIE))))
            alloc_flags |= ALLOC_NO_WATERMARKS;
    }

Appreciate your kind review,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

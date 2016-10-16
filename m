Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9FA6B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 07:01:24 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z65so45837519itc.2
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 04:01:24 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id u1si3682378ite.80.2016.10.16.04.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 04:01:23 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id 139so20038077itm.1
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 04:01:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161014152615.GB6105@dhcp22.suse.cz>
References: <CADUS3okBoQNW_mzgZnfr6evK2Qrx2TDtPygqnodn0CwtSyrA8w@mail.gmail.com>
 <20161014152615.GB6105@dhcp22.suse.cz>
From: yoma sophian <sophian.yoma@gmail.com>
Date: Sun, 16 Oct 2016 19:01:23 +0800
Message-ID: <CADUS3o=64pZae+Nq302RSRukCd3beRCtm3Ch=iDVkrPSUOODZw@mail.gmail.com>
Subject: Re: some question about order0 page allocation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

 hi michal:

2016-10-14 23:26 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> On Fri 14-10-16 17:29:34, yoma sophian wrote:
> [...]
>> [ 5515.127555] dialog invoked oom-killer: gfp_mask=0x80d0, order=0,
>> oom_score_adj=0
>
> This looks like a GFP_KERNEL + something allocation
Yes, you are correct.
The page is allocated with GFP as (KERNEL + ZERO) flag
>
>> [ 5515.444859] Normal: 4314*4kB (UEMC) 3586*8kB (UMC) 131*16kB (MC)
>> 21*32kB (C) 6*64kB (C) 1*128kB (C) 0*256kB 0*512kB 0*1024kB 0*2048kB
>> 0*4096kB = 49224kB
>
> And it seems like CMA blocks are spread in all orders and no unmovable
> allocations can fallback in them. It seems that there should be some
> movable blocks but I do not have any idea why those are not used. Anyway
> this is where I would start investigating.
Per your kind hint, I trace pcp page allocation again.(since the order
of allocation is 0 this time)
I found when the list of pcp with unmovable type is empty, it will
call rmqueue_bulk for trying to get batch, 31 order-0 pages.
And rmqueue_bulk will call __rmqueue_smallest and even
__rmqueue_fallback once the buddy of unmovable memory is not enough.

But from below message:
[ 5515.444859] Normal: 4314*4kB (UEMC) 3586*8kB (UMC)
the order 0 of U type in buddy is at least has 1 page free.
That mean even there is not enough 32 order-0 pages with U in buddy
right now, buddy can at least provide 1 page to satisfy this
allocation.
if my conclusion is correct, there is no need for fallback.
Please correct me, if I am wrong.

Sincerely appreciate your kind help,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CBFA6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 09:12:30 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id y9so307836411ywy.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 06:12:30 -0700 (PDT)
Received: from mail-yw0-f170.google.com (mail-yw0-f170.google.com. [209.85.161.170])
        by mx.google.com with ESMTPS id o63si8349521ywd.187.2016.10.17.06.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 06:12:29 -0700 (PDT)
Received: by mail-yw0-f170.google.com with SMTP id w3so114240002ywg.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 06:12:29 -0700 (PDT)
Date: Mon, 17 Oct 2016 15:12:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: some question about order0 page allocation
Message-ID: <20161017131228.GM23322@dhcp22.suse.cz>
References: <CADUS3okBoQNW_mzgZnfr6evK2Qrx2TDtPygqnodn0CwtSyrA8w@mail.gmail.com>
 <20161014152615.GB6105@dhcp22.suse.cz>
 <CADUS3o=64pZae+Nq302RSRukCd3beRCtm3Ch=iDVkrPSUOODZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUS3o=64pZae+Nq302RSRukCd3beRCtm3Ch=iDVkrPSUOODZw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yoma sophian <sophian.yoma@gmail.com>
Cc: linux-mm@kvack.org

On Sun 16-10-16 19:01:23, yoma sophian wrote:
>  hi michal:
> 
> 2016-10-14 23:26 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> > On Fri 14-10-16 17:29:34, yoma sophian wrote:
> > [...]
> >> [ 5515.127555] dialog invoked oom-killer: gfp_mask=0x80d0, order=0,
> >> oom_score_adj=0
> >
> > This looks like a GFP_KERNEL + something allocation
> Yes, you are correct.
> The page is allocated with GFP as (KERNEL + ZERO) flag
> >
> >> [ 5515.444859] Normal: 4314*4kB (UEMC) 3586*8kB (UMC) 131*16kB (MC)
> >> 21*32kB (C) 6*64kB (C) 1*128kB (C) 0*256kB 0*512kB 0*1024kB 0*2048kB
> >> 0*4096kB = 49224kB
> >
> > And it seems like CMA blocks are spread in all orders and no unmovable
> > allocations can fallback in them. It seems that there should be some
> > movable blocks but I do not have any idea why those are not used. Anyway
> > this is where I would start investigating.
> Per your kind hint, I trace pcp page allocation again.(since the order
> of allocation is 0 this time)
> I found when the list of pcp with unmovable type is empty, it will
> call rmqueue_bulk for trying to get batch, 31 order-0 pages.
> And rmqueue_bulk will call __rmqueue_smallest and even
> __rmqueue_fallback once the buddy of unmovable memory is not enough.
> 
> But from below message:
> [ 5515.444859] Normal: 4314*4kB (UEMC) 3586*8kB (UMC)
> the order 0 of U type in buddy is at least has 1 page free.
> That mean even there is not enough 32 order-0 pages with U in buddy
> right now, buddy can at least provide 1 page to satisfy this
> allocation.
> if my conclusion is correct, there is no need for fallback.
> Please correct me, if I am wrong.

I am not deeply familiar with the mobility code, more so for an old
kernel, but my general understanding is that that the migrate type
information is not exact and there are races possible. Maybe there are
even accounting bugs in such an old kernel. Do you see the same problem
with the current upstream kernel?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

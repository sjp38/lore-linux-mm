Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 122B76B0120
	for <linux-mm@kvack.org>; Wed, 27 May 2015 00:10:24 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so107573087pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 21:10:23 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id l15si23918888pbq.72.2015.05.26.21.10.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 21:10:23 -0700 (PDT)
Received: by pdea3 with SMTP id a3so107627791pde.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 21:10:22 -0700 (PDT)
Date: Wed, 27 May 2015 13:10:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info
 allocator
Message-ID: <20150527041015.GB11609@blaptop>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com>
 <20150525144045.GE14922@blaptop>
 <D5CD4D44-77BC-4817-B9A7-60C0F4AE444F@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D5CD4D44-77BC-4817-B9A7-60C0F4AE444F@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, barami97@gmail.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Jungseok,

On Tue, May 26, 2015 at 08:29:59PM +0900, Jungseok Lee wrote:
> On May 25, 2015, at 11:40 PM, Minchan Kim wrote:
> > Hello Jungseok,
> 
> Hi, Minchan,
> 
> > On Mon, May 25, 2015 at 01:02:20AM +0900, Jungseok Lee wrote:
> >> Fork-routine sometimes fails to get a physically contiguous region for
> >> thread_info on 4KB page system although free memory is enough. That is,
> >> a physically contiguous region, which is currently 16KB, is not available
> >> since system memory is fragmented.
> > 
> > Order less than PAGE_ALLOC_COSTLY_ORDER should not fail in current
> > mm implementation. If you saw the order-2,3 high-order allocation fail
> > maybe your application received SIGKILL by someone. LMK?
> 
> Exactly right. The allocation is failed via the following path.
> 
> if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> 	goto nopage;
> 
> IMHO, a reclaim operation would be not needed in this context if memory is
> allocated from vmalloc space. It means there is no need to traverse shrinker list. 

For making fork successful with using vmalloc, it's bandaid.

> 
> >> This patch tries to solve the problem as allocating thread_info memory
> >> from vmalloc space, not 1:1 mapping one. The downside is one additional
> >> page allocation in case of vmalloc. However, vmalloc space is large enough,
> > 
> > The size you want to allocate is 16KB in here but additional 4K?
> > It increases 25% memory footprint, which is huge downside.
> 
> I agree with the point, and most people who try to use vmalloc might know the number.
> However, an interoperation on the number depends on a point of view.
> 
> Vmalloc is large enough and not fully utilized in case of ARM64.
> With the considerations, there is a room to do math as follows.
> 
> 4KB / 240GB = 1.5e-8 (4KB page + 3 level combo)
> 
> It would be not a huge downside if fork-routine is not damaged due to fragmentation.

Okay, address size point of view, it wouldn't be significant problem.
Then, let's see it performance as point of view.

If we use vmalloc, it needs additional data structure for vmalloc
management, several additional allocation request, page table hanlding
and TLB flush.

Normally, forking is very frequent operation so we shouldn't do
make it slow and memory consumption bigger if there isn't big reason.

> 
> However, this is one of reasons to add "RFC" prefix in the patch set. How is the
> additional 4KB interpreted and considered?
> 
> Best Regards
> Jungseok Lee

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

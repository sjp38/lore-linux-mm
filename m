Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3519A6B0280
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 18:56:14 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id wk8so172102354pab.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 15:56:14 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 142si4121766pfy.166.2016.09.22.15.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 15:56:13 -0700 (PDT)
Date: Thu, 22 Sep 2016 15:56:08 -0700
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160922225608.GA3898@kernel.org>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
> 
> The advantages of the THP swap support include:
> 
> - Batch the swap operations for the THP to reduce lock
>   acquiring/releasing, including allocating/freeing the swap space,
>   adding/deleting to/from the swap cache, and writing/reading the swap
>   space, etc.  This will help improve the performance of the THP swap.
> 
> - The THP swap space read/write will be 2M sequential IO.  It is
>   particularly helpful for the swap read, which usually are 4k random
>   IO.  This will improve the performance of the THP swap too.

I think this is not a problem. Even with current early split, we are allocating
swap entry sequentially, after IO is dispatched, block layer will merge IO to
big size.

> - It will help the memory fragmentation, especially when the THP is
>   heavily used by the applications.  The 2M continuous pages will be
>   free up after THP swapping out.

So this is impossible without THP swapin. While 2M swapout makes a lot of
sense, I doubt 2M swapin is really useful. What kind of application is
'optimized' to do sequential memory access?

One advantage of THP swapout is to reduce TLB flush. Eg, when we split 2m to 4k
pages, we set swap entry for the 4k pages since your patch already allocates
swap entry before the split, so we only do tlb flush once in the split. Without
the delay THP split, we do twice tlb flush (split and unmap of swapout). I
don't see this in the patches, do I misread the code?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

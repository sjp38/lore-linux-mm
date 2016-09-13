Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1A06B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 10:35:54 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id c79so49671154ybf.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 07:35:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a4si6050026ywc.404.2016.09.13.07.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 07:35:53 -0700 (PDT)
Date: Tue, 13 Sep 2016 16:35:48 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160913143548.GP19048@redhat.com>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160909054336.GA2114@bbox>
 <87sht824n3.fsf@yhuang-mobile.sh.intel.com>
 <20160913061349.GA4445@bbox>
 <87y42wgv5r.fsf@yhuang-dev.intel.com>
 <20160913070524.GA4973@bbox>
 <87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hello,

On Tue, Sep 13, 2016 at 04:53:49PM +0800, Huang, Ying wrote:
> I am glad to discuss my final goal, that is, swapping out/in the full
> THP without splitting.  Why I want to do that is copied as below,

I think that is a fine objective. It wasn't implemented initially just
to keep things simple.

Doing it will reduce swap fragmentation (provided we can find a
physically contiguous piece of to swapout the THP in the first place)
and it will make all other heuristics that tries to keep the swap
space contiguous less relevant and it should increase the swap
bandwidth significantly at least on spindle disks. I personally see it
as a positive that we relay less on those and the readhaead swapin.

> >> >> The disadvantage are:
> >> >> 
> >> >> - Increase the memory pressure when swap in THP.

That is always true with THP enabled to always. It is the tradeoff. It
still cannot use more RAM than userland ever allocated in the vma as
virtual memory. If userland don't ever need such memory it can free it
by zapping the vma and the THP will be splitted. If the vma is zapped
while the THP is natively swapped out, the zapped portion of swap
space shall be released as well. So ultimately userland always
controls the cap on the max virtual memory (ram+swap) the kernel
decides to use with THP enabled to always.

> I think it is important to use 2M pages as much as possible to deal with
> the big memory problem.  Do you agree?

I agree.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

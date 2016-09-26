Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41FCA28026B
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 21:06:32 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id cg13so325730978pac.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:06:32 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id r63si22133731pfi.132.2016.09.25.18.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 18:06:31 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id hm5so894177pac.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:06:31 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Date: Mon, 26 Sep 2016 10:06:20 +0900
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160926010620.GA2502@blaptop>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160922225608.GA3898@kernel.org>
 <1474591086.17726.1.camel@redhat.com>
 <87d1jvuz08.fsf@yhuang-dev.intel.com>
 <20160925191849.GA83300@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160925191849.GA83300@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Sun, Sep 25, 2016 at 12:18:49PM -0700, Shaohua Li wrote:
> On Fri, Sep 23, 2016 at 10:32:39AM +0800, Huang, Ying wrote:
> > Rik van Riel <riel@redhat.com> writes:
> > 
> > > On Thu, 2016-09-22 at 15:56 -0700, Shaohua Li wrote:
> > >> On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
> > >> > 
> > >> > - It will help the memory fragmentation, especially when the THP is
> > >> >   heavily used by the applications.  The 2M continuous pages will
> > >> > be
> > >> >   free up after THP swapping out.
> > >> 
> > >> So this is impossible without THP swapin. While 2M swapout makes a
> > >> lot of
> > >> sense, I doubt 2M swapin is really useful. What kind of application
> > >> is
> > >> 'optimized' to do sequential memory access?
> > >
> > > I suspect a lot of this will depend on the ratio of storage
> > > speed to CPU & RAM speed.
> > >
> > > When swapping to a spinning disk, it makes sense to avoid
> > > extra memory use on swapin, and work in 4kB blocks.
> > 
> > For spinning disk, the THP swap optimization will be turned off in
> > current implementation.  Because huge swap cluster allocation based on
> > swap cluster management, which is available only for non-rotating block
> > devices (blk_queue_nonrot()).
> 
> For 2m swapin, as long as one byte is changed in the 2m, next time we must do
> 2m swapout. There is huge waste of memory and IO bandwidth and increases
> unnecessary memory pressure. 2M IO will very easily saturate a very fast SSD

I agree. No doubt THP swapout is helpful for overall performance but
THP swapin should be more careful. It would cause memory pressure which
could evict warm pages which mitigates THP's benefit. THP swapin also
would increase minor fault latency, too.

If we want to swap in a THP, I think we need something to guarantee that
subpages in a THP swapped out were hot and temporal locality so that
it's worth to swap in a THP page to lose other memory kept in in memory.

Maybe it would not matter so much in MADVISE mode where userspace knows
pros and cons and choosed it. The problem would be there in ALWAYS mode.

One of idea is we can raise bar to collapse THP page higher, for example,
reducing khugepaged_max_ptes_none and introducing khugepaged_max_pte_ref.
With that, khugepaged would collapse 4K pages into a THP only if most of
subpages are mapped and hot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

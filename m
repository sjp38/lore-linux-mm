Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A573280266
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:18:55 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fi2so71270102pad.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 12:18:55 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 65si6218059pfh.155.2016.09.25.12.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 12:18:54 -0700 (PDT)
Date: Sun, 25 Sep 2016 12:18:49 -0700
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160925191849.GA83300@kernel.org>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160922225608.GA3898@kernel.org>
 <1474591086.17726.1.camel@redhat.com>
 <87d1jvuz08.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87d1jvuz08.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 23, 2016 at 10:32:39AM +0800, Huang, Ying wrote:
> Rik van Riel <riel@redhat.com> writes:
> 
> > On Thu, 2016-09-22 at 15:56 -0700, Shaohua Li wrote:
> >> On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
> >> > 
> >> > - It will help the memory fragmentation, especially when the THP is
> >> >   heavily used by the applications.  The 2M continuous pages will
> >> > be
> >> >   free up after THP swapping out.
> >> 
> >> So this is impossible without THP swapin. While 2M swapout makes a
> >> lot of
> >> sense, I doubt 2M swapin is really useful. What kind of application
> >> is
> >> 'optimized' to do sequential memory access?
> >
> > I suspect a lot of this will depend on the ratio of storage
> > speed to CPU & RAM speed.
> >
> > When swapping to a spinning disk, it makes sense to avoid
> > extra memory use on swapin, and work in 4kB blocks.
> 
> For spinning disk, the THP swap optimization will be turned off in
> current implementation.  Because huge swap cluster allocation based on
> swap cluster management, which is available only for non-rotating block
> devices (blk_queue_nonrot()).

For 2m swapin, as long as one byte is changed in the 2m, next time we must do
2m swapout. There is huge waste of memory and IO bandwidth and increases
unnecessary memory pressure. 2M IO will very easily saturate a very fast SSD
and makes IO the bottleneck. Not sure about NVRAM though.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

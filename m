Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDCAB6B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:19:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so1022284pgq.5
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 06:19:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m4-v6si1211506pll.461.2018.07.26.06.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 06:19:29 -0700 (PDT)
Date: Thu, 26 Jul 2018 15:19:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] RFC: clear 1G pages with streaming stores on x86
Message-ID: <20180726131927.GK28386@dhcp22.suse.cz>
References: <20180724210923.GA20168@bombadil.infradead.org>
 <20180725023728.44630-1-cannonmatthews@google.com>
 <20180725125741.GL28386@dhcp22.suse.cz>
 <CAJfu=UcVygNivApyumjTBn897yZmU=VD3WGuPioRDDrkej1XKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfu=UcVygNivApyumjTBn897yZmU=VD3WGuPioRDDrkej1XKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: mike.kravetz@oracle.com, akpm@linux-foundation.org, willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>, ying.huang@intel.com

On Wed 25-07-18 10:55:40, Cannon Matthews wrote:
> On Wed, Jul 25, 2018 at 5:57 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > [Cc Huang]
> > On Tue 24-07-18 19:37:28, Cannon Matthews wrote:
> > > Reimplement clear_gigantic_page() to clear gigabytes pages using the
> > > non-temporal streaming store instructions that bypass the cache
> > > (movnti), since an entire 1GiB region will not fit in the cache anyway.
> > >
> > > Doing an mlock() on a 512GiB 1G-hugetlb region previously would take on
> > > average 134 seconds, about 260ms/GiB which is quite slow. Using `movnti`
> > > and optimizing the control flow over the constituent small pages, this
> > > can be improved roughly by a factor of 3-4x, with the 512GiB mlock()
> > > taking only 34 seconds on average, or 67ms/GiB.
> > >
> > > The assembly code for the __clear_page_nt routine is more or less
> > > taken directly from the output of gcc with -O3 for this function with
> > > some tweaks to support arbitrary sizes and moving memory barriers:
> > >
> > > void clear_page_nt_64i (void *page)
> > > {
> > >   for (int i = 0; i < GiB /sizeof(long long int); ++i)
> > >     {
> > >       _mm_stream_si64 (((long long int*)page) + i, 0);
> > >     }
> > >   sfence();
> > > }
> > >
> > > In general I would love to hear any thoughts and feedback on this
> > > approach and any ways it could be improved.
> >
> > Well, I like it. In fact 2MB pages are in a similar situation even
> > though they fit into the cache so the problem is not that pressing.
> > Anyway if you are a standard DB wokrload which simply preallocates large
> > hugetlb shared files then it would help. Huang has gone a different
> > direction c79b57e462b5 ("mm: hugetlb: clear target sub-page last when
> > clearing huge page") and I was asking about using the mechanism you are
> > proposing back then http://lkml.kernel.org/r/20170821115235.GD25956@dhcp22.suse.cz
> > I've got an explanation http://lkml.kernel.org/r/87h8x0whfs.fsf@yhuang-dev.intel.com
> > which hasn't really satisfied me but I didn't really want to block the
> > obvious optimization. The similar approach has been proposed for GB
> > pages IIRC but I do not see it in linux-next so I am not sure what
> > happened with it.
> >
> > Is there any reason to use a different scheme for GB an 2MB pages? Why
> > don't we settle with movnti for both? The first access will be a miss
> > but I am not really sure it matters all that much.
> >
> My only hesitation is that while the benefits of doing it faster seem
> obvious at a 1GiB granularity, things become more subtle at 2M, and
> they are used much more frequently, where negative impacts from this
> approach could outweigh.

Well, one would expect that even 2M huge pages would be long lived. And
that is usually the case for hugetlb pages which are usually
preallocated and pre-faulted/initialized during the startup.

> Not that that is actually the case, but I am not familiar enough to be
> confident proposing that, especially when it gets into the stuff in
> that response you liked about synchronous RAM loads and such.
>
> With the right benchmarking we could certainly motivate it one way or
> the other, but I wouldn't know where to begin to do so in a robust
> enough way.
>
> For the first access being a miss, there is the suggestion that Robert
> Elliot had above of doing a normal caching store on the sub-page
> that contains the faulting address, as an optimization to avoid
> that. Perhaps that would be enough.

Well, currently we are initializating pages towards the faulting address
(from both ends). Extending that to non-temporal mov shouldn't be hard.
-- 
Michal Hocko
SUSE Labs

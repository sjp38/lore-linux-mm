Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA056B4306
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 19:25:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r25-v6so13367edc.7
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 16:25:41 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e18-v6si554716edb.332.2018.08.27.16.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 16:25:39 -0700 (PDT)
Date: Mon, 27 Aug 2018 16:24:58 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 3/3] mm: don't miss the last page because of round-off
 error
Message-ID: <20180827232456.GA20631@tower.DHCP.thefacebook.com>
References: <20180827162621.30187-1-guro@fb.com>
 <20180827162621.30187-3-guro@fb.com>
 <20180827140432.b3c792f60235a13739038808@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180827140432.b3c792f60235a13739038808@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>

On Mon, Aug 27, 2018 at 02:04:32PM -0700, Andrew Morton wrote:
> On Mon, 27 Aug 2018 09:26:21 -0700 Roman Gushchin <guro@fb.com> wrote:
> 
> > I've noticed, that dying memory cgroups are  often pinned
> > in memory by a single pagecache page. Even under moderate
> > memory pressure they sometimes stayed in such state
> > for a long time. That looked strange.
> > 
> > My investigation showed that the problem is caused by
> > applying the LRU pressure balancing math:
> > 
> >   scan = div64_u64(scan * fraction[lru], denominator),
> > 
> > where
> > 
> >   denominator = fraction[anon] + fraction[file] + 1.
> > 
> > Because fraction[lru] is always less than denominator,
> > if the initial scan size is 1, the result is always 0.
> > 
> > This means the last page is not scanned and has
> > no chances to be reclaimed.
> > 
> > Fix this by rounding up the result of the division.
> > 
> > In practice this change significantly improves the speed
> > of dying cgroups reclaim.
> > 
> > ...
> >
> > --- a/include/linux/math64.h
> > +++ b/include/linux/math64.h
> > @@ -281,4 +281,6 @@ static inline u64 mul_u64_u32_div(u64 a, u32 mul, u32 divisor)
> >  }
> >  #endif /* mul_u64_u32_div */
> >  
> > +#define DIV64_U64_ROUND_UP(ll, d)	div64_u64((ll) + (d) - 1, (d))
> 
> This macro references arg `d' more than once.  That can cause problems
> if the passed expression has side-effects and is poor practice.  Can
> we please redo this with a temporary?

Sure. This was copy-pasted to match the existing DIV_ROUND_UP
(probably, not the best idea).

So let me fix them both in a separate patch.

Thanks!

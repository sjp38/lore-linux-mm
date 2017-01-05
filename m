Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABA7C6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 01:22:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so804615354pfy.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 22:22:45 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g31si44264434pld.30.2017.01.04.22.22.44
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 22:22:44 -0800 (PST)
Date: Thu, 5 Jan 2017 15:15:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
Message-ID: <20170105061557.GD24371@bbox>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
 <20161227074503.GA10616@bbox>
 <20170102154841.GG18058@quack2.suse.cz>
 <20170103043411.GA15657@bbox>
 <87inpwu29c.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
In-Reply-To: <87inpwu29c.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Jan Kara <jack@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Nicholas Piggin <npiggin@gmail.com>

Hi Huang,

On Tue, Jan 03, 2017 at 01:43:43PM +0800, Huang, Ying wrote:
> Hi, Minchan,
> 
> Minchan Kim <minchan@kernel.org> writes:
> 
> > Hi Jan,
> >
> > On Mon, Jan 02, 2017 at 04:48:41PM +0100, Jan Kara wrote:
> >> Hi,
> >> 
> >> On Tue 27-12-16 16:45:03, Minchan Kim wrote:
> >> > > Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
> >> > >         the rate that we have to contende for the radix tree.
> >> > 
> >> > To me, it's rather hacky. I think it might be common problem for page cache
> >> > so can we think another generalized way like range_lock? Ccing Jan.
> >> 
> >> I agree on the hackyness of the patch and that page cache would suffer with
> >> the same contention (although the files are usually smaller than swap so it
> >> would not be that visible I guess). But I don't see how range lock would
> >> help here - we need to serialize modifications of the tree structure itself
> >> and that is difficult to achieve with the range lock. So what you would
> >> need is either a different data structure for tracking swap cache entries
> >> or a finer grained locking of the radix tree.
> >
> > Thanks for the comment, Jan.
> >
> > I think there are more general options. One is to shrink batching pages like
> > Mel and Tim had approached.
> >
> > https://patchwork.kernel.org/patch/9008421/
> > https://patchwork.kernel.org/patch/9322793/
> 
> This helps to reduce the lock contention on radix tree of swap cache.
> But splitting swap cache has much better performance.  So we switched
> from that solution to current solution.
> 
> > Or concurrent page cache by peter.
> >
> > https://www.kernel.org/doc/ols/2007/ols2007v2-pages-311-318.pdf
> 
> I think this is good, it helps swap and file cache.  But I don't know
> whether other people want to go this way and how much effort will be
> needed.
> 
> In contrast, splitting swap cache is quite simple, for implementation
> and review.  And the effect is good.

I think general approach is better but I don't want to be a a party pooper
if every people are okay with this. I just wanted to point out we need to
consider more general approach and I did my best.

Decision depends on you guys.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

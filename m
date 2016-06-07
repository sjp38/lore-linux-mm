Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA98B6B025E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 10:18:24 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id j12so76926155lbo.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 07:18:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a138si25448930wmd.114.2016.06.07.07.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 07:18:23 -0700 (PDT)
Date: Tue, 7 Jun 2016 10:18:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/10] mm: allow swappiness that prefers anon over file
Message-ID: <20160607141818.GE9978@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-2-hannes@cmpxchg.org>
 <20160607002550.GA26230@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160607002550.GA26230@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Tue, Jun 07, 2016 at 09:25:50AM +0900, Minchan Kim wrote:
> Hi Johannes,
> 
> Thanks for the nice work. I didn't read all patchset yet but the design
> makes sense to me so it would be better for zram-based on workload
> compared to as is.

Thanks!

> On Mon, Jun 06, 2016 at 03:48:27PM -0400, Johannes Weiner wrote:
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -771,14 +771,20 @@ with no ill effects: errors and warnings on these stats are suppressed.)
> >  
> >  swappiness
> >  
> > -This control is used to define how aggressive the kernel will swap
> > -memory pages.  Higher values will increase agressiveness, lower values
> > -decrease the amount of swap.  A value of 0 instructs the kernel not to
> > -initiate swap until the amount of free and file-backed pages is less
> > -than the high water mark in a zone.
> > +This control is used to define the relative IO cost of cache misses
> > +between the swap device and the filesystem as a value between 0 and
> > +200. At 100, the VM assumes equal IO cost and will thus apply memory
> > +pressure to the page cache and swap-backed pages equally. At 0, the
> > +kernel will not initiate swap until the amount of free and file-backed
> > +pages is less than the high watermark in a zone.
> 
> Generally, I agree extending swappiness value good but not sure 200 is
> enough to represent speed gap between file and swap sotrage in every
> cases. - Just nitpick.

How so? You can't give swap more weight than 100%. 200 is the maximum
possible value.

> Some years ago, I extended it to 200 like your patch and experimented it
> based on zram in our platform workload. At that time, it was terribly
> slow in app switching workload if swappiness is higher than 150.
> Although it was highly dependent on the workload, it's dangerous to
> recommend it before fixing balacing between file and anon, I think.
> IOW, I think this patch should be last one in this patchset.

Good point. I'll tone down the recommendations. But OTOH it's a fairly
trivial patch, so I wouldn't want it to close after the current 10/10.

> >  The default value is 60.
> >  
> > +On non-rotational swap devices, a value of 100 (or higher, depending
> > +on what's backing the filesystem) is recommended.
> > +
> > +For in-memory swap, like zswap, values closer to 200 are recommended.
> 
>                 maybe, like zram
> 
> I'm not sure it would be good suggestion for zswap because it ends up
> writing cached pages to swap device once it reaches threshold.
> Then, the cost is compression + decompression + write I/O which is
> heavier than normal swap device(i.e., write I/O). OTOH, zram have no
> (writeback I/O+ decompression) cost.

Oh, good catch. Yeah, I'll change that for v2.

Thanks for your input, Minchan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

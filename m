Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 176A96B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 20:05:28 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 5so45326527ioy.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 17:05:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g73si17151211pfj.6.2016.06.07.17.05.26
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 17:05:27 -0700 (PDT)
Date: Wed, 8 Jun 2016 09:06:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 01/10] mm: allow swappiness that prefers anon over file
Message-ID: <20160608000632.GA27258@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-2-hannes@cmpxchg.org>
 <20160607002550.GA26230@bbox>
 <20160607141818.GE9978@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160607141818.GE9978@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Tue, Jun 07, 2016 at 10:18:18AM -0400, Johannes Weiner wrote:
> On Tue, Jun 07, 2016 at 09:25:50AM +0900, Minchan Kim wrote:
> > Hi Johannes,
> > 
> > Thanks for the nice work. I didn't read all patchset yet but the design
> > makes sense to me so it would be better for zram-based on workload
> > compared to as is.
> 
> Thanks!
> 
> > On Mon, Jun 06, 2016 at 03:48:27PM -0400, Johannes Weiner wrote:
> > > --- a/Documentation/sysctl/vm.txt
> > > +++ b/Documentation/sysctl/vm.txt
> > > @@ -771,14 +771,20 @@ with no ill effects: errors and warnings on these stats are suppressed.)
> > >  
> > >  swappiness
> > >  
> > > -This control is used to define how aggressive the kernel will swap
> > > -memory pages.  Higher values will increase agressiveness, lower values
> > > -decrease the amount of swap.  A value of 0 instructs the kernel not to
> > > -initiate swap until the amount of free and file-backed pages is less
> > > -than the high water mark in a zone.
> > > +This control is used to define the relative IO cost of cache misses
> > > +between the swap device and the filesystem as a value between 0 and
> > > +200. At 100, the VM assumes equal IO cost and will thus apply memory
> > > +pressure to the page cache and swap-backed pages equally. At 0, the
> > > +kernel will not initiate swap until the amount of free and file-backed
> > > +pages is less than the high watermark in a zone.
> > 
> > Generally, I agree extending swappiness value good but not sure 200 is
> > enough to represent speed gap between file and swap sotrage in every
> > cases. - Just nitpick.
> 
> How so? You can't give swap more weight than 100%. 200 is the maximum
> possible value.

In old, swappiness is how agressively reclaim anonymous pages in favour
of page cache. But when I read your description and changes about
swappiness in vm.txt, esp, *relative IO cost*, I feel you change swappiness
define to represent relative IO cost between swap storage and file storage.
Then, with that, we could balance anonymous and file LRU with the weight.

For example, let's assume that in-memory swap storage is 10x times faster
than slow thumb drive. In that case, IO cost of 5 anonymous pages
swapping-in/out is equal to 1 file-backed page-discard/read.

I thought it does make sense because that measuring the speed gab between
those storages is easier than selecting vague swappiness tendency.

In terms of such approach, I thought 200 is not enough to show the gab
because the gap is started from 100.
Isn't it your intention? If so, to me, the description was rather
misleading. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

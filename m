Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 351B76B0261
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 11:58:25 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id jf8so5480033lbc.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 08:58:25 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x3si2224401wja.80.2016.06.08.08.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 08:58:22 -0700 (PDT)
Date: Wed, 8 Jun 2016 11:58:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/10] mm: allow swappiness that prefers anon over file
Message-ID: <20160608155812.GC6727@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-2-hannes@cmpxchg.org>
 <20160607002550.GA26230@bbox>
 <20160607141818.GE9978@cmpxchg.org>
 <20160608000632.GA27258@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160608000632.GA27258@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Wed, Jun 08, 2016 at 09:06:32AM +0900, Minchan Kim wrote:
> On Tue, Jun 07, 2016 at 10:18:18AM -0400, Johannes Weiner wrote:
> > On Tue, Jun 07, 2016 at 09:25:50AM +0900, Minchan Kim wrote:
> > > On Mon, Jun 06, 2016 at 03:48:27PM -0400, Johannes Weiner wrote:
> > > > --- a/Documentation/sysctl/vm.txt
> > > > +++ b/Documentation/sysctl/vm.txt
> > > > @@ -771,14 +771,20 @@ with no ill effects: errors and warnings on these stats are suppressed.)
> > > >  
> > > >  swappiness
> > > >  
> > > > -This control is used to define how aggressive the kernel will swap
> > > > -memory pages.  Higher values will increase agressiveness, lower values
> > > > -decrease the amount of swap.  A value of 0 instructs the kernel not to
> > > > -initiate swap until the amount of free and file-backed pages is less
> > > > -than the high water mark in a zone.
> > > > +This control is used to define the relative IO cost of cache misses
> > > > +between the swap device and the filesystem as a value between 0 and
> > > > +200. At 100, the VM assumes equal IO cost and will thus apply memory
> > > > +pressure to the page cache and swap-backed pages equally. At 0, the
> > > > +kernel will not initiate swap until the amount of free and file-backed
> > > > +pages is less than the high watermark in a zone.
> > > 
> > > Generally, I agree extending swappiness value good but not sure 200 is
> > > enough to represent speed gap between file and swap sotrage in every
> > > cases. - Just nitpick.
> > 
> > How so? You can't give swap more weight than 100%. 200 is the maximum
> > possible value.
> 
> In old, swappiness is how agressively reclaim anonymous pages in favour
> of page cache. But when I read your description and changes about
> swappiness in vm.txt, esp, *relative IO cost*, I feel you change swappiness
> define to represent relative IO cost between swap storage and file storage.
> Then, with that, we could balance anonymous and file LRU with the weight.
> 
> For example, let's assume that in-memory swap storage is 10x times faster
> than slow thumb drive. In that case, IO cost of 5 anonymous pages
> swapping-in/out is equal to 1 file-backed page-discard/read.
> 
> I thought it does make sense because that measuring the speed gab between
> those storages is easier than selecting vague swappiness tendency.
> 
> In terms of such approach, I thought 200 is not enough to show the gab
> because the gap is started from 100.
> Isn't it your intention? If so, to me, the description was rather
> misleading. :(

The way swappiness works never actually changed.

The only thing that changed is that we used to look at referenced
pages (recent_rotated) and *assumed* they would likely cause IO when
reclaimed, whereas with my patches we actually know whether they are.
But swappiness has always been about relative IO cost of the LRUs.

Swappiness defines relative IO cost between file and swap on a scale
from 0 to 200, where 100 is the point of equality. The scale factors
are calculated in get_scan_count() like this:

  anon_prio = swappiness
  file_prio = 200 - swappiness

and those are applied to the recorded cost/value ratios like this:

  ap = anon_prio * scanned / rotated
  fp = file_prio * scanned / rotated

That means if your swap device is 10 times faster than your filesystem
device, and you thus want anon to receive 10x the refaults when the
anon and file pages are used equally, you do this:

  x + 10x = 200
        x = 18 (ish)

So your file priority is ~18 and your swap priority is the remainder
of the range, 200 - 18. You set swappiness to 182.

Now fill in the numbers while assuming all pages on both lists have
been referenced before and will likely refault (or in the new model,
all pages are refaulting):

  fraction[anon] = ap      = 182 * 1 / 1 = 182
  fraction[file] = fp      =  18 * 1 / 1 =  18
     denominator = ap + fp =    182 + 18 = 200

and then calculate the scan target like this:

  scan[type] = (lru_size() >> priority) * fraction[type] / denominator

This will scan and reclaim 9% of the file pages and 90% of the anon
pages. On refault, 9% of the IO will be from the filesystem and 90%
from the swap device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id EF08C6B00A2
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 11:16:05 -0400 (EDT)
Received: by mail-bk0-f52.google.com with SMTP id my13so421455bkb.11
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 08:16:05 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id nl1si6545636bkb.188.2014.03.17.08.16.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 08:16:01 -0700 (PDT)
Date: Mon, 17 Mar 2014 11:15:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: vmscan: do not swap anon pages just because
 free+file is low
Message-ID: <20140317151553.GG14688@cmpxchg.org>
References: <1394811302-30468-1-git-send-email-hannes@cmpxchg.org>
 <53232901.5030307@redhat.com>
 <20140314170807.GW10663@suse.de>
 <alpine.LSU.2.11.1403152056430.21540@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1403152056430.21540@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rafael Aquini <aquini@redhat.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 15, 2014 at 09:20:16PM -0700, Hugh Dickins wrote:
> On Fri, 14 Mar 2014, Mel Gorman wrote:
> > On Fri, Mar 14, 2014 at 12:06:25PM -0400, Rik van Riel wrote:
> > > On 03/14/2014 11:35 AM, Johannes Weiner wrote:
> > > > Page reclaim force-scans / swaps anonymous pages when file cache drops
> > > > below the high watermark of a zone in order to prevent what little
> > > > cache remains from thrashing.
> > > > 
> > > > However, on bigger machines the high watermark value can be quite
> > > > large and when the workload is dominated by a static anonymous/shmem
> > > > set, the file set might just be a small window of used-once cache.  In
> > > > such situations, the VM starts swapping heavily when instead it should
> > > > be recycling the no longer used cache.
> > > > 
> > > > This is a longer-standing problem, but it's more likely to trigger
> > > > after 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
> > > > because file pages can no longer accumulate in a single zone and are
> > > > dispersed into smaller fractions among the available zones.
> > > > 
> > > > To resolve this, do not force scan anon when file pages are low but
> > > > instead rely on the scan/rotation ratios to make the right prediction.
> > > 
> > > I am not entirely sure that the scan/rotation ratio will be
> > > meaningful when the page cache has been essentially depleted,
> > > but on larger systems the distance between the low and high
> > > watermark is gigantic, and I have no better idea on how to
> > > fix the bug you encountered, so ...
> > > 
> > 
> > I still agree with the direction in general even though I've not put
> > thought into this specific patch yet. We've observed a problem whereby force
> > reclaim was causing one or other LRU list to be trashed.  In one specific
> > case, the inactive file is low logic was causing problems because while
> > the relative size of inactive/active was taken into account, the absolute
> > size vs anon was not. It was not a mainline kernel and we do not have a
> > test configuration that properly illustrates the problem on mainline it's
> > on our radar that it's a potential problem. The scan/rotation ratio at the
> > moment does not take absolute sizes into account but we almost certainly
> > want to go in that direction at some stage. Hugh's patch on altering how
> > proportional shrinking works is also relevant.
> 
> That https://lkml.org/lkml/2014/3/13/217
> is relevant, yes, but I think rather more so is
> Suleiman's in https://lkml.org/lkml/2014/3/15/168
> 
> Hannes, your patch looks reasonable to me, and as I read it would
> be well complemented by Suleiman's and mine; but I do worry that
> the "scan_balance = SCAN_ANON" block you're removing was inserted
> for good reason, and its removal bring complaint from some direction.

It's been introduced with the original LRU split patch but there is no
explanation why.  Rik's concern now was that the scan/rotate numbers
might not be too meaningful with very little cache.

> By the way, I notice you marked yours for stable [3.12+]:
> if it's for stable at all, shouldn't it be for 3.9+?
> (well, maybe nobody's doing a 3.9.N.M but 3.10.N is still alive).

The code I'm removing is fairly old and it's only been reported to
create problems starting with the fair zone allocator in 3.12.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

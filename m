Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7E11A6B0038
	for <linux-mm@kvack.org>; Sun, 16 Mar 2014 00:21:11 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so4319942pab.12
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 21:21:11 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id vu10si10328690pbc.249.2014.03.15.21.21.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 21:21:10 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so4190308pdj.23
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 21:21:10 -0700 (PDT)
Date: Sat, 15 Mar 2014 21:20:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm: vmscan: do not swap anon pages just because free+file
 is low
In-Reply-To: <20140314170807.GW10663@suse.de>
Message-ID: <alpine.LSU.2.11.1403152056430.21540@eggly.anvils>
References: <1394811302-30468-1-git-send-email-hannes@cmpxchg.org> <53232901.5030307@redhat.com> <20140314170807.GW10663@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rafael Aquini <aquini@redhat.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 14 Mar 2014, Mel Gorman wrote:
> On Fri, Mar 14, 2014 at 12:06:25PM -0400, Rik van Riel wrote:
> > On 03/14/2014 11:35 AM, Johannes Weiner wrote:
> > > Page reclaim force-scans / swaps anonymous pages when file cache drops
> > > below the high watermark of a zone in order to prevent what little
> > > cache remains from thrashing.
> > > 
> > > However, on bigger machines the high watermark value can be quite
> > > large and when the workload is dominated by a static anonymous/shmem
> > > set, the file set might just be a small window of used-once cache.  In
> > > such situations, the VM starts swapping heavily when instead it should
> > > be recycling the no longer used cache.
> > > 
> > > This is a longer-standing problem, but it's more likely to trigger
> > > after 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
> > > because file pages can no longer accumulate in a single zone and are
> > > dispersed into smaller fractions among the available zones.
> > > 
> > > To resolve this, do not force scan anon when file pages are low but
> > > instead rely on the scan/rotation ratios to make the right prediction.
> > 
> > I am not entirely sure that the scan/rotation ratio will be
> > meaningful when the page cache has been essentially depleted,
> > but on larger systems the distance between the low and high
> > watermark is gigantic, and I have no better idea on how to
> > fix the bug you encountered, so ...
> > 
> 
> I still agree with the direction in general even though I've not put
> thought into this specific patch yet. We've observed a problem whereby force
> reclaim was causing one or other LRU list to be trashed.  In one specific
> case, the inactive file is low logic was causing problems because while
> the relative size of inactive/active was taken into account, the absolute
> size vs anon was not. It was not a mainline kernel and we do not have a
> test configuration that properly illustrates the problem on mainline it's
> on our radar that it's a potential problem. The scan/rotation ratio at the
> moment does not take absolute sizes into account but we almost certainly
> want to go in that direction at some stage. Hugh's patch on altering how
> proportional shrinking works is also relevant.

That https://lkml.org/lkml/2014/3/13/217
is relevant, yes, but I think rather more so is
Suleiman's in https://lkml.org/lkml/2014/3/15/168

Hannes, your patch looks reasonable to me, and as I read it would
be well complemented by Suleiman's and mine; but I do worry that
the "scan_balance = SCAN_ANON" block you're removing was inserted
for good reason, and its removal bring complaint from some direction.

By the way, I notice you marked yours for stable [3.12+]:
if it's for stable at all, shouldn't it be for 3.9+?
(well, maybe nobody's doing a 3.9.N.M but 3.10.N is still alive).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

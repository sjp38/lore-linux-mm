Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 802516B003B
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 13:08:13 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so5682498wiw.12
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 10:08:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si4654984wix.53.2014.03.14.10.08.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 10:08:12 -0700 (PDT)
Date: Fri, 14 Mar 2014 17:08:08 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm: vmscan: do not swap anon pages just because
 free+file is low
Message-ID: <20140314170807.GW10663@suse.de>
References: <1394811302-30468-1-git-send-email-hannes@cmpxchg.org>
 <53232901.5030307@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53232901.5030307@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz

On Fri, Mar 14, 2014 at 12:06:25PM -0400, Rik van Riel wrote:
> On 03/14/2014 11:35 AM, Johannes Weiner wrote:
> > Page reclaim force-scans / swaps anonymous pages when file cache drops
> > below the high watermark of a zone in order to prevent what little
> > cache remains from thrashing.
> > 
> > However, on bigger machines the high watermark value can be quite
> > large and when the workload is dominated by a static anonymous/shmem
> > set, the file set might just be a small window of used-once cache.  In
> > such situations, the VM starts swapping heavily when instead it should
> > be recycling the no longer used cache.
> > 
> > This is a longer-standing problem, but it's more likely to trigger
> > after 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
> > because file pages can no longer accumulate in a single zone and are
> > dispersed into smaller fractions among the available zones.
> > 
> > To resolve this, do not force scan anon when file pages are low but
> > instead rely on the scan/rotation ratios to make the right prediction.
> 
> I am not entirely sure that the scan/rotation ratio will be
> meaningful when the page cache has been essentially depleted,
> but on larger systems the distance between the low and high
> watermark is gigantic, and I have no better idea on how to
> fix the bug you encountered, so ...
> 

I still agree with the direction in general even though I've not put
thought into this specific patch yet. We've observed a problem whereby force
reclaim was causing one or other LRU list to be trashed.  In one specific
case, the inactive file is low logic was causing problems because while
the relative size of inactive/active was taken into account, the absolute
size vs anon was not. It was not a mainline kernel and we do not have a
test configuration that properly illustrates the problem on mainline it's
on our radar that it's a potential problem. The scan/rotation ratio at the
moment does not take absolute sizes into account but we almost certainly
want to go in that direction at some stage. Hugh's patch on altering how
proportional shrinking works is also relevant.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

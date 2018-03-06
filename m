Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B73576B0006
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 18:57:15 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y83so788386ita.5
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 15:57:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g124sor5418822ith.52.2018.03.06.15.57.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 15:57:14 -0800 (PST)
Date: Tue, 6 Mar 2018 15:57:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: drain pcps for zone when kcompactd
 fails
In-Reply-To: <alpine.DEB.2.20.1803011535280.173043@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803061549590.258123@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com> <20180301152737.62b78dcb129339a3261a9820@linux-foundation.org> <alpine.DEB.2.20.1803011535280.173043@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 Mar 2018, David Rientjes wrote:

> On Thu, 1 Mar 2018, Andrew Morton wrote:
> 
> > On Thu, 1 Mar 2018 03:42:04 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> > 
> > > It's possible for buddy pages to become stranded on pcps that, if drained,
> > > could be merged with other buddy pages on the zone's free area to form
> > > large order pages, including up to MAX_ORDER.
> > 
> > I grabbed this as-is.  Perhaps you could send along a new changelog so
> > that others won't be asking the same questions as Vlastimil?
> > 
> > The patch has no reviews or acks at this time...
> > 
> 
> Thanks.
> 
> As mentioned in my response to Vlastimil, I think the case could also be 
> made that we should do drain_all_pages(zone) in try_to_compact_pages() 
> when we defer for direct compactors.  It would be great to have feedback 
> from those on the cc on that point, the patch in general, and then I can 
> send an update.
> 

Andrew, here's a new changelog that should clarify the questions asked 
about the patch.


It's possible for free pages to become stranded on per-cpu pagesets (pcps) 
that, if drained, could be merged with buddy pages on the zone's free area 
to form large order pages, including up to MAX_ORDER.

Consider a verbose example using the tools/vm/page-types tool at the
beginning of a ZONE_NORMAL ('B' indicates a buddy page and 'S' indicates a
slab page).  Pages on pcps do not have any page flags set.

109954  1       _______S________________________________________________________
109955  2       __________B_____________________________________________________
109957  1       ________________________________________________________________
109958  1       __________B_____________________________________________________
109959  7       ________________________________________________________________
109960  1       __________B_____________________________________________________
109961  9       ________________________________________________________________
10996a  1       __________B_____________________________________________________
10996b  3       ________________________________________________________________
10996e  1       __________B_____________________________________________________
10996f  1       ________________________________________________________________
...
109f8c  1       __________B_____________________________________________________
109f8d  2       ________________________________________________________________
109f8f  2       __________B_____________________________________________________
109f91  f       ________________________________________________________________
109fa0  1       __________B_____________________________________________________
109fa1  7       ________________________________________________________________
109fa8  1       __________B_____________________________________________________
109fa9  1       ________________________________________________________________
109faa  1       __________B_____________________________________________________
109fab  1       _______S________________________________________________________

The compaction migration scanner is attempting to defragment this memory 
since it is at the beginning of the zone.  It has done so quite well, all 
movable pages have been migrated.  From pfn [0x109955, 0x109fab), there
are only buddy pages and pages without flags set.

These pages may be stranded on pcps that could otherwise allow this memory 
to be coalesced if freed back to the zone free area.  It is possible that 
some of these pages may not be on pcps and that something has called 
alloc_pages() and used the memory directly, but we rely on the absence of
__GFP_MOVABLE in these cases to allocate from MIGATE_UNMOVABLE pageblocks 
to try to keep these MIGRATE_MOVABLE pageblocks as free as possible.

These buddy and pcp pages, spanning 1,621 pages, could be coalesced and 
allow for three transparent hugepages to be dynamically allocated.  
Running the numbers for all such spans on the system, it was found that 
there were over 400 such spans of only buddy pages and pages without flags 
set at the time this /proc/kpageflags sample was collected.  Without this 
support, there were _no_ order-9 or order-10 pages free.

When kcompactd fails to defragment memory such that a cc.order page can
be allocated, drain all pcps for the zone back to the buddy allocator so
this stranding cannot occur.  Compaction for that order will subsequently
be deferred, which acts as a ratelimit on this drain.

Signed-off-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

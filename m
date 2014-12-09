Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 205E86B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 03:24:34 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so111371pab.19
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 00:24:33 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fk4si556855pbb.236.2014.12.09.00.24.31
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 00:24:32 -0800 (PST)
Date: Tue, 9 Dec 2014 17:28:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] mm: more aggressive page stealing for UNMOVABLE
 allocations
Message-ID: <20141209082821.GB7714@js1304-P5Q-DELUXE>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
 <1417713178-10256-3-git-send-email-vbabka@suse.cz>
 <20141208071140.GB3904@js1304-P5Q-DELUXE>
 <54857D0F.3080601@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54857D0F.3080601@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Mon, Dec 08, 2014 at 11:27:27AM +0100, Vlastimil Babka wrote:
> On 12/08/2014 08:11 AM, Joonsoo Kim wrote:
> >On Thu, Dec 04, 2014 at 06:12:57PM +0100, Vlastimil Babka wrote:
> >>When allocation falls back to stealing free pages of another migratetype,
> >>it can decide to steal extra pages, or even the whole pageblock in order to
> >>reduce fragmentation, which could happen if further allocation fallbacks
> >>pick a different pageblock. In try_to_steal_freepages(), one of the situations
> >>where extra pages are stolen happens when we are trying to allocate a
> >>MIGRATE_RECLAIMABLE page.
> >>
> >>However, MIGRATE_UNMOVABLE allocations are not treated the same way, although
> >>spreading such allocation over multiple fallback pageblocks is arguably even
> >>worse than it is for RECLAIMABLE allocations. To minimize fragmentation, we
> >>should minimize the number of such fallbacks, and thus steal as much as is
> >>possible from each fallback pageblock.
> >
> >I'm not sure that this change is good. If we steal order 0 pages,
> >this may be good. But, sometimes, we try to steal high order page
> >and, in this case, there would be many order 0 freepages and blindly
> >stealing freepages in that pageblock make the system more fragmented.
> 
> I don't understand. If we try to steal high order page
> (current_order >= pageblock_order / 2), then nothing changes, the
> condition for extra stealing is the same.

More accureately, I means mid order page (current_order <
pageblock_order / 2), but, not order 0, such as order 2,3,4(?).
In this case, perhaps, the system has enough unmovable order 0 freepages,
so we don't need to worry about second kind of fragmentation you
mentioned below. Stealing one mid order freepage is enough to satify
request.

> 
> >MIGRATE_RECLAIMABLE is different case than MIGRATE_UNMOVABLE, because
> >it can be reclaimed so excessive migratetype movement doesn't result
> >in permanent fragmentation.
> 
> There's two kinds of "fragmentation" IMHO. First, inside a
> pageblock, unmovable allocations can prevent merging of lower
> orders. This can get worse if we steal multiple pages from a single
> pageblock, but the pageblock itself is not marked as unmovable.

So, what's the intention pageblock itself not marked as unmovable?
I guess that if many pages are moved to unmovable, they can't be easily
back and this pageblock is highly fragmented. So, processing more unmovable
requests from this pageblock by changing pageblock migratetype makes more
sense to me.

> Second kind of fragmentation is when unmovable allocations spread
> over multiple pageblocks. Lower order allocations within each such
> pageblock might be still possible, but less pageblocks are able to
> compact to have whole pageblock free.
> 
> I think the second kind is worse, so when do have to pollute a
> movable pageblock with unmovable allocation, we better take as much
> as possible, so we prevent polluting other pageblocks.

I agree.

> 
> >What I'd like to do to prevent fragmentation is
> >1) check whether we can steal all or almost freepages and change
> >migratetype of pageblock.
> >2) If above condition isn't met, deny allocation and invoke compaction.
> 
> Could work to some extend, but we need also to prevent excessive compaction.

So, I suggest knob to control behaviour. In small memory system,
fragmentation occurs frequently so the system can't handle just order 2
request. In that system, excessive compaction is acceptable because
it it better than system down.

> 
> We could also introduce a new pageblock migratetype, something like
> MIGRATE_MIXED. The idea is that once pageblock isn't used purely by
> MOVABLE allocations, it's marked as MIXED, until it either becomes
> marked UNMOVABLE or RECLAIMABLE by the existing mechanisms, or is
> fully freed. In more detail:
> 
> - MIXED is preferred for fallback before any other migratetypes
> - if RECLAIMABLE/UNMOVABLE page allocation is stealing from MOVABLE
> pageblock and cannot mark pageblock as RECLAIMABLE/UNMOVABLE (by
> current rules), it marks it as MIXED instead.
> - if MOVABLE allocation is stealing from UNMOVABLE/RECLAIMABLE
> pageblocks, it will only mark it as MOVABLE if it was fully free.
> Otherwise, if current rules would result in marking it as MOVABLE
> (i.e. most of it was stolen, but not all) it will mark it as MIXED
> instead.
> 
> This could in theory leave more MOVABLE pageblocks unspoiled by
> UNMOVABLE allocations.

I guess that we can do it without introducing new migratetype pageblock.
Just always marking it as RECLAIMABLE/UNMOVABLE when
RECLAIMABLE/UNMOVABLE page allocation is stealing from MOVABLE would
have same effect.

Thanks.

> >Maybe knob to control behaviour would be needed.
> >How about it?
> 
> Adding new knobs is not a good solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

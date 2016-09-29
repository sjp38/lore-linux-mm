Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2016B0269
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 22:25:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so58436514wmg.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:25:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f1si12804505wmi.89.2016.09.28.19.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 19:25:48 -0700 (PDT)
Date: Wed, 28 Sep 2016 22:25:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Regression in mobility grouping?
Message-ID: <20160929022540.GA30883@cmpxchg.org>
References: <20160928014148.GA21007@cmpxchg.org>
 <8c3b7dd8-ef6f-6666-2f60-8168d41202cf@suse.cz>
 <20160928153925.GA24966@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928153925.GA24966@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 28, 2016 at 11:39:25AM -0400, Johannes Weiner wrote:
> On Wed, Sep 28, 2016 at 11:00:15AM +0200, Vlastimil Babka wrote:
> > I guess testing revert of 9c0415e could give us some idea. Commit
> > 3a1086f shouldn't result in pageblock marking differences and as I said
> > above, 99592d5 should be just restoring to what 3.10 did.
> 
> I can give this a shot, but note that this commit makes only unmovable
> stealing more aggressive. We see reclaimable blocks up as well.

Quick update, I reverted back to stealing eagerly only on behalf of
MIGRATE_RECLAIMABLE allocations in a 4.6 kernel:

static bool can_steal_fallback(unsigned int order, int start_mt)
{
        if (order >= pageblock_order / 2 ||
            start_mt == MIGRATE_RECLAIMABLE ||
            page_group_by_mobility_disabled)
                return true;

        return false;
}

Yet, I still see UNMOVABLE growing to the thousands within minutes,
whereas 3.10 didn't reach those numbers even after days of uptime.

Okay, that wasn't it. However, there is something fishy going on,
because I see extfrag traces like these:

<idle>-0     [006] d.s.  1110.217281: mm_page_alloc_extfrag: page=ffffea0064142000 pfn=26235008 alloc_order=3 fallback_order=3 pageblock_order=9 alloc_migratetype=0 fallback_migratetype=2 fragmenting=1 change_ownership=1

enum {
        MIGRATE_UNMOVABLE,
        MIGRATE_MOVABLE,
        MIGRATE_RECLAIMABLE,
        MIGRATE_PCPTYPES,       /* the number of types on the pcp lists */
        MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
	...
};

This is an UNMOVABLE order-3 allocation falling back to RECLAIMABLE.
According to can_steal_fallback(), this allocation shouldn't steal the
pageblock, yet change_ownership=1 indicates the block is UNMOVABLE.

Who converted it? I wonder if there is a bug in ownership management,
and there was an UNMOVABLE block on the RECLAIMABLE freelist from the
beginning. AFAICS we never validate list/mt consistency anywhere.

I'll continue looking tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

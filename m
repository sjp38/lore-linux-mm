Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA498299E
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:12:57 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2976980eei.28
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:12:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b49si9972180eez.263.2014.05.06.08.12.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:12:56 -0700 (PDT)
Date: Tue, 6 May 2014 16:12:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/17] mm: page_alloc: Use word-based accesses for
 get/set pageblock bitmaps
Message-ID: <20140506151252.GZ23991@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-9-git-send-email-mgorman@suse.de>
 <53641D8C.6040601@oracle.com>
 <20140504131454.GS23991@suse.de>
 <536786C6.8040805@suse.cz>
 <20140506091336.GX23991@suse.de>
 <5368F4CA.7060002@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5368F4CA.7060002@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, May 06, 2014 at 04:42:18PM +0200, Vlastimil Babka wrote:
> >>>+unsigned long get_pageblock_flags_mask(struct page *page,
> >>>+					unsigned long end_bitidx,
> >>>+					unsigned long nr_flag_bits,
> >>>+					unsigned long mask)
> >>>  {
> >>>  	struct zone *zone;
> >>>  	unsigned long *bitmap;
> >>>-	unsigned long pfn, bitidx;
> >>>-	unsigned long flags = 0;
> >>>-	unsigned long value = 1;
> >>>+	unsigned long pfn, bitidx, word_bitidx;
> >>>+	unsigned long word;
> >>>
> >>>  	zone = page_zone(page);
> >>>  	pfn = page_to_pfn(page);
> >>>  	bitmap = get_pageblock_bitmap(zone, pfn);
> >>>  	bitidx = pfn_to_bitidx(zone, pfn);
> >>>+	word_bitidx = bitidx / BITS_PER_LONG;
> >>>+	bitidx &= (BITS_PER_LONG-1);
> >>>
> >>>-	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
> >>>-		if (test_bit(bitidx + start_bitidx, bitmap))
> >>>-			flags |= value;
> >>>-
> >>>-	return flags;
> >>>+	word = bitmap[word_bitidx];
> >>
> >>I wonder if on some architecture this may result in inconsistent
> >>word when racing with set(), i.e. cmpxchg? We need consistency at
> >>least on the granularity of byte to prevent the problem with bogus
> >>migratetype values being read.
> >>fix:
> >
> >The number of bits align on the byte boundary so I do not think there is
> >a problem there. There is a BUILD_BUG_ON check in set_pageblock_flags_mask
> >in case this changes so it can be revisited if necessary.
> 
> I was wondering about hardware guarantees in that case (e.g.
> consistency at least on the granularity of byte when a simple memory
> read races with write) but after some discussion in the office I
> understand that hardware without such guarantees wouldn't be able to
> run Linux anyway :)
> 
> Still I wonder if ACCESS_ONCE would be safer in the 'word' variable
> assignment to protect against compiler trying to be too smart?
> 

I couldn't see a case in the get path where it would matter. I put an
ACCESS_ONCE in the set path in case the compiler accidentally determined
that old_word was invariant in that loop.

> Anyway with the nr_flag_bits removed:
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA486B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 18:24:13 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so163098eek.13
        for <linux-mm@kvack.org>; Tue, 06 May 2014 15:24:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si14500608eeo.244.2014.05.06.15.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 15:24:12 -0700 (PDT)
Date: Tue, 6 May 2014 23:24:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/17] mm: page_alloc: Use word-based accesses for
 get/set pageblock bitmaps
Message-ID: <20140506222408.GC23991@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-9-git-send-email-mgorman@suse.de>
 <20140506203449.GG1429@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140506203449.GG1429@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, May 06, 2014 at 10:34:49PM +0200, Peter Zijlstra wrote:
> On Thu, May 01, 2014 at 09:44:39AM +0100, Mel Gorman wrote:
> > +void set_pfnblock_flags_group(struct page *page, unsigned long flags,
> > +					unsigned long end_bitidx,
> > +					unsigned long nr_flag_bits,
> > +					unsigned long mask)
> >  {
> >  	struct zone *zone;
> >  	unsigned long *bitmap;
> > +	unsigned long pfn, bitidx, word_bitidx;
> > +	unsigned long old_word, new_word;
> > +
> > +	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
> >  
> >  	zone = page_zone(page);
> >  	pfn = page_to_pfn(page);
> >  	bitmap = get_pageblock_bitmap(zone, pfn);
> >  	bitidx = pfn_to_bitidx(zone, pfn);
> > +	word_bitidx = bitidx / BITS_PER_LONG;
> > +	bitidx &= (BITS_PER_LONG-1);
> > +
> >  	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
> >  
> > +	bitidx += end_bitidx;
> > +	mask <<= (BITS_PER_LONG - bitidx - 1);
> > +	flags <<= (BITS_PER_LONG - bitidx - 1);
> > +
> > +	do {
> > +		old_word = ACCESS_ONCE(bitmap[word_bitidx]);
> > +		new_word = (old_word & ~mask) | flags;
> > +	} while (cmpxchg(&bitmap[word_bitidx], old_word, new_word) != old_word);
> >  }
> 
> You could write it like:
> 
> 	word = ACCESS_ONCE(bitmap[word_bitidx]);
> 	for (;;) {
> 		old_word = cmpxchg(&bitmap[word_bitidx], word, (word & ~mask) | flags);
> 		if (word == old_word);
> 			break;
> 		word = old_word;
> 	}
> 
> It has a slightly tighter loop by avoiding the read being included.

Thanks, I'll use that.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

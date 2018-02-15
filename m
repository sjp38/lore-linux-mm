Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68D1D6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:55:26 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 5so860916wrt.12
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 06:55:26 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id v13si1038067edi.511.2018.02.15.06.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 06:55:24 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 8D6711C5974
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 14:55:24 +0000 (GMT)
Date: Thu, 15 Feb 2018 14:55:23 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 1/2] free_pcppages_bulk: do not hold lock when picking
 pages to free
Message-ID: <20180215145523.btoutbrskdvizkqk@techsingularity.net>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124163926.c7ptagn655aeiut3@techsingularity.net>
 <20180125072144.GA27678@intel.com>
 <20180215124644.GA12360@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180215124644.GA12360@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Feb 15, 2018 at 04:46:44AM -0800, Matthew Wilcox wrote:
> On Thu, Jan 25, 2018 at 03:21:44PM +0800, Aaron Lu wrote:
> > When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
> > the zone->lock is held and then pages are chosen from PCP's migratetype
> > list. While there is actually no need to do this 'choose part' under
> > lock since it's PCP pages, the only CPU that can touch them is us and
> > irq is also disabled.
> 
> I have no objection to this patch.  If you're looking for ideas for
> future improvement though, I wonder whether using a LIST_HEAD is the
> best way to store these pages temporarily.  If you batch them into a
> pagevec and then free the entire pagevec, the CPU should be a little
> faster scanning a short array than walking a linked list.
> 
> It would also puts a hard boundary on how long zone->lock is held, as
> you'd drop it and go back for another batch after 15 pages.  That might
> be bad, of course.
> 

It's not a guaranteed win. You're trading a list traversal for increased
stack usage of 128 bytes (unless you stick a static one in the pgdat and
incur a cache miss penalty instead or a per-cpu pagevec and increase memory
consumption) and 2 spin lock acquire/releases in the common case which may
or may not be contended. It might make more sense if the PCP's themselves
where statically sized but that would limit tuning options and increase
the per-cpu footprint of the pcp structures.

Maybe I'm missing something obvious and it really would be a universal
win but right now I find it hard to imagine that it's a win.

> Another minor change I'd like to see is free_pcpages_bulk updating

> pcp->count itself; all of the callers do it currently.
> 

That should be reasonable, it's not even particularly difficult.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

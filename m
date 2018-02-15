Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 572FC6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:46:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 189so3870370pge.0
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 04:46:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c10si1100643pfm.263.2018.02.15.04.46.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Feb 2018 04:46:49 -0800 (PST)
Date: Thu, 15 Feb 2018 04:46:44 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/2] free_pcppages_bulk: do not hold lock when picking
 pages to free
Message-ID: <20180215124644.GA12360@bombadil.infradead.org>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124163926.c7ptagn655aeiut3@techsingularity.net>
 <20180125072144.GA27678@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180125072144.GA27678@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jan 25, 2018 at 03:21:44PM +0800, Aaron Lu wrote:
> When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
> the zone->lock is held and then pages are chosen from PCP's migratetype
> list. While there is actually no need to do this 'choose part' under
> lock since it's PCP pages, the only CPU that can touch them is us and
> irq is also disabled.

I have no objection to this patch.  If you're looking for ideas for
future improvement though, I wonder whether using a LIST_HEAD is the
best way to store these pages temporarily.  If you batch them into a
pagevec and then free the entire pagevec, the CPU should be a little
faster scanning a short array than walking a linked list.

It would also puts a hard boundary on how long zone->lock is held, as
you'd drop it and go back for another batch after 15 pages.  That might
be bad, of course.

Another minor change I'd like to see is free_pcpages_bulk updating
pcp->count itself; all of the callers do it currently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

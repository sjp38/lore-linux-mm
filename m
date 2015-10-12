Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1F78A6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 06:05:17 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so43905911wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:05:16 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id cl14si18623287wjb.118.2015.10.12.03.05.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 03:05:15 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so43905438wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:05:15 -0700 (PDT)
Date: Mon, 12 Oct 2015 13:05:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] mm: fix a BUG, the page is allocated 2 times
Message-ID: <20151012100514.GA2544@node>
References: <1444617606-8685-1-git-send-email-yalin.wang2010@gmail.com>
 <561B6379.2070407@suse.cz>
 <4D925B19-2187-4892-A99A-E59D575C2147@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4D925B19-2187-4892-A99A-E59D575C2147@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, mhocko@suse.com, David Rientjes <rientjes@google.com>, js1304@gmail.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 12, 2015 at 03:58:51PM +0800, yalin wang wrote:
> 
> > On Oct 12, 2015, at 15:38, Vlastimil Babka <vbabka@suse.cz> wrote:
> > 
> > On 10/12/2015 04:40 AM, yalin wang wrote:
> >> Remove unlikely(order), because we are sure order is not zero if
> >> code reach here, also add if (page == NULL), only allocate page again if
> >> __rmqueue_smallest() failed or alloc_flags & ALLOC_HARDER == 0
> > 
> > The second mentioned change is actually more important as it removes a memory leak! Thanks for catching this. The problem is in patch mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch and seems to have been due to a change in the last submitted version to make sure the tracepoint is called.
> > 
> >> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> >> ---
> >>  mm/page_alloc.c | 6 +++---
> >>  1 file changed, 3 insertions(+), 3 deletions(-)
> >> 
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index 0d6f540..de82e2c 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -2241,13 +2241,13 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
> >>  		spin_lock_irqsave(&zone->lock, flags);
> >> 
> >>  		page = NULL;
> >> -		if (unlikely(order) && (alloc_flags & ALLOC_HARDER)) {
> >> +		if (alloc_flags & ALLOC_HARDER) {
> >>  			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> >>  			if (page)
> >>  				trace_mm_page_alloc_zone_locked(page, order, migratetype);
> >>  		}
> >> -
> >> -		page = __rmqueue(zone, order, migratetype, gfp_flags);
> >> +		if (page == NULL)
> > 
> > "if (!page)" is more common and already used below.
> > We could skip the check for !page in case we don't go through the ALLOC_HARDER branch, but I guess it's not worth the goto, and hopefully the compiler is smart enough anywaya?|
> agree with your comments,
> do i need send a new patch for this ?

Looks like a two patches to me: memory leak and removing always-true part
of condifition.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

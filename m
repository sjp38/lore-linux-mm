Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5520F6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 05:08:25 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xb4so6851179pbc.8
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 02:08:25 -0800 (PST)
Received: from psmtp.com ([74.125.245.153])
        by mx.google.com with SMTP id ra5si7151042pbc.314.2013.11.04.02.08.23
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 02:08:24 -0800 (PST)
Date: Mon, 4 Nov 2013 10:08:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Do not walk all of system memory during show_mem
Message-ID: <20131104100818.GB2400@suse.de>
References: <20131016104228.GM11028@suse.de>
 <alpine.DEB.2.02.1310161809470.12062@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1310161809470.12062@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 16, 2013 at 06:11:56PM -0700, David Rientjes wrote:
> On Wed, 16 Oct 2013, Mel Gorman wrote:
> 
> > It has been reported on very large machines that show_mem is taking almost
> > 5 minutes to display information. This is a serious problem if there is
> > an OOM storm. The bulk of the cost is in show_mem doing a very expensive
> > PFN walk to give us the following information
> > 
> > Total RAM:	Also available as totalram_pages
> > Highmem pages:	Also available as totalhigh_pages
> > Reserved pages:	Can be inferred from the zone structure
> > Shared pages:	PFN walk required
> > Unshared pages:	PFN walk required
> > Quick pages:	Per-cpu walk required
> > 
> > Only the shared/unshared pages requires a full PFN walk but that information
> > is useless. It is also inaccurate as page pins of unshared pages would
> > be accounted for as shared.  Even if the information was accurate, I'm
> > struggling to think how the shared/unshared information could be useful
> > for debugging OOM conditions. Maybe it was useful before rmap existed when
> > reclaiming shared pages was costly but it is less relevant today.
> > 
> > The PFN walk could be optimised a bit but why bother as the information is
> > useless. This patch deletes the PFN walker and infers the total RAM, highmem
> > and reserved pages count from struct zone. It omits the shared/unshared page
> > usage on the grounds that it is useless.  It also corrects the reporting
> > of HighMem as HighMem/MovableOnly as ZONE_MOVABLE has similar problems to
> > HighMem with respect to lowmem/highmem exhaustion.
> > 
> 
> We haven't been hit by this for the oom killer, but we did get hit with 
> this for page allocation failure warnings as a result of having irqs 
> disabled and passing GFP_ATOMIC to the page allocator without GFP_NOWARN.  
> That was the intention of passing SHOW_MEM_FILTER_PAGE_COUNT into 
> show_mem() in 4b59e6c47309 ("mm, show_mem: suppress page counts in 
> non-blockable contexts").
> 
> With this, I assume we can just remove SHOW_MEM_FILTER_PAGE_COUNT 
> entirely?

We could once all the per-arch show_mem functions were updated similar
to lib/show_mem.c. I've added a todo item to do just that. Thanks.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

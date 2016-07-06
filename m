Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 118D6828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 21:37:47 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fq2so460502273obb.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 18:37:47 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b75si4150386ioe.115.2016.07.05.18.37.45
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 18:37:46 -0700 (PDT)
Date: Wed, 6 Jul 2016 10:41:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when
 terminating freeing scanner
Message-ID: <20160706014109.GC23627@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
 <7ecb4f2d-724f-463f-961f-efba1bdb63d2@suse.cz>
 <alpine.DEB.2.10.1607051357050.110721@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607051357050.110721@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, minchan@kernel.org, stable@vger.kernel.org

On Tue, Jul 05, 2016 at 02:01:29PM -0700, David Rientjes wrote:
> On Thu, 30 Jun 2016, Vlastimil Babka wrote:
> 
> > >  Note: I really dislike the low watermark check in split_free_page() and
> > >  consider it poor software engineering.  The function should split a free
> > >  page, nothing more.  Terminating memory compaction because of a low
> > >  watermark check when we're simply trying to migrate memory seems like an
> > >  arbitrary heuristic.  There was an objection to removing it in the first
> > >  proposed patch, but I think we should really consider removing that
> > >  check so this is simpler.
> > 
> > There's a patch changing it to min watermark (you were CC'd on the series). We
> > could argue whether it belongs to split_free_page() or some wrapper of it, but
> > I don't think removing it completely should be done. If zone is struggling
> > with order-0 pages, a functionality for making higher-order pages shouldn't
> > make it even worse. It's also not that arbitrary, even if we succeeded the
> > migration and created a high-order page, the higher-order allocation would
> > still fail due to watermark checks. Worse, __compact_finished() would keep
> > telling the compaction to continue, creating an even longer lag, which is also
> > against your recent patches.
> > 
> 
> I'm suggesting we shouldn't check any zone watermark in split_free_page(): 
> that function should just split the free page.
> 
> I don't find our current watermark checks to determine if compaction is 
> worthwhile to be invalid, but I do think that we should avoid checking or 
> acting on any watermark in isolate_freepages() itself.  We could do more 
> effective checking in __compact_finished() to determine if we should 
> terminate compaction, but the freeing scanner feels like the wrong place 
> to do it -- it's also expensive to check while gathering free pages for 
> memory that we have already successfully isolated as part of the 
> iteration.
> 
> Do you have any objection to this fix for 4.7?
> 
> Joonson and/or Minchan, does this address the issue that you reported?

Unfortunately, I have no test case to trigger it. But, I think that
this patch will address it. Anyway, I commented one problem on this
patch in other e-mail so please fix it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

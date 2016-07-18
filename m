Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEFC66B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:40:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so353588855pfb.0
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 22:40:47 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id gx2si14055618pac.52.2016.07.17.22.40.46
        for <linux-mm@kvack.org>;
        Sun, 17 Jul 2016 22:40:46 -0700 (PDT)
Date: Mon, 18 Jul 2016 14:44:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm, compaction: make sure freeing scanner isn't
 persistently expensive
Message-ID: <20160718054452.GE9460@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.10.1606281839050.101842@chino.kir.corp.google.com>
 <6685fe19-753d-7d76-aced-3bb071d7c81d@suse.cz>
 <alpine.DEB.2.10.1606291349320.145590@chino.kir.corp.google.com>
 <20160630073158.GA30114@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1607111556580.107663@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607111556580.107663@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 11, 2016 at 04:01:52PM -0700, David Rientjes wrote:
> On Thu, 30 Jun 2016, Joonsoo Kim wrote:
> 
> > We need to find a root cause of this problem, first.
> > 
> > I guess that this problem would happen when isolate_freepages_block()
> > early stop due to watermark check (if your patch is applied to your
> > kernel). If scanner meets, cached pfn will be reset and your patch
> > doesn't have any effect. So, I guess that scanner doesn't meet.
> > 
> 
> If the scanners meet, we should rely on deferred compaction to suppress 
> further attempts in the near future.  This is outside the scope of this 
> fix.
> 
> > We enter the compaction with enough free memory so stop in
> > isolate_freepages_block() should be unlikely event but your number
> > shows that it happens frequently?
> > 
> 
> It's not the only reason why freepages will be returned to the buddy 
> allocator: if locks become contended because we are spending too much time 
> compacting memory, we can persistently get free pages returned to the end 
> of the zone and then repeatedly iterate >100GB of memory on every call to 
> isolate_freepages(), which makes its own contended checks fire more often.  
> This patch is only an attempt to prevent lenghty iterations when we have 
> recently scanned the memory and found freepages to not be isolatable.

Hmm... I can't understand how freepage scanner is persistently
expensive. After freepage scanner get freepages, migration isn't
stopped until either migratable pages are empty or freepages are empty.

If there is no freepage, above problem doesn't happen so I assume that
there is no migratable pages after calling migrate_pages().

If there is no migratable pages, it means that freepages are used by
migration. Sometimes later, freepages in that pageblock are exhausted by
migration and freepage scanner will move the next pageblock. So, I
cannot understand how it is persistently expensive.

Am I missing something?

If it is caused by the fact that too many freepages are isolated at
once (up to migratable pages), we can modify logic to stop isolating
freepages when the pageblock is changed and freepage scanner has one
or more freepages.

> 
> > In addition, I worry that your previous patch that makes
> > isolate_freepages_block() stop when watermark doesn't meet would cause
> > compaction non-progress. Amount of free memory can be flutuated so
> > watermark fail would be temporaral. We need to break compaction in
> > this case? It would decrease compaction success rate if there is a
> > memory hogger in parallel. Any idea?
> > 
> 
> In my opinion, which I think is quite well known by now, the compaction 
> freeing scanner shouldn't be checking _any_ watermark.  The end result is 
> that we're migrating memory, not allocating additional memory; determining 
> if compaction should be done is best left lower on the stack.

Hmm...if there are many parallel compactors and we have no watermark check,
they consume all emergency memory. It can be mitigated by isolating
just one freepage in this case, but, potential risk would not
be disappeared.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

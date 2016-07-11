Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1846B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 19:02:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hh10so81993623pac.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 16:02:00 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id hz1si4821385pac.174.2016.07.11.16.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 16:01:59 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id hu1so26567564pad.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 16:01:59 -0700 (PDT)
Date: Mon, 11 Jul 2016 16:01:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: make sure freeing scanner isn't persistently
 expensive
In-Reply-To: <20160630073158.GA30114@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1607111556580.107663@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606281839050.101842@chino.kir.corp.google.com> <6685fe19-753d-7d76-aced-3bb071d7c81d@suse.cz> <alpine.DEB.2.10.1606291349320.145590@chino.kir.corp.google.com> <20160630073158.GA30114@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jun 2016, Joonsoo Kim wrote:

> We need to find a root cause of this problem, first.
> 
> I guess that this problem would happen when isolate_freepages_block()
> early stop due to watermark check (if your patch is applied to your
> kernel). If scanner meets, cached pfn will be reset and your patch
> doesn't have any effect. So, I guess that scanner doesn't meet.
> 

If the scanners meet, we should rely on deferred compaction to suppress 
further attempts in the near future.  This is outside the scope of this 
fix.

> We enter the compaction with enough free memory so stop in
> isolate_freepages_block() should be unlikely event but your number
> shows that it happens frequently?
> 

It's not the only reason why freepages will be returned to the buddy 
allocator: if locks become contended because we are spending too much time 
compacting memory, we can persistently get free pages returned to the end 
of the zone and then repeatedly iterate >100GB of memory on every call to 
isolate_freepages(), which makes its own contended checks fire more often.  
This patch is only an attempt to prevent lenghty iterations when we have 
recently scanned the memory and found freepages to not be isolatable.

> In addition, I worry that your previous patch that makes
> isolate_freepages_block() stop when watermark doesn't meet would cause
> compaction non-progress. Amount of free memory can be flutuated so
> watermark fail would be temporaral. We need to break compaction in
> this case? It would decrease compaction success rate if there is a
> memory hogger in parallel. Any idea?
> 

In my opinion, which I think is quite well known by now, the compaction 
freeing scanner shouldn't be checking _any_ watermark.  The end result is 
that we're migrating memory, not allocating additional memory; determining 
if compaction should be done is best left lower on the stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

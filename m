Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 970086B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 18:06:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so133206110pfb.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:06:32 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id b82si2109116pfb.196.2016.06.22.15.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 15:06:31 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id c2so21518068pfa.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:06:31 -0700 (PDT)
Date: Wed, 22 Jun 2016 15:06:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: abort free scanner if split fails
In-Reply-To: <20160622145617.79197acff1a7e617b9d9d393@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1606221502140.146497@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com> <alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com> <20160622145617.79197acff1a7e617b9d9d393@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 22 Jun 2016, Andrew Morton wrote:

> On Tue, 21 Jun 2016 18:22:49 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > If the memory compaction free scanner cannot successfully split a free
> > page (only possible due to per-zone low watermark), terminate the free 
> > scanner rather than continuing to scan memory needlessly.  If the 
> > watermark is insufficient for a free page of order <= cc->order, then 
> > terminate the scanner since all future splits will also likely fail.
> > 
> > This prevents the compaction freeing scanner from scanning all memory on 
> > very large zones (very noticeable for zones > 128GB, for instance) when 
> > all splits will likely fail while holding zone->lock.
> > 
> 
> This collides pretty heavily with Joonsoo's "mm/compaction: split
> freepages without holding the zone lock".
> 

Sorry if it wasn't clear, but I was proposing this patch for 4.7 
inclusion and Vlastimil agreed we should ask for that.  Joonsoo said he 
was prepared to rebase on top of that.  Is 
mm-compaction-split-freepages-without-holding-the-zone-lock.patch and 
friends going into 4.7 or are we deferring this fix until 4.8?

compaction_alloc() iterating a 128GB zone has been benchmarked to take 
over 400ms on some systems whereas any free page isolated and ready to be 
split ends up failing in split_free_page() because of the low watermark 
check and thus the iteration continues.

The next time compaction occurs, the freeing scanner will likely start at 
the end of the zone again since no success was made previously and we get 
the same lengthy iteration until the zone is brought above the low 
watermark.  All thp page faults can take >400ms in such a state without 
this fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C2CD1828E5
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 18:47:59 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id 20so6497020wmh.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 15:47:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z193si15683383wme.98.2016.04.04.15.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 15:47:58 -0700 (PDT)
Date: Mon, 4 Apr 2016 18:47:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm: filemap: only do access activations on reads
Message-ID: <20160404224750.GA14828@cmpxchg.org>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
 <1459790018-6630-3-git-send-email-hannes@cmpxchg.org>
 <20160404142233.cfdea284b8107768fb359efd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160404142233.cfdea284b8107768fb359efd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Freund <andres@anarazel.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Apr 04, 2016 at 02:22:33PM -0700, Andrew Morton wrote:
> On Mon,  4 Apr 2016 13:13:37 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Andres Freund observed that his database workload is struggling with
> > the transaction journal creating pressure on frequently read pages.
> > 
> > Access patterns like transaction journals frequently write the same
> > pages over and over, but in the majority of cases those pages are
> > never read back. There are no caching benefits to be had for those
> > pages, so activating them and having them put pressure on pages that
> > do benefit from caching is a bad choice.
> 
> Read-after-write is a pretty common pattern: temporary files for
> example.  What are the opportunities for regressions here?

The read(s) following the write will call mark_page_accessed() and so
promote the pages if their data is in fact repeatedly accessed. That
makes sense, because the writes really don't say anything about the
cache-worthiness. One write followed by one read shouldn't mean the
data is strongly benefiting from being cached. Only multiple reads.

What complicates that a little bit is that when the multiple reads do
happen on write-instantiated pages, the pages might have already been
aged somewhat in between, whereas fresh-faulting reads start counting
accesses from the head of the LRU right away. If both have re-use
distances shorter than memory, the LRU offset of pages instantiated by
writes could push the second access past eviction.

In that case, they would likely get picked up by refault detection and
promoted after all. So it would be one more IO, but nothing permanent.

This is also somewhat compensated by the dirty cache delaying reclaim
and giving these pages another round-trip anyway - unless dirty limits
cause the pages to be written back before they reach the LRU tail.

It's really hard to tell whether that would even be an issue since it
depends on whether a workload matching those parameters even exist. A
synthetic test doesn't really say us much about that. I think all we
can do here is decide whether the cache semantics make logical sense.

One thing I proposed in the thread that would compensate for the LRU
offset of write-instantiated pages would be to set PageReferenced on
these pages but never call mark_page_accessed() from the write. This
wouldn't be perfect because the distance between write and read does
not necessarily predict the distance between the subsequent reads, but
it would mean that the first read would promote the pages, whereas
repeatedly written files would never be activated or refault-activate.

Would that make sense? Is there something I'm missing?

> Did you consider providing userspace with a way to hint "this file is
> probably write-then-not-read"?

Yes, but I'm not too confident in that working out :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

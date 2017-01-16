Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62D646B0069
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 10:01:20 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so12060952wjb.5
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:01:20 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id a19si12711145wmd.119.2017.01.16.07.01.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 07:01:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id BA633C10A
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 15:01:18 +0000 (UTC)
Date: Mon, 16 Jan 2017 15:01:18 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/4] mm, page_alloc: Add a bulk page allocator
Message-ID: <20170116150118.7r6q55n2c4wlj244@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
 <20170109163518.6001-5-mgorman@techsingularity.net>
 <20170116152518.5519dc1e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170116152518.5519dc1e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Mon, Jan 16, 2017 at 03:25:18PM +0100, Jesper Dangaard Brouer wrote:
> On Mon,  9 Jan 2017 16:35:18 +0000
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > This patch adds a new page allocator interface via alloc_pages_bulk,
> > __alloc_pages_bulk and __alloc_pages_bulk_nodemask. A caller requests a
> > number of pages to be allocated and added to a list. They can be freed in
> > bulk using free_pages_bulk(). Note that it would theoretically be possible
> > to use free_hot_cold_page_list for faster frees if the symbol was exported,
> > the refcounts were 0 and the caller guaranteed it was not in an interrupt.
> > This would be significantly faster in the free path but also more unsafer
> > and a harder API to use.
> > 
> > The API is not guaranteed to return the requested number of pages and
> > may fail if the preferred allocation zone has limited free memory, the
> > cpuset changes during the allocation or page debugging decides to fail
> > an allocation. It's up to the caller to request more pages in batch if
> > necessary.
> > 
> > The following compares the allocation cost per page for different batch
> > sizes. The baseline is allocating them one at a time and it compares with
> > the performance when using the new allocation interface.
> 
> I've also played with testing the bulking API here:
>  [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench04_bulk.c
> 
> My baseline single (order-0 page) show: 158 cycles(tsc) 39.593 ns
> 
> Using bulking API:
>  Bulk:   1 cycles: 128 nanosec: 32.134
>  Bulk:   2 cycles: 107 nanosec: 26.783
>  Bulk:   3 cycles: 100 nanosec: 25.047
>  Bulk:   4 cycles:  95 nanosec: 23.988
>  Bulk:   8 cycles:  91 nanosec: 22.823
>  Bulk:  16 cycles:  88 nanosec: 22.093
>  Bulk:  32 cycles:  85 nanosec: 21.338
>  Bulk:  64 cycles:  85 nanosec: 21.315
>  Bulk: 128 cycles:  84 nanosec: 21.214
>  Bulk: 256 cycles: 115 nanosec: 28.979
> 
> This bulk API (and other improvements part of patchset) definitely
> moves the speed of the page allocator closer to my (crazy) time budget
> target of between 201 to 269 cycles per packet[1].  Remember I was
> reporting[2] order-0 cost between 231 to 277 cycles, at MM-summit
> 2016, so this is a huge improvement since then.
> 

Good to hear.

> The bulk numbers are great, but it still cannot compete with the
> recycles tricks used by drivers.  Looking at the code (and as Mel also
> mentions) there is room for improvements especially on the bulk free-side.
> 

A major component there is how the ref handling is done and the safety
checks. If necessary, you could mandate that callers drop the reference
count or allow pages to be freed with an elevated count to avoid the atomic
ops. In an early prototype, I made the refcount "mistake" and freeing was
half the cost. I restored it in the final version to have an API that was
almost identical to the existing allocator other than the bulking aspects.

You could also disable all the other safety checks and flag that the bulk
alloc/free potentially frees pages in inconsistent state.  That would
increase the performance at the cost of safety but that may be acceptable
given that driver recycling of pages also avoids the same checks.

You could also consider disabling the statistics updates to avoid a bunch
of per-cpu stat operations, particularly if the pages were mostly recycled
by the generic pool allocator.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

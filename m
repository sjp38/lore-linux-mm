Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id ED9516B0035
	for <linux-mm@kvack.org>; Sun,  3 Nov 2013 23:04:30 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id x10so6159442pdj.23
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 20:04:30 -0800 (PST)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id c9si9405860pbj.202.2013.11.03.20.04.29
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 20:04:30 -0800 (PST)
Message-ID: <1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: cache largest vma
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sun, 03 Nov 2013 20:04:22 -0800
In-Reply-To: <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran,
 Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, 2013-11-03 at 10:51 -0800, Linus Torvalds wrote:
> Ugh. This patch makes me angry. It looks way too ad-hoc.
> 
> I can well imagine that our current one-entry cache is crap and could
> be improved, but this looks too random. 

Indeed, my approach is random *because* I wanted to keep things as
simple and low overhead as possible. Caching the largest VMA is probably
as least invasive and as low as overhead as you can get in find_vma().

> Different code for the
> CONFIG_MMU case? Same name, but for non-MMU it's a single entry, for
> MMU it's an array? And the whole "largest" just looks odd. Plus why do
> you set LAST_USED if you also set LARGEST?
> 
> Did you try just a two- or four-entry pseudo-LRU instead, with a
> per-thread index for "last hit"? Or even possibly a small fixed-size
> hash table (say "idx = (add >> 10) & 3" or something)?
> 
> And what happens for threaded models? Maybe we'd be much better off
> making the cache be per-thread, and the flushing of the cache would be
> a sequence number that has to match (so "vma_clear_cache()" ends up
> just incrementing a 64-bit sequence number in the mm)?

I will look into doing the vma cache per thread instead of mm (I hadn't
really looked at the problem like this) as well as Ingo's suggestion on
the weighted LRU approach. However, having seen that we can cheaply and
easily reach around ~70% hit rate in a lot of workloads, makes me wonder
how good is good enough?

> Basically, my complaints boil down to "too random" and "too
> specialized", and I can see (and you already comment on) this patch
> being grown with even *more* ad-hoc random new cases (LAST, LARGEST,
> MOST_USED - what's next?). And while I don't know if we should worry
> about the threaded case, I do get the feeling that this ad-hoc
> approach is guaranteed to never work for that, which makes me feel
> that it's not just ad-hoc, it's also fundamentally limited.
> 
> I can see us merging this patch, but I would really like to hear that
> we do so because other cleaner approaches don't work well. In
> particular, pseudo-LRU tends to be successful (and cheap) for caches.

OK, will report back with comparisons, hopefully I'll have a better
picture by then.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

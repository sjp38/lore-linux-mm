Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBFC6B0035
	for <linux-mm@kvack.org>; Sun,  3 Nov 2013 13:51:30 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so6085876pab.32
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 10:51:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.149])
        by mx.google.com with SMTP id l8si8742113pbi.91.2013.11.03.10.51.28
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 10:51:29 -0800 (PST)
Received: by mail-ve0-f181.google.com with SMTP id jz11so894715veb.40
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 10:51:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
Date: Sun, 3 Nov 2013 10:51:27 -0800
Message-ID: <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
Subject: Re: [PATCH] mm: cache largest vma
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Ugh. This patch makes me angry. It looks way too ad-hoc.

I can well imagine that our current one-entry cache is crap and could
be improved, but this looks too random. Different code for the
CONFIG_MMU case? Same name, but for non-MMU it's a single entry, for
MMU it's an array? And the whole "largest" just looks odd. Plus why do
you set LAST_USED if you also set LARGEST?

Did you try just a two- or four-entry pseudo-LRU instead, with a
per-thread index for "last hit"? Or even possibly a small fixed-size
hash table (say "idx = (add >> 10) & 3" or something)?

And what happens for threaded models? Maybe we'd be much better off
making the cache be per-thread, and the flushing of the cache would be
a sequence number that has to match (so "vma_clear_cache()" ends up
just incrementing a 64-bit sequence number in the mm)?

Basically, my complaints boil down to "too random" and "too
specialized", and I can see (and you already comment on) this patch
being grown with even *more* ad-hoc random new cases (LAST, LARGEST,
MOST_USED - what's next?). And while I don't know if we should worry
about the threaded case, I do get the feeling that this ad-hoc
approach is guaranteed to never work for that, which makes me feel
that it's not just ad-hoc, it's also fundamentally limited.

I can see us merging this patch, but I would really like to hear that
we do so because other cleaner approaches don't work well. In
particular, pseudo-LRU tends to be successful (and cheap) for caches.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

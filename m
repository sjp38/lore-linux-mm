Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 122566B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 09:56:42 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md4so7170114pbc.16
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 06:56:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.193])
        by mx.google.com with SMTP id bc2si11005992pad.129.2013.11.04.06.56.40
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 06:56:41 -0800 (PST)
Received: by mail-qa0-f51.google.com with SMTP id hu16so126966qab.3
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 06:56:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131104073640.GF13030@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
	<1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
	<20131104073640.GF13030@gmail.com>
Date: Mon, 4 Nov 2013 06:56:38 -0800
Message-ID: <CANN689EdM6+64hsJgGMSF=6aA8hYJf_4FgdCy3FtqRtDAv87qw@mail.gmail.com>
Subject: Re: [PATCH] mm: cache largest vma
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, Nov 3, 2013 at 11:36 PM, Ingo Molnar <mingo@kernel.org> wrote:
> So I think it all really depends on the hit/miss cost difference. It makes
> little sense to add a more complex scheme if it washes out most of the
> benefits!
>
> Also note the historic context: the _original_ mmap_cache, that I
> implemented 16 years ago, was a front-line cache to a linear list walk
> over all vmas (!).
>
> Today we have the vma rbtree, which is self-balancing and a lot faster
> than your typical linear list walk search ;-)
>
> So I'd _really_ suggest to first examine the assumptions behind the cache,
> it being named 'cache' and it having a hit rate does in itself not
> guarantee that it gives us any worthwile cost savings when put in front of
> an rbtree ...

Agree. We have made the general case a lot faster, and caches in front
of it may not pull their weight anymore - the fact that we are
wondering how to even measure that, to me, means that we probably
shouldn't even bother. That's what I did when I implemented the
augmented rbtree to search for allocatable spaces between vmas: I
removed the cache for the last used gap, and nobody has complained
about it since. Absent some contrary data, I would actually prefer we
remove the mmap_cache as well.

And if a multiple-entry cache is necessary, I would also prefer it to
be LRU type rather than something ad-hoc (if there is a benefit to
caching the largest VMA, then LRU would capture that as well...)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7556B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 16:22:14 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so59690003igc.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 13:22:14 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id ip4si1174935igb.21.2015.09.07.13.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 13:22:13 -0700 (PDT)
Received: by igbni9 with SMTP id ni9so63363226igb.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 13:22:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150907113026.5bb28ca3@redhat.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
	<20150904032607.GX1933@devil.localdomain>
	<CA+55aFzBTL=DnC4zv6yxjk0HxwxWpOhpKDPA8zkTGdgbh08sEg@mail.gmail.com>
	<20150907113026.5bb28ca3@redhat.com>
Date: Mon, 7 Sep 2015 13:22:13 -0700
Message-ID: <CA+55aFym-dM37xtvKjddMheSV9vPUq=tnN9FoFvEgD0QWW22sg@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On Mon, Sep 7, 2015 at 2:30 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> The slub allocator have a faster "fastpath", if your workload is
> fast-reusing within the same per-cpu page-slab, but once the workload
> increases you hit the slowpath, and then slab catches up. Slub looks
> great in micro-benchmarking.
>
> And with "slab_nomerge" I get even high performance:

I think those two are related.

Not merging means that effectively the percpu caches end up being
bigger (simply because there are more of them), and so it captures
more of the fastpath cases.

Obviously the percpu queue size is an easy tunable too, but there are
real downsides to that too. I suspect your IP forwarding case isn't so
different from some of the microbenchmarks, it just has more
outstanding work..

And yes, the slow path (ie not hitting in the percpu cache) of SLUB
could hopefully be optimizable too, although maybe the bulk patches
are the way to go (and unrelated to this thread - at least part of
your bulk patches actually got merged last Friday - they were part of
Andrew's patch-bomb).

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

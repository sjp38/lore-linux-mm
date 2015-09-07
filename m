Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 218F36B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 17:17:28 -0400 (EDT)
Received: by qgev79 with SMTP id v79so68827714qge.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 14:17:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 87si1243860qkx.83.2015.09.07.14.17.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 14:17:27 -0700 (PDT)
Date: Mon, 7 Sep 2015 23:17:15 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150907231715.0a375b40@redhat.com>
In-Reply-To: <CA+55aFym-dM37xtvKjddMheSV9vPUq=tnN9FoFvEgD0QWW22sg@mail.gmail.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
	<20150904032607.GX1933@devil.localdomain>
	<CA+55aFzBTL=DnC4zv6yxjk0HxwxWpOhpKDPA8zkTGdgbh08sEg@mail.gmail.com>
	<20150907113026.5bb28ca3@redhat.com>
	<CA+55aFym-dM37xtvKjddMheSV9vPUq=tnN9FoFvEgD0QWW22sg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, brouer@redhat.com

On Mon, 7 Sep 2015 13:22:13 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Sep 7, 2015 at 2:30 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> >
> > The slub allocator have a faster "fastpath", if your workload is
> > fast-reusing within the same per-cpu page-slab, but once the workload
> > increases you hit the slowpath, and then slab catches up. Slub looks
> > great in micro-benchmarking.
> >
> > And with "slab_nomerge" I get even high performance:
> 
> I think those two are related.
> 
> Not merging means that effectively the percpu caches end up being
> bigger (simply because there are more of them), and so it captures
> more of the fastpath cases.

Yes, that was also my theory.  As manually tuning the percpu sizes gave
me almost the same boost.


> Obviously the percpu queue size is an easy tunable too, but there are
> real downsides to that too. 

The easy fix is to introduce a subsystem specific percpu cache that is
large enough for our use-case.  That seems to be a trend. I'm hoping to
come up with something smarter that every subsystem can benefit from. 
E.g some heuristic that can dynamic adjust SLUB according to the usage
pattern. I can imagine something as simple as a counter for every
slowpath call, that is only valid as long as the jiffies count matches
(reset to zero, and store new jiffies cnt).  (But I have not thought
this through...)


> I suspect your IP forwarding case isn't so
> different from some of the microbenchmarks, it just has more
> outstanding work..

Yes, I will admit that my testing is very close to micro benchmarking,
and it is specifically designed to pressure the system to its limits[1].
Especially the minimum frame size is evil and unrealistic, but the real
purpose is preparing the stack for increasing speeds like 100Gbit/s.


> And yes, the slow path (ie not hitting in the percpu cache) of SLUB
> could hopefully be optimizable too, although maybe the bulk patches
> are the way to go (and unrelated to this thread - at least part of
> your bulk patches actually got merged last Friday - they were part of
> Andrew's patch-bomb).

Cool. Yes, it is only part of the bulk patches. The real performance
boosters are not in yet (but I need to make them work correctly with
memory debugging enabled before they can get merged).  At least the
main API is in, which allows me to implement use-case easier in other
subsystems :-)

[1] http://netoptimizer.blogspot.dk/2014/09/packet-per-sec-measurements-for.html
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

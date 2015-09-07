Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 04EED6B0256
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 05:30:39 -0400 (EDT)
Received: by iofh134 with SMTP id h134so83007006iof.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 02:30:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v4si5634634pdp.62.2015.09.07.02.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 02:30:38 -0700 (PDT)
Date: Mon, 7 Sep 2015 11:30:26 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150907113026.5bb28ca3@redhat.com>
In-Reply-To: <CA+55aFzBTL=DnC4zv6yxjk0HxwxWpOhpKDPA8zkTGdgbh08sEg@mail.gmail.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
	<20150904032607.GX1933@devil.localdomain>
	<CA+55aFzBTL=DnC4zv6yxjk0HxwxWpOhpKDPA8zkTGdgbh08sEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: brouer@redhat.com, Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>


On Thu, 3 Sep 2015 20:51:09 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Sep 3, 2015 at 8:26 PM, Dave Chinner <dchinner@redhat.com> wrote:
> >
> > The double standard is the problem here. No notification, proof,
> > discussion or review was needed to turn on slab merging for
> > everyone, but you're setting a very high bar to jump if anyone wants
> > to turn it off in their code.
> 
> Ehh. You realize that almost the only load that is actually seriously
> allocator-limited is networking?
> 
> And slub was beating slab on that? And slub has been doing the merging
> since day one. Slab was just changed to try to keep up with the
> winning strategy.

Sorry, I have to correct you on this.  The slub allocator is not as
fast as you might think.  The slab allocator is actually faster for
networking.

IP-forwarding, single CPU, single flow UDP (highly tuned):
 * Allocator slub: 2043575 pps
 * Allocator slab: 2088295 pps

Difference slab faster than slub:
 * +44720 pps and -10.48ns

The slub allocator have a faster "fastpath", if your workload is
fast-reusing within the same per-cpu page-slab, but once the workload
increases you hit the slowpath, and then slab catches up. Slub looks
great in micro-benchmarking.


As you can see in patchset:
 [PATCH 0/3] Network stack, first user of SLAB/kmem_cache bulk free API.
 http://thread.gmane.org/gmane.linux.kernel.mm/137469/focus=376625

I'm working on speeding up slub to the level of slab.  And it seems
like I have succeeded with half-a-nanosec 2090522 pps (+2227 pps or
0.51 ns).

And with "slab_nomerge" I get even high performance:
 * slub: bulk-free and slab_nomerge: 2121824 pps
 * Diff to slub: +78249 and -18.05ns

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

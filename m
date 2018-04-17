Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E47CB6B0279
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:49:35 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id s138so12578585qke.10
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:49:35 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id a130si14103776qkg.352.2018.04.17.07.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:49:35 -0700 (PDT)
Date: Tue, 17 Apr 2018 09:49:28 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <b0e6ccf6-06ce-e50b-840e-c8d3072382fd@suse.cz>
Message-ID: <alpine.DEB.2.20.1804170948170.17557@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161054410.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161018030.9397@nuc-kabylake>
 <alpine.LRH.2.02.1804161123400.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161043430.9622@nuc-kabylake> <alpine.LRH.2.02.1804161532480.19492@file01.intranet.prod.int.rdu2.redhat.com> <b0e6ccf6-06ce-e50b-840e-c8d3072382fd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 16 Apr 2018, Vlastimil Babka wrote:

> >> Its not a senseless increase. The more objects you fit into a slab page
> >> the higher the performance of the allocator.
>
> It's not universally without a cost. It might increase internal
> fragmentation of the slabs, if you end up with lots of 4MB pages
> containing just few objects. Thus, waste of memory. You also consume
> high-order pages that could be used elsewhere. If you fail to allocate
> 4MB, then what's the fallback, order-0? I doubt it's "the highest
> available order". Thus, a more conservative choice e.g. order-3 will
> might succeed more in allocating order-3, while a choice of 4MB will
> have many order-0 fallbacks.

Obviously there is a cost. But here the subsystem has a fallback.

> I think it should be possible without a new flag. The slub allocator
> could just balance priorities (performance vs memory efficiency) better.
> Currently I get the impression that "slub_max_order" is a performance
> tunable. Let's add another criteria for selecting an order, that would
> try to pick an order to minimize wasted space below e.g. 10% with some
> different kind of max order. Pick good defaults, add tunables if you must.

There is also slub_min_objects.

> I mean, anyone who's creating a cache for 640KB objects most likely
> doesn't want to waste another 384KB by each such object. They shouldn't
> have to add a flag to let the slub allocator figure out that using 2MB
> pages is the right thing to do here.

I agree if we do this then preferably without a flag.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7F046B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:01:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q10so11133298qtp.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:01:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v2si10425951qkh.112.2018.04.16.14.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 14:01:15 -0700 (PDT)
Date: Mon, 16 Apr 2018 17:01:13 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <b0e6ccf6-06ce-e50b-840e-c8d3072382fd@suse.cz>
Message-ID: <alpine.LRH.2.02.1804161650170.7237@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161054410.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161018030.9397@nuc-kabylake>
 <alpine.LRH.2.02.1804161123400.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161043430.9622@nuc-kabylake> <alpine.LRH.2.02.1804161532480.19492@file01.intranet.prod.int.rdu2.redhat.com> <b0e6ccf6-06ce-e50b-840e-c8d3072382fd@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On Mon, 16 Apr 2018, Vlastimil Babka wrote:

> On 04/16/2018 09:36 PM, Mikulas Patocka wrote:
> 
> >>> I need to increase it just for dm-bufio slabs.
> >>
> >> If you do this then others will want the same...
> > 
> > If others need it, they can turn on the flag SLAB_MINIMIZE_WASTE too.
> 
> I think it should be possible without a new flag. The slub allocator
> could just balance priorities (performance vs memory efficiency) better.
> Currently I get the impression that "slub_max_order" is a performance
> tunable. Let's add another criteria for selecting an order, that would
> try to pick an order to minimize wasted space below e.g. 10% with some
> different kind of max order. Pick good defaults, add tunables if you must.
> 
> I mean, anyone who's creating a cache for 640KB objects most likely
> doesn't want to waste another 384KB by each such object. They shouldn't
> have to add a flag to let the slub allocator figure out that using 2MB
> pages is the right thing to do here.
> 
> Vlastimil

The problem is that higher-order allocations (larger than 32K) are 
unreliable. So, if you increase page order beyond that, the allocation may 
randomly fail.

dm-bufio deals gracefully with allocation failure, because it preallocates 
some buffers with vmalloc, but other subsystems may not deal with it and 
they cound return ENOMEM randomly or misbehave in other ways. So, the 
"SLAB_MINIMIZE_WASTE" flag is also saying that the allocation may fail and 
the caller is prepared to deal with it.

The slub subsystem does actual fallback to low-order when the allocation 
fails (it allows different order for each slab in the same cache), but 
slab doesn't fallback and you get NULL if higher-order allocation fails. 
So, SLAB_MINIMIZE_WASTE is needed for slab because it will just randomly 
fail with higher order.

Mikulas

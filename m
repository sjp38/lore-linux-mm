Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E67A6B0280
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q19so3890061qta.17
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f10si6596829qki.156.2018.03.21.12.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:25:09 -0700 (PDT)
Date: Wed, 21 Mar 2018 15:25:07 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1803211522310.26409@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>



On Wed, 21 Mar 2018, Christopher Lameter wrote:

> One other thought: If you want to improve the behavior for large scale
> objects allocated through kmalloc/kmemcache then we would certainly be
> glad to entertain those ideas.
> 
> F.e. you could optimize the allcations > 2x PAGE_SIZE so that they do not
> allocate powers of two pages. It would be relatively easy to make
> kmalloc_large round the allocation to the next page size and then allocate
> N consecutive pages via alloc_pages_exact() and free the remainder unused
> pages or some such thing.

It may be possible, but we'd need to improve the horrible complexity of 
alloc_pages_exact().

This is a trade-of between performance and waste. A power-of-two 
allocation can be done quicky, but it wastes a lot of space. 
alloc_pages_exact() wastes less space, but it is slow.

The question is - how many of these large-kmalloc allocations are 
short-lived and how many are long-lived? I don't know, I haven't measured 
it.

Mikulas

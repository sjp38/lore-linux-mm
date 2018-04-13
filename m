Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1C246B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 11:10:22 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id a11-v6so5362963ybl.19
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:10:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c84si8196032qkh.117.2018.04.13.08.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 08:10:21 -0700 (PDT)
Date: Fri, 13 Apr 2018 11:10:19 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
Message-ID: <20180413151019.GA5660@redhat.com>
References: <20180320173512.GA19669@bombadil.infradead.org>
 <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
 <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Apr 13 2018 at  5:22am -0400,
Vlastimil Babka <vbabka@suse.cz> wrote:

> On 03/21/2018 07:36 PM, Mikulas Patocka wrote:
> > 
> > 
> > On Wed, 21 Mar 2018, Christopher Lameter wrote:
> > 
> >> On Wed, 21 Mar 2018, Mikulas Patocka wrote:
> >>
> >>>> You should not be using the slab allocators for these. Allocate higher
> >>>> order pages or numbers of consecutive smaller pagess from the page
> >>>> allocator. The slab allocators are written for objects smaller than page
> >>>> size.
> >>>
> >>> So, do you argue that I need to write my own slab cache functionality
> >>> instead of using the existing slab code?
> >>
> >> Just use the existing page allocator calls to allocate and free the
> >> memory you need.
> >>
> >>> I can do it - but duplicating code is bad thing.
> >>
> >> There is no need to duplicate anything. There is lots of infrastructure
> >> already in the kernel. You just need to use the right allocation / freeing
> >> calls.
> > 
> > So, what would you recommend for allocating 640KB objects while minimizing 
> > wasted space?
> > * alloc_pages - rounds up to the next power of two
> > * kmalloc - rounds up to the next power of two
> > * alloc_pages_exact - O(n*log n) complexity; and causes memory 
> >   fragmentation if used excesivelly
> > * vmalloc - horrible performance (modifies page tables and that causes 
> >   synchronization across all CPUs)
> > 
> > anything else?
> > 
> > The slab cache with large order seems as a best choice for this.
> 
> Sorry for being late, I just read this thread and tend to agree with
> Mikulas, that this is a good use case for SL*B. If we extend the
> use-case from "space-efficient allocator of objects smaller than page
> size" to "space-efficient allocator of objects that are not power-of-two
> pages" then IMHO it turns out the implementation would be almost the
> same. All other variants listed above would lead to waste of memory or
> fragmentation.
> 
> Would this perhaps be a good LSF/MM discussion topic? Mikulas, are you
> attending, or anyone else that can vouch for your usecase?

Any further discussion on SLAB_MINIMIZE_WASTE should continue on list.

Mikulas won't be at LSF/MM.  But I included Mikulas' dm-bufio changes
that no longer depend on this proposed SLAB_MINIMIZE_WASTE (as part of
the 4.17 merge window).

Mike

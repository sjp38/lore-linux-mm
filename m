Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5A676B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 12:41:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u127so1789397qka.9
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 09:41:50 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id k31-v6si1748172qvh.111.2018.04.27.09.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 09:41:49 -0700 (PDT)
Date: Fri, 27 Apr 2018 11:41:48 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1804261508430.26980@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1804271136390.11686@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
 <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804180952580.1334@nuc-kabylake> <alpine.LRH.2.02.1804251702250.9428@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804251917460.2429@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1804261354230.6674@nuc-kabylake> <alpine.LRH.2.02.1804261508430.26980@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, 26 Apr 2018, Mikulas Patocka wrote:

> > Hmmm... order 4 for these caches may cause some concern. These should stay
> > under costly order I think. Otherwise allocations are no longer
> > guaranteed.
>
> You said that slub has fallback to smaller order allocations.

Yes it does...

> The whole purpose of this "minimize waste" approach is to use higher-order
> allocations to use memory more efficiently, so it is just doing its job.
> (for these 3 caches, order-4 really wastes less memory than order-3 - on
> my system TCPv6 and sighand_cache have size 2112, task_struct 2752).

Hmmm... Ok if the others are fine with this as well. I got some pushback
there in the past.

> We could improve the fallback code, so that if order-4 allocation fails,
> it tries order-3 allocation, and then falls back to order-0. But I think
> that these failures are rare enough that it is not a problem.

I also think that would be too many fallbacks.

> > > +		/* Increase order even more, but only if it reduces waste */
> > > +		if (test_order_obj <= 32 &&
> >
> > Where does the 32 come from?
>
> It is to avoid extremely high order for extremely small slabs.
>
> For example, see kmalloc-96.
> 10922 96-byte objects would fit into 1MiB
> 21845 96-byte objects would fit into 2MiB

That is the result of considering absolute byte wastage..

> The algorithm would recognize this one more object that fits into 2MiB
> slab as "waste reduction" and increase the order to 2MiB - and we don't
> want this.
>
> So, the general reasoning is - if we have 32 objects in a slab, then it is
> already considered that wasted space is reasonably low and we don't want
> to increase the order more.
>
> Currently, kmalloc-96 uses order-0 - that is reasonable (we already have
> 42 objects in 4k page, so we don't need to use higher order, even if it
> wastes one-less object).


The old code uses the concept of a "fraction" to calculate overhead. The
code here uses absolute counts of bytes. Fraction looks better to me.

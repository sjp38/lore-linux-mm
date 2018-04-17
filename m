Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51D866B0009
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:38:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h141so1987974qke.6
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 09:38:07 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id x128si2572171qkd.131.2018.04.17.09.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 09:38:06 -0700 (PDT)
Date: Tue, 17 Apr 2018 11:38:02 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <f8f736fe-9e0e-acd2-8040-f4f25ea5a7a2@suse.cz>
Message-ID: <alpine.DEB.2.20.1804171135190.18801@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
 <f8f736fe-9e0e-acd2-8040-f4f25ea5a7a2@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, 17 Apr 2018, Vlastimil Babka wrote:

> On 04/17/2018 04:45 PM, Christopher Lameter wrote:

> > But then higher order allocs are generally seen as problematic.
>
> I think in this case they are better than wasting/fragmenting 384kB for
> 640kB object.

Well typically we have suggested that people use vmalloc in the past.


> > Note that SLUB will fall back to smallest order already if a failure
> > occurs so increasing slub_max_order may not be that much of an issue.
> >
> > Maybe drop the max order limit completely and use MAX_ORDER instead?
>
> For packing, sure. For performance, please no (i.e. don't try to
> allocate MAX_ORDER for each and every cache).

No of course not. We would have to modify the order selection on kmem
cache creation.

> > That
> > means that callers need to be able to tolerate failures.
>
> Is it any different from now? I suppose there would still be
> smallest-order fallback involved in sl*b itself? And if your allocation
> is so large it can fail even with the fallback (i.e. >= costly order),
> you need to tolerate failures anyway?

Failures can occur even with < costly order as far as I can telkl. Order 0
is the only safe one.

> One corner case I see is if there is anyone who would rather use their
> own fallback instead of the space-wasting smallest-order fallback.
> Maybe we could map some GFP flag to indicate that.

Well if you have a fallback then maybe the slab allocator should not fall
back on its own but let the caller deal with it.

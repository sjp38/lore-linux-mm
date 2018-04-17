Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE0286B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 13:26:58 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id g138so9268633qke.22
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:26:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a20si6755271qth.204.2018.04.17.10.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 10:26:57 -0700 (PDT)
Date: Tue, 17 Apr 2018 13:26:51 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <f8f736fe-9e0e-acd2-8040-f4f25ea5a7a2@suse.cz>
Message-ID: <alpine.LRH.2.02.1804171318010.5023@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
 <f8f736fe-9e0e-acd2-8040-f4f25ea5a7a2@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On Tue, 17 Apr 2018, Vlastimil Babka wrote:

> On 04/17/2018 04:45 PM, Christopher Lameter wrote:
> > On Mon, 16 Apr 2018, Mikulas Patocka wrote:
> > 
> >> This patch introduces a flag SLAB_MINIMIZE_WASTE for slab and slub. This
> >> flag causes allocation of larger slab caches in order to minimize wasted
> >> space.
> >>
> >> This is needed because we want to use dm-bufio for deduplication index and
> >> there are existing installations with non-power-of-two block sizes (such
> >> as 640KB). The performance of the whole solution depends on efficient
> >> memory use, so we must waste as little memory as possible.
> > 
> > Hmmm. Can we come up with a generic solution instead?
> 
> Yes please.
> 
> > This may mean relaxing the enforcement of the allocation max order a bit
> > so that we can get dense allocation through higher order allocs.
> > 
> > But then higher order allocs are generally seen as problematic.
> 
> I think in this case they are better than wasting/fragmenting 384kB for
> 640kB object.

Wasting 37% of memory is still better than the kernel randomly returning 
-ENOMEM when higher-order allocation fails.

> > That
> > means that callers need to be able to tolerate failures.
> 
> Is it any different from now? I suppose there would still be
> smallest-order fallback involved in sl*b itself? And if your allocation
> is so large it can fail even with the fallback (i.e. >= costly order),
> you need to tolerate failures anyway?
> 
> One corner case I see is if there is anyone who would rather use their
> own fallback instead of the space-wasting smallest-order fallback.
> Maybe we could map some GFP flag to indicate that.

For example, if you create a cache with 17KB objects, the slab subsystem 
will pad it up to 32KB. You are wasting almost 1/2 memory, but the 
allocation is realiable and it won't fail.

If you use order higher than 32KB, you get less wasted memory, but you 
also get random -ENOMEMs (yes, we had a problem in dm-thin that it was 
randomly failing during initialization due to 64KB allocation).

Mikulas

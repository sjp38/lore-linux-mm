Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF7E6B0008
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 10:52:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v8so6574536wmv.1
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 07:52:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t4si1991195edt.195.2018.04.03.07.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 07:52:52 -0700 (PDT)
Date: Tue, 3 Apr 2018 10:54:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
Message-ID: <20180403145408.GA21411@cmpxchg.org>
References: <20180321205928.22240-1-mhocko@kernel.org>
 <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Mar 21, 2018 at 02:22:13PM -0700, David Rientjes wrote:
> PAGE_ALLOC_COSTLY_ORDER is a heuristic used by the page allocator because 
> it cannot free high-order contiguous memory.  Memcg just needs to reclaim 
> a number of pages.  Two order-3 charges can cause a memcg oom kill but now 
> an order-4 charge cannot.  It's an unfair bias against high-order charges 
> that are not explicitly using __GFP_NORETRY.

I agree with your premise: unlike the page allocator, memcg could OOM
kill to help satisfy higher order allocations.

Technically.

But the semantics and expectations matter too.

Because of the allocator's restriction, we've been telling and
teaching callsites to fail gracefully and implement fallbacks forever,
and that makes costly-order allocations inherently speculative and to
a certain extent often optional. They've been written with that in
mind forever.

OOM is not graceful failure, though. We don't want to OOM kill when an
the callsite can easily fallback to smaller allocations, trigger a
packet resend, fail the syscall, what have you.

We could argue what the default should be if callsites aren't
specifically annotated - and whether we should change it.

But the page allocator has established the default behavior already,
and this is a bugfix. I prefer this fix not fundamentally change
semantics for costly-order allocations.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id A555C6B0038
	for <linux-mm@kvack.org>; Tue, 27 May 2014 13:29:37 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id j107so14295438qga.20
        for <linux-mm@kvack.org>; Tue, 27 May 2014 10:29:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h7si18431242qan.34.2014.05.27.10.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 May 2014 10:29:37 -0700 (PDT)
Date: Tue, 27 May 2014 19:29:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
Message-ID: <20140527172930.GE11074@laptop.programming.kicks-ass.net>
References: <20140526203232.GC5444@laptop.programming.kicks-ass.net>
 <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net>
 <alpine.DEB.2.10.1405270929550.13999@gentwo.org>
 <20140527144655.GC19143@laptop.programming.kicks-ass.net>
 <alpine.DEB.2.10.1405271011100.14466@gentwo.org>
 <20140527153143.GD19143@laptop.programming.kicks-ass.net>
 <alpine.DEB.2.10.1405271128530.14883@gentwo.org>
 <20140527164341.GD11074@laptop.programming.kicks-ass.net>
 <alpine.DEB.2.10.1405271152400.14883@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405271152400.14883@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, May 27, 2014 at 11:56:44AM -0500, Christoph Lameter wrote:
> On Tue, 27 May 2014, Peter Zijlstra wrote:
> 
> > > Code could be easily added to alloc_pages_vma() to consider the pinned
> > > status on allocation. Remove GFP_MOVABLE if the vma is pinned.
> >
> > Yes, but alloc_pages_vma() isn't used for shared pages (with exception
> > of shmem and hugetlbfs).
> 
> alloc_pages_vma() is used for all paths where we populate address ranges
> with pages. This is what we are doing when pinning. Pages are not
> allocated outside of a vma context.
> 
> What do you mean by shared pages that are not shmem pages? AnonPages that
> are referenced from multiple processes?

Regular files.. they get allocated through __page_cache_alloc(). AFAIK
there is nothing stopping people from pinning file pages for RDMA or
other purposes. Unusual maybe, but certainly not impossible, and
therefore we must be able to handle it.

> > So whichever way around we have to do the mm_populate() + eviction hook
> > + migration code, and since that equally covers the anon case, why
> > bother?
> 
> Migration is expensive and the memory registration overhead already
> causes lots of complaints.

Sure, but first to the simple thing, then if its a problem do something
else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

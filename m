Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABD76B00A7
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:31:51 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id i8so13882267qcq.4
        for <linux-mm@kvack.org>; Tue, 27 May 2014 08:31:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id y10si17928658qaj.18.2014.05.27.08.31.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 May 2014 08:31:50 -0700 (PDT)
Date: Tue, 27 May 2014 17:31:43 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
Message-ID: <20140527153143.GD19143@laptop.programming.kicks-ass.net>
References: <20140526145605.016140154@infradead.org>
 <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
 <20140526203232.GC5444@laptop.programming.kicks-ass.net>
 <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net>
 <alpine.DEB.2.10.1405270929550.13999@gentwo.org>
 <20140527144655.GC19143@laptop.programming.kicks-ass.net>
 <alpine.DEB.2.10.1405271011100.14466@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405271011100.14466@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, May 27, 2014 at 10:14:10AM -0500, Christoph Lameter wrote:
> On Tue, 27 May 2014, Peter Zijlstra wrote:
> 
> > Well, like with IB, they start out as normal userspace pages, and will
> > be from ZONE_MOVABLE.
> 
> Well we could change that now I think. If the VMA has VM_PINNED set
> pages then do not allocate from ZONE_MOVABLE.

But most allocations sites don't have the vma. We allocate page-cache
pages based on its address_space/mapping, not on whatever vma they're
mapped into.

So I still think the sanest way to do this is by making mm_mpin() do a
mm_populate() and have reclaim skip VM_PINNED pages (so they stay
present), and then migrate the lot out of MOVABLE.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

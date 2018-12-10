Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE7B68E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:47:20 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so7568807pgb.10
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 06:47:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id ay4si9814820plb.235.2018.12.10.06.47.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Dec 2018 06:47:19 -0800 (PST)
Date: Mon, 10 Dec 2018 15:47:11 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/4] kernel.h: Add non_block_start/end()
Message-ID: <20181210144711.GN5289@hirez.programming.kicks-ass.net>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
 <20181210103641.31259-3-daniel.vetter@ffwll.ch>
 <20181210141337.GQ1286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210141337.GQ1286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Mon, Dec 10, 2018 at 03:13:37PM +0100, Michal Hocko wrote:
> I do not see any scheduler guys Cced and it would be really great to get
> their opinion here.
> 
> On Mon 10-12-18 11:36:39, Daniel Vetter wrote:
> > In some special cases we must not block, but there's not a
> > spinlock, preempt-off, irqs-off or similar critical section already
> > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > pair to annotate these.
> > 
> > This will be used in the oom paths of mmu-notifiers, where blocking is
> > not allowed to make sure there's forward progress.
> 
> Considering the only alternative would be to abuse
> preempt_{disable,enable}, and that really has a different semantic, I
> think this makes some sense. The cotext is preemptible but we do not
> want notifier to sleep on any locks, WQ etc.

I'm confused... what is this supposed to do?

And what does 'block' mean here? Without preempt_disable/IRQ-off we're
subject to regular preemption and execution can stall for arbitrary
amounts of time.

The Changelog doesn't yield any clues.

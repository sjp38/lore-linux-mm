Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE3CF8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 10:02:03 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q63so10021842pfi.19
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 07:02:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4si9967511plr.306.2018.12.10.07.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 07:02:02 -0800 (PST)
Date: Mon, 10 Dec 2018 16:01:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] kernel.h: Add non_block_start/end()
Message-ID: <20181210150159.GR1286@dhcp22.suse.cz>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
 <20181210103641.31259-3-daniel.vetter@ffwll.ch>
 <20181210141337.GQ1286@dhcp22.suse.cz>
 <20181210144711.GN5289@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210144711.GN5289@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Mon 10-12-18 15:47:11, Peter Zijlstra wrote:
> On Mon, Dec 10, 2018 at 03:13:37PM +0100, Michal Hocko wrote:
> > I do not see any scheduler guys Cced and it would be really great to get
> > their opinion here.
> > 
> > On Mon 10-12-18 11:36:39, Daniel Vetter wrote:
> > > In some special cases we must not block, but there's not a
> > > spinlock, preempt-off, irqs-off or similar critical section already
> > > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > > pair to annotate these.
> > > 
> > > This will be used in the oom paths of mmu-notifiers, where blocking is
> > > not allowed to make sure there's forward progress.
> > 
> > Considering the only alternative would be to abuse
> > preempt_{disable,enable}, and that really has a different semantic, I
> > think this makes some sense. The cotext is preemptible but we do not
> > want notifier to sleep on any locks, WQ etc.
> 
> I'm confused... what is this supposed to do?
> 
> And what does 'block' mean here? Without preempt_disable/IRQ-off we're
> subject to regular preemption and execution can stall for arbitrary
> amounts of time.

The notifier is called from quite a restricted context - oom_reaper - 
which shouldn't depend on any locks or sleepable conditionals. The code
should be swift as well but we mostly do care about it to make a forward
progress. Checking for sleepable context is the best thing we could come
up with that would describe these demands at least partially.

-- 
Michal Hocko
SUSE Labs

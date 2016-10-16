Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E47F36B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 02:11:02 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rz1so163236413pab.0
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 23:11:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z135si21903585pgz.214.2016.10.15.23.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 23:11:01 -0700 (PDT)
Date: Sat, 15 Oct 2016 23:10:57 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3] mm: vmalloc: Replace purge_lock spinlock with atomic
 refcount
Message-ID: <20161016061057.GA26990@infradead.org>
References: <1476535979-27467-1-git-send-email-joelaf@google.com>
 <20161015164613.GA26079@infradead.org>
 <20161015165405.GA31568@infradead.org>
 <CAJWu+opcYnvYXwLcOz49u9N7ZFpsLaqzccG7MZV2w85pgsR0Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJWu+opcYnvYXwLcOz49u9N7ZFpsLaqzccG7MZV2w85pgsR0Bw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Sat, Oct 15, 2016 at 03:59:34PM -0700, Joel Fernandes wrote:
> Your patch changes the behavior of the original code I think.

It does.  And it does so as I don't think the existing behavior makes
sense, as mentioned in the changelog.

> With the
> patch, for the case where you have 2 concurrent tasks executing
> alloc_vmap_area function, say both hit the overflow label and enter
> the __purge_vmap_area_lazy at the same time. The first task empties
> the purge list and sets nr to the total number of pages of all the
> vmap areas in the list. Say the first task has just emptied the list
> but hasn't started freeing the vmap areas and is preempted at this
> point. Now the second task runs and since the purge list is empty, the
> second task doesn't have anything to do and immediately returns to
> alloc_vmap_area. Once it returns, it sets purged to 1 in
> alloc_vmap_area and retries. Say it hits overflow label again in the
> retry path. Now because purged was set to 1, it goes to err_free.
> Without your patch, it would have waited on the spin_lock (sync = 1)
> instead of just erroring out, so your patch does change the behavior
> of the original code by not using the purge_lock. I realize my patch
> also changes the behavior, but in mine I think we can make it behave
> like the original code by spinning until purging=0 (if sync = 1)
> because I still have the purging variable..

But for sync = 1 you don't spin on it in any way.  This is the logic
in your patch:

	if (!sync && !force_flush) {
		if (atomic_cmpxchg(&purging, 0, 1))
			return;
	} else
		atomic_inc(&purging);

So when called from free_vmap_area_noflush your skip the whole call
if anyone else is currently purging the list, but all other cases
we will always execute the code.  So maybe my mistake with to follow
what your patch did as I just jumped onto it for seeing this atomic_t
"synchronization", but the change in behavior to your is very limited,
basically the only difference is that if free_vmap_area_noflush hits
the purge cases due to having lots of lazy pages on the purge list
it will execute despite some other purge being in progress.

> You should add a cond_resched_lock here as Chris Wilson suggested. I
> tried your patch both with and without cond_resched_lock in this loop,
> and without it I see the same problems my patch solves (high latencies
> on cyclic test). With cond_resched_lock, your patch does solve my
> problem although as I was worried above - that it changes the original
> behavior.

Yes, I actually pointed that out to "zhouxianrong", who sent a patch
just after yours.  I just thought lock breaking is a different aspect
to improving this whole function.  In fact I suspect even my patch
should probably be split up quite a bit more.

> Also, could you share your concerns about use of atomic_t in my patch?
> I believe that since this is not a contented variable, the question of
> lock fairness is not a concern. It is also not a lock really the way
> I'm using it, it just keeps track of how many purges are in progress..

atomic_t doesn't have any acquire/release semantics, and will require
off memory barrier dances to actually get the behavior you intended.
And from looking at the code I can't really see why we even would
want synchronization behavior - for the sort of problems where we
don't want multiple threads to run the same code at the same time
for effiency but not correctness reasons it's usually better to have
batch thresholds and/or splicing into local data structures before
operations.  Both are techniques used in this code, and I'd rather
rely on them and if required improve on them then using very odd
hoc synchronization methods.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

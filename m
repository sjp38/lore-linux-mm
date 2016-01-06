Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id F119E800C7
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 10:56:20 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id wp13so167629432obc.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:56:20 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id v85si34699953oif.102.2016.01.06.07.56.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Jan 2016 07:56:20 -0800 (PST)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 6 Jan 2016 08:56:19 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 8843E3E40048
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 08:56:18 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u06FuI5226083440
	for <linux-mm@kvack.org>; Wed, 6 Jan 2016 08:56:18 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u06FuGYr022845
	for <linux-mm@kvack.org>; Wed, 6 Jan 2016 08:56:18 -0700
Date: Wed, 6 Jan 2016 07:56:21 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [Intel-gfx] [PATCH v2 1/3] drm/i915: Enable lockless lookup of
 request tracking via RCU
Message-ID: <20160106155621.GI3818@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1450869563-23892-1-git-send-email-chris@chris-wilson.co.uk>
 <1450877756-2902-1-git-send-email-chris@chris-wilson.co.uk>
 <20160105145951.GN8076@phenom.ffwll.local>
 <20160105150213.GP6344@twins.programming.kicks-ass.net>
 <20160105150648.GT6373@twins.programming.kicks-ass.net>
 <20160105163537.GL32217@linux.vnet.ibm.com>
 <20160106080658.GC8076@phenom.ffwll.local>
 <20160106083830.GT6344@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160106083830.GT6344@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Jens Axboe <jens.axboe@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Jan 06, 2016 at 09:38:30AM +0100, Peter Zijlstra wrote:
> On Wed, Jan 06, 2016 at 09:06:58AM +0100, Daniel Vetter wrote:
> > This pretty much went over my head ;-) What I naively hoped for is that
> > kfree() on an rcu-freeing slab could be tought to magically stall a bit
> > (or at least expedite the delayed freeing) if we're piling up too many
> > freed objects.
> 
> Well, RCU does try harder when the callback list is getting 'big' (10k
> IIRC).

You got it, 10k by default, can be adjusted with the rcutree.qhimark
kernel-boot/sysfs parameter.  When a given CPU's callback list exceeds
this limit, it more aggressively starts a grace period, and if a grace
period is already in progress, it does more aggressive quiescent-state
forcing.  It does nothing to push back on processes generating callbacks,
other than by soaking up extra CPU cycles.

So, Daniel, if you haven't tried hammering the system hard, give it a
shot and see if qhimark is helping enough.  And perhaps adjust its value
if need be.  (Though please let me know if this is necessary -- if it is,
we should try to automate its setting.)

> > Doing that only in OOM is probably too late since OOM
> > handling is a bit unreliable/unpredictable. And I thought we're not the
> > first ones running into this problem.
> 
> The whole memory pressure thing is unreliable/unpredictable last time I
> looked at it, but sure, I suppose we could try and poke RCU sooner, but
> then you get into the problem of when, doing it too soon will be
> detrimental to performance, doing it too late is, well, too late.
> 
> > Do all the other users of rcu-freed slabs just open-code their own custom
> > approach? If that's the recommendation we can certainly follow that, too.
> 
> The ones I know of seem to simply ignore this problem..

I believe that there are a few that do the occasional synchronize_rcu()
to throttle themselves, but have not checked recently.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

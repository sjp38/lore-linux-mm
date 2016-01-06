Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 31A4C6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 03:38:36 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id u188so51779428wmu.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 00:38:36 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id z132si11025111wme.43.2016.01.06.00.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 00:38:34 -0800 (PST)
Date: Wed, 6 Jan 2016 09:38:30 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [Intel-gfx] [PATCH v2 1/3] drm/i915: Enable lockless lookup of
 request tracking via RCU
Message-ID: <20160106083830.GT6344@twins.programming.kicks-ass.net>
References: <1450869563-23892-1-git-send-email-chris@chris-wilson.co.uk>
 <1450877756-2902-1-git-send-email-chris@chris-wilson.co.uk>
 <20160105145951.GN8076@phenom.ffwll.local>
 <20160105150213.GP6344@twins.programming.kicks-ass.net>
 <20160105150648.GT6373@twins.programming.kicks-ass.net>
 <20160105163537.GL32217@linux.vnet.ibm.com>
 <20160106080658.GC8076@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160106080658.GC8076@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Jens Axboe <jens.axboe@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Jan 06, 2016 at 09:06:58AM +0100, Daniel Vetter wrote:
> This pretty much went over my head ;-) What I naively hoped for is that
> kfree() on an rcu-freeing slab could be tought to magically stall a bit
> (or at least expedite the delayed freeing) if we're piling up too many
> freed objects.

Well, RCU does try harder when the callback list is getting 'big' (10k
IIRC).

> Doing that only in OOM is probably too late since OOM
> handling is a bit unreliable/unpredictable. And I thought we're not the
> first ones running into this problem.

The whole memory pressure thing is unreliable/unpredictable last time I
looked at it, but sure, I suppose we could try and poke RCU sooner, but
then you get into the problem of when, doing it too soon will be
detrimental to performance, doing it too late is, well, too late.

> Do all the other users of rcu-freed slabs just open-code their own custom
> approach? If that's the recommendation we can certainly follow that, too.

The ones I know of seem to simply ignore this problem..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

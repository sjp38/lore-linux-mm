Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE72800C7
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:06:58 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id cy9so216494311pac.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:06:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 86si10624208pfo.28.2016.01.05.07.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 07:06:57 -0800 (PST)
Date: Tue, 5 Jan 2016 16:06:48 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [Intel-gfx] [PATCH v2 1/3] drm/i915: Enable lockless lookup of
 request tracking via RCU
Message-ID: <20160105150648.GT6373@twins.programming.kicks-ass.net>
References: <1450869563-23892-1-git-send-email-chris@chris-wilson.co.uk>
 <1450877756-2902-1-git-send-email-chris@chris-wilson.co.uk>
 <20160105145951.GN8076@phenom.ffwll.local>
 <20160105150213.GP6344@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105150213.GP6344@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Jens Axboe <jens.axboe@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, Jan 05, 2016 at 04:02:13PM +0100, Peter Zijlstra wrote:
> > Shouldn't the slab subsystem do this for us if we request it delays the
> > actual kfree? Seems like a core bug to me ... Adding more folks.
> 
> note that sync_rcu() can take a terribly long time.. but yes, I seem to
> remember Paul talking about adding this to reclaim paths for just this
> reason. Not sure that ever happened thouhg.

Also, you might be wanting rcu_barrier() instead, that not only waits
for a GP to complete, but also for all pending callbacks to be
processed.

Without the latter there might still not be anything to free after it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

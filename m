Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 24BC96B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 18:28:12 -0400 (EDT)
Received: by iagk10 with SMTP id k10so5034188iag.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2012 15:28:11 -0700 (PDT)
Date: Thu, 30 Aug 2012 15:28:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: consider pfmemalloc_match() in
 get_partial_node()
In-Reply-To: <1345831202-4225-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1208301527510.14189@chino.kir.corp.google.com>
References: <1345831202-4225-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 25 Aug 2012, Joonsoo Kim wrote:

> There is no consideration for pfmemalloc_match() in get_partial(). If we don't
> consider that, we can't restrict access to PFMEMALLOC page mostly.
> 
> We may encounter following scenario.
> 
> Assume there is a request from normal allocation
> and there is no objects in per cpu cache and no node partial slab.
> 
> In this case, slab_alloc go into slow-path and
> new_slab_objects() is invoked. It may return PFMEMALLOC page.
> Current user is not allowed to access PFMEMALLOC page,
> deactivate_slab() is called (commit 5091b74a95d447e34530e713a8971450a45498b3),
> then return object from PFMEMALLOC page.
> 
> Next time, when we meet another request from normal allocation,
> slab_alloc() go into slow-path and re-go new_slab_objects().
> In new_slab_objects(), we invoke get_partial() and we get a partial slab
> which we have been deactivated just before, that is, PFMEMALLOC page.
> We extract one object from it and re-deactivate.
> 
> "deactivate -> re-get in get_partial -> re-deactivate" occures repeatedly.
> 
> As a result, we can't restrict access to PFMEMALLOC page and
> moreover, it introduce much performance degration to normal allocation
> because of deactivation frequently.
> 
> Now, we need to consider pfmemalloc_match() in get_partial_node()
> It prevent "deactivate -> re-get in get_partial".
> Instead, new_slab() is called. It may return !PFMEMALLOC page,
> so above situation will be suspended sometime.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Mike Christie <michaelc@cs.wisc.edu>
> Cc: Eric B Munson <emunson@mgebm.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD939000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 06:28:08 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1488638fxm.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 03:28:05 -0700 (PDT)
Date: Wed, 27 Apr 2011 12:28:01 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110427102801.GF31015@htj.dyndns.org>
References: <20110421145837.GB22898@htj.dyndns.org>
 <alpine.DEB.2.00.1104211243350.5741@router.home>
 <20110421180159.GF15988@htj.dyndns.org>
 <alpine.DEB.2.00.1104211308300.5741@router.home>
 <20110421183727.GG15988@htj.dyndns.org>
 <alpine.DEB.2.00.1104211350310.5741@router.home>
 <20110421190807.GK15988@htj.dyndns.org>
 <1303439580.3981.241.camel@sli10-conroe>
 <20110426121011.GD878@htj.dyndns.org>
 <alpine.LSU.2.00.1104261140010.9169@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1104261140010.9169@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello, Hugh.

On Tue, Apr 26, 2011 at 12:02:15PM -0700, Hugh Dickins wrote:
> This worried me a little when the percpu block counting went into tmpfs,
> though it's not really critical there.
> 
> Would it be feasible, with these counters that are used against limits,
> to have an adaptive batching scheme such that the batches get smaller
> and smaller, down to 1 and to 0, as the total approaches the limit?
> (Of course a single global percpu_counter_batch won't do for this.)
> 
> Perhaps it's a demonstrable logical impossibility, perhaps it would
> slow down the fast (far from limit) path more than we can afford,
> perhaps I haven't read enough of this thread and I'm taking it
> off-topic.  Forgive me if so.

Hmmm... it seems like what you're suggesting is basically a simple
per-cpu slot allocator.

* The global counter is initialized with predefined number of slots
  and per-cpu buffers start at zero (or with initial chunks).

* Allocation first consults per-cpu buffer and if enough slots are
  there, they're consumed.  If not, global counter is accessed and
  some portion of it is transferred to per-cpu buffer and allocation
  is retried.  The amount transferred is adjusted according to the
  amount of slots available in the global pool.

* Free populates the per-cpu buffer.  If it meets certain criteria,
  part of the buffer is returned to the global pool.

The principles are easy but as with any per-cpu allocation scheme
balancing and reclaiming would be the complex part.  ie. What to do
when the global and some per-cpu buffers are draining while a few
still have some left.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

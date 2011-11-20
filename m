Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9607D6B0070
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 18:30:26 -0500 (EST)
Received: by iaek3 with SMTP id k3so8682925iae.14
        for <linux-mm@kvack.org>; Sun, 20 Nov 2011 15:30:24 -0800 (PST)
Date: Sun, 20 Nov 2011 15:30:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc 00/18] slub: irqless/lockless slow allocation paths
In-Reply-To: <20111111200711.156817886@linux.com>
Message-ID: <alpine.DEB.2.00.1111201529100.30815@chino.kir.corp.google.com>
References: <20111111200711.156817886@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, 11 Nov 2011, Christoph Lameter wrote:

> This is a patchset that makes the allocator slow path also lockless like
> the free paths. However, in the process it is making processing more
> complex so that this is not a performance improvement. I am going to
> drop this series unless someone comes up with a bright idea to fix the
> following performance issues:
> 
> 1. Had to reduce the per cpu state kept to two words in order to
>    be able to operate without preempt disable / interrupt disable only
>    through cmpxchg_double(). This means that the node information and
>    the page struct location have to be calculated from the free pointer.
>    That is possible but relatively expensive and has to be done frequently
>    in fast paths.
> 
> 2. If the freepointer becomes NULL then the page struct location can
>    no longer be determined. So per cpu slabs must be deactivated when
>    the last object is retrieved from them causing more regressions.
> 
> If these issues remain unresolved then I am fine with the way things are
> right now in slub. Currently interrupts are disabled in the slow paths and
> then multiple fields in the kmem_cache_cpu structure are modified without
> regard to instruction atomicity.
> 

I think patches 1-7 should be proposed as a separate set of cleanups that 
are an overall improvement to the slub code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

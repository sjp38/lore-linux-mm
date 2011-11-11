Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 32B0D6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:27 -0500 (EST)
Message-Id: <20111111200711.156817886@linux.com>
Date: Fri, 11 Nov 2011 14:07:11 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 00/18] slub: irqless/lockless slow allocation paths
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

This is a patchset that makes the allocator slow path also lockless like
the free paths. However, in the process it is making processing more
complex so that this is not a performance improvement. I am going to
drop this series unless someone comes up with a bright idea to fix the
following performance issues:

1. Had to reduce the per cpu state kept to two words in order to
   be able to operate without preempt disable / interrupt disable only
   through cmpxchg_double(). This means that the node information and
   the page struct location have to be calculated from the free pointer.
   That is possible but relatively expensive and has to be done frequently
   in fast paths.

2. If the freepointer becomes NULL then the page struct location can
   no longer be determined. So per cpu slabs must be deactivated when
   the last object is retrieved from them causing more regressions.

If these issues remain unresolved then I am fine with the way things are
right now in slub. Currently interrupts are disabled in the slow paths and
then multiple fields in the kmem_cache_cpu structure are modified without
regard to instruction atomicity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

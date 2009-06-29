Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 32D416B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 18:29:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 26CCB82C49B
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 18:48:20 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2Uf6Zj6QNGgU for <linux-mm@kvack.org>;
	Mon, 29 Jun 2009 18:48:20 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A489682C49F
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 18:48:14 -0400 (EDT)
Date: Mon, 29 Jun 2009 18:30:12 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem
 in sl[aou]b
In-Reply-To: <20090625193137.GA16861@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.1.10.0906291827050.21956@gentwo.org>
References: <20090625193137.GA16861@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 2009, Paul E. McKenney wrote:

> Jesper noted that kmem_cache_destroy() invokes synchronize_rcu() rather
> than rcu_barrier() in the SLAB_DESTROY_BY_RCU case, which could result
> in RCU callbacks accessing a kmem_cache after it had been destroyed.
>
> The following untested (might not even compile) patch proposes a fix.

It could be seen to be the responsibility of the caller of
kmem_cache_destroy to insure that no accesses are pending.

If the caller specified destroy by rcu on cache creation then he also
needs to be aware of not destroying the cache itself until all rcu actions
are complete. This is similar to the caution that has to be execised then
accessing cache data itself.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFA26B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 18:44:46 -0400 (EDT)
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem
 in sl[aou]b
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.1.10.0906291827050.21956@gentwo.org>
References: <20090625193137.GA16861@linux.vnet.ibm.com>
	 <alpine.DEB.1.10.0906291827050.21956@gentwo.org>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 17:45:53 -0500
Message-Id: <1246315553.21295.100.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-29 at 18:30 -0400, Christoph Lameter wrote:
> On Thu, 25 Jun 2009, Paul E. McKenney wrote:
> 
> > Jesper noted that kmem_cache_destroy() invokes synchronize_rcu() rather
> > than rcu_barrier() in the SLAB_DESTROY_BY_RCU case, which could result
> > in RCU callbacks accessing a kmem_cache after it had been destroyed.
> >
> > The following untested (might not even compile) patch proposes a fix.
> 
> It could be seen to be the responsibility of the caller of
> kmem_cache_destroy to insure that no accesses are pending.
> 
> If the caller specified destroy by rcu on cache creation then he also
> needs to be aware of not destroying the cache itself until all rcu actions
> are complete. This is similar to the caution that has to be execised then
> accessing cache data itself.

This is a reasonable point, and in keeping with the design principle
'callers should handle their own special cases'. However, I think it
would be more than a little surprising for kmem_cache_free() to do the
right thing, but not kmem_cache_destroy().

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

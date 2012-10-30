Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id DB1766B0072
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 18:48:51 -0400 (EDT)
Message-ID: <5090594E.7050401@cesarb.net>
Date: Tue, 30 Oct 2012 20:48:46 -0200
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: refactor reinsert of swap_info in sys_swapoff
References: <1351372847-13625-1-git-send-email-cesarb@cesarb.net> <1351372847-13625-2-git-send-email-cesarb@cesarb.net> <20121030140417.988c2437.akpm@linux-foundation.org>
In-Reply-To: <20121030140417.988c2437.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Em 30-10-2012 19:04, Andrew Morton escreveu:
> Your patch doesn't change this, but...  it is very unusual for any
> subsystem's ->init method to be called under a spinlock.  Because it is
> highly likely that such a method will wish to do things such as memory
> allocation.
>
> It is rare and unlikely for an ->init() method to *need* such external
> locking, because all the objects it is dealing with cannot be looked up
> by other threads because nothing has been registered anywhere yet.

The frontswap_init() method is being passed the swap_info_struct's 
->type, which it uses to get back the swap_info_struct itself, which it 
then uses to check if the frontswap_map allocation succeeded. As noted 
by the commit message for commit 38b5faf (mm: frontswap: core swap 
subsystem hooks and headers), that allocation can fail, which will do 
nothing more than not enable frontswap for that swap area.

The same parameter is then passed down to the ->init() method, which 
proceeds to sumarily ignore it on the three in-tree implementations I 
looked at.

Yeah, it looks like a violation of YAGNI to me, and doing things in a 
more roundabount way than is justified. Why pass the ->type and then get 
the pointer from it instead of just passing the pointer in the first 
place? Or better yet, why not pass the frontswap_map pointer? Even 
better, why not a boolean saying whether it worked? Even better, *why 
not just put the conditional inside enable_swap_info* and pass no 
parameter at all?

> So either frontswap is doing something wrong here or there's some
> subtlety which escapes me.  If the former then we should try to get
> that ->init call to happen outside swap_lock.

I believe the swap_lock is protecting the poolid. It is possible that 
other things in the frontswap code are being called before the first 
swapon with a successful frontswap_map allocation (which is when the 
poolid would get allocated).

A quick look suggests the poolid only gets set on an initcall or in the 
->init() method; perhaps a local mutex (to prevent double allocation) 
and an atomic update of the poolid would be enough to move it outside 
the lock (and also outside the swapon_mutex).

But that would work only if no out-of-tree frontswap module needs it 
within the swap_lock.

> And if we can do that, perhaps we can fix the regrettable GFP_ATOMIC
> in zcache_new_pool().


-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

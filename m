Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 8FCD16B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 09:05:30 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id j10so4868511qcx.11
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 06:05:29 -0700 (PDT)
Date: Wed, 14 Aug 2013 09:05:26 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
Message-ID: <20130814130526.GA28628@htj.dyndns.org>
References: <520AAF9C.1050702@tilera.com>
 <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com>
 <20130813232904.GJ28996@mtj.dyndns.org>
 <520AC215.4050803@tilera.com>
 <20130813234629.4ce2ec70.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130813234629.4ce2ec70.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello,

On Tue, Aug 13, 2013 at 11:46:29PM -0700, Andrew Morton wrote:
> What does "nest" mean?  lru_add_drain_all() calls itself recursively,
> presumably via some ghastly alloc_percpu()->alloc_pages(GFP_KERNEL)
> route?  If that ever happens then we'd certainly want to know about it.
> Hopefully PF_MEMALLOC would prevent infinite recursion.
> 
> If "nest" means something else then please enlighten me!
> 
> As for "doing it simultaneously", I assume we're referring to
> concurrent execution from separate threads.  If so, why would that "buy
> us anything"?  Confused.  As long as each thread sees "all pages which
> were in pagevecs at the time I called lru_add_drain_all() get spilled
> onto the LRU" then we're good.  afaict the implementation will do this.

I was wondering whether we can avoid all allocations by just
pre-allocating all resources.  If it can't call itself if we get rid
of all allocations && running multiple instances of them doesn't buy
us anything, the best solution would be allocating work items
statically and synchronize their use using a mutex.  That way the
whole thing wouldn't need any allocation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

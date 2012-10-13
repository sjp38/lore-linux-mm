Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id C74C56B002B
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 11:10:25 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so428786wib.2
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 08:10:24 -0700 (PDT)
Subject: Re: [Q] Default SLAB allocator
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
References: 
	 <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	 <m27gqwtyu9.fsf@firstfloor.org>
	 <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	 <m2391ktxjj.fsf@firstfloor.org>
	 <alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 13 Oct 2012 17:10:21 +0200
Message-ID: <1350141021.21172.14949.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Sat, 2012-10-13 at 02:51 -0700, David Rientjes wrote:
> On Thu, 11 Oct 2012, Andi Kleen wrote:
> 
> > When did you last test? Our regressions had disappeared a few kernels
> > ago.
> > 
> 
> This was in August when preparing for LinuxCon, I tested netperf TCP_RR on 
> two 64GB machines (one client, one server), four nodes each, with thread 
> counts in multiples of the number of cores.  SLUB does a comparable job, 
> but once we have the the number of threads equal to three times the number 
> of cores, it degrades almost linearly.  I'll run it again next week and 
> get some numbers on 3.6.

In latest kernels, skb->head no longer use kmalloc()/kfree(), so SLAB vs
SLUB is less a concern for network loads.

In 3.7, (commit 69b08f62e17) we use fragments of order-3 pages to
populate skb->head.

SLUB was really bad in the common workload you describe (allocations
done by one cpu, freeing done by other cpus), because all kfree() hit
the slow path and cpus contend in __slab_free() in the loop guarded by
cmpxchg_double_slab(). SLAB has a cache for this, while SLUB directly
hit the main "struct page" to add the freed object to freelist.

I played some months ago adding a percpu associative cache to SLUB, then
just moved on other strategy.

(Idea for this per cpu cache was to build a temporary free list of
objects to batch accesses to struct page)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

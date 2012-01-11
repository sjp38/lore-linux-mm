Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 664146B006E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 02:05:19 -0500 (EST)
From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH v6 6/8] fs: only send IPI to invalidate LRU BH when needed
In-Reply-To: <1326040026-7285-7-git-send-email-gilad@benyossef.com>
References: <1326040026-7285-7-git-send-email-gilad@benyossef.com>
Date: Wed, 11 Jan 2012 01:04:14 -0600
Message-ID: <1326265454_1663@mail4.comsite.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Sun Jan 08 2012 about 11:28:17 EST, Gilad Ben-Yossef wrote:
> In several code paths, such as when unmounting a file system (but
> not only) we send an IPI to ask each cpu to invalidate its local
> LRU BHs.
> 
> For multi-cores systems that have many cpus that may not have
For multi-core systems that have many cpus, many may not have

> any LRU BH because they are idle or because they have no performed

not performed

> any file system access since last invalidation (e.g. CPU crunching

accesses

> on high perfomance computing nodes that write results to shared
> memory) this can lead to loss of performance each time someone

memory).  This can lead to a loss

Also: or only using filesystems that do not use the bh layer.


> switches KVM (the virtual keyboard and screen type, not the

switches the KVM 

> hypervisor) that has a USB storage stuck in.

if it has

> 
> This patch attempts to only send the IPI to cpus that have LRU BH.

send an IPI

> +
> +static int local_bh_lru_avail(int cpu, void *dummy)
> +{

This is not about the availibilty of the lru, but rather the
decision if it is empty.  How about has_bh_in_lru() ?

> + struct bh_lru *b = per_cpu_ptr(&bh_lrus, cpu);
> + int i;
> 
> + for (i = 0; i < BH_LRU_SIZE; i++) {
> + if (b->bhs[i])
> + return 1;
> + }


If we change the loop in invalidate_bh to be end to beginning, then we
could get by only checking b->bhs[0] instead of all BH_LRU_SIZE words.
(The other loops all start by having entry 0 as a valid entry and pushing
towards higher slots as they age.)  We might say we don't care, but I
think we need to know if another cpu is still invalidating in case it
gets stuck in brelse, we need to wait for all the invalidates to occur
before we can continue to kill the device.

The other question is locking, what covers the window from getting
the bh until it is installed if the lru was empty?  It looks like
it could be a large hole, but I'm not sure it wasn't there before.
By when do we need them freed?  The locking seems to be irq-disable
for smp and preempt-disable for up, can we use an RCU grace period?

There seem to be more on_each_cpu calls in the bdev invalidate
so we need more patches, although each round trip though ipi
takes time; we could also consider if they take time.

> +
> + return 0;
> +}
> +
> void invalidate_bh_lrus(void)
> {
> - on_each_cpu(invalidate_bh_lru, NULL, 1);
> + on_each_cpu_cond(local_bh_lru_avail, invalidate_bh_lru, NULL, 1);
> }
> EXPORT_SYMBOL_GPL(invalidate_bh_lrus);

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

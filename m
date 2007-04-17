Date: Tue, 17 Apr 2007 17:02:46 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M
In-Reply-To: <4624D0C1.4090304@sw.ru>
Message-ID: <Pine.LNX.4.64.0704171653420.22366@sbz-30.cs.Helsinki.FI>
References: <4624C3C1.9040709@sw.ru> <84144f020704170622h2b16f0f6m47ffdbb3b5686758@mail.gmail.com>
 <4624D0C1.4090304@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@sw.ru>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

At some point in time, I wrote:
> > So, now we have two locks protecting cache_chain? Please explain why
> > you can't use the mutex.

On Tue, 17 Apr 2007, Pavel Emelianov wrote:
> Because OOM can actually happen with this mutex locked. For example
> kmem_cache_create() locks it and calls kmalloc(), or write to
> /proc/slabinfo also locks it and calls do_tune_cpu_caches(). This is
> very rare case and the deadlock is VERY unlikely to happen, but it
> will be very disappointing if it happens.
> 
> Moreover, I put the call to show_slabs() into sysrq handler, so it may
> be called from atomic context.
> 
> Making mutex_trylock() is possible, but we risk of loosing this info
> in case OOM happens while the mutex is locked for cache shrinking (see
> cache_reap() for example)...
> 
> So we have a choice - either we have an additional lock on a slow and
> rare paths and show this info for sure, or we do not have a lock, but
> have a risk of loosing this info.

I don't worry about performance as much I do about maintenance. Do you 
know if mutex_trylock() is a problem in practice? Could we perhaps fix 
the worst offenders who are holding cache_chain_mutex for a long time?

In any case, if we do end up adding the lock, please add a BIG FAT COMMENT 
explaining why we have it.

At some point in time, I wrote:
> > I would also drop the OFF_SLAB bits because it really doesn't matter
> > that much for your purposes. Besides, you're already per-node and
> > per-CPU caches here which attribute to much more memory on NUMA setups
> > for example.
 
On Tue, 17 Apr 2007, Pavel Emelianov wrote:
> This gives us a more precise information :) The precision is less than 1%
> so if nobody likes/needs it, this may be dropped.

My point is that the "precision" is useless here. We probably waste more 
memory in the caches which are not accounted here. So I'd just drop it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 752006B0047
	for <linux-mm@kvack.org>; Sun,  7 Mar 2010 20:52:50 -0500 (EST)
Date: Mon, 8 Mar 2010 10:44:47 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure
Message-Id: <20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1267995474-9117-4-git-send-email-arighi@develer.com>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-4-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> +/*
> + * mem_cgroup_update_page_stat_locked() - update memcg file cache's accounting
> + * @page:	the page involved in a file cache operation.
> + * @idx:	the particular file cache statistic.
> + * @charge:	true to increment, false to decrement the statistic specified
> + *		by @idx.
> + *
> + * Update memory cgroup file cache's accounting from a locked context.
> + *
> + * NOTE: must be called with mapping->tree_lock held.
> + */
> +void mem_cgroup_update_page_stat_locked(struct page *page,
> +			enum mem_cgroup_write_page_stat_item idx, bool charge)
> +{
> +	struct address_space *mapping = page_mapping(page);
> +	struct page_cgroup *pc;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +	WARN_ON_ONCE(!irqs_disabled());
> +	WARN_ON_ONCE(mapping && !spin_is_locked(&mapping->tree_lock));
> +
I think this is a wrong place to insert assertion.
The problem about page cgroup lock is that it can be interrupted in current implementation.
So,

a) it must not be aquired under another lock which can be aquired in interrupt context,
   such as mapping->tree_lock, to avoid:

		context1			context2
					lock_page_cgroup(pcA)
	spin_lock_irq(&tree_lock)
		lock_page_cgroup(pcA)		<interrupted>
		=>fail				spin_lock_irqsave(&tree_lock)
						=>fail

b) it must not be aquired in interrupt context to avoid:

	lock_page_cgroup(pcA)
		<interrupted>
		lock_page_cgroup(pcA)
		=>fail

I think something like this would be better:

@@ -83,8 +83,14 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
        return page_zonenum(pc->page);
 }

+#include <linux/irqflags.h>
+#include <linux/hardirq.h>
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
+#ifdef CONFIG_DEBUG_VM
+       WARN_ON_ONCE(irqs_disabled());
+       WARN_ON_ONCE(in_interrupt());
+#endif
        bit_spin_lock(PCG_LOCK, &pc->flags);
 }

> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!pc) || !PageCgroupUsed(pc))
> +		return;
> +	mem_cgroup_update_page_stat(pc, idx, charge);
> +}
> +EXPORT_SYMBOL_GPL(mem_cgroup_update_page_stat_locked);
> +
> +/*
> + * mem_cgroup_update_page_stat_unlocked() - update memcg file cache's accounting
> + * @page:	the page involved in a file cache operation.
> + * @idx:	the particular file cache statistic.
> + * @charge:	true to increment, false to decrement the statistic specified
> + *		by @idx.
> + *
> + * Update memory cgroup file cache's accounting from an unlocked context.
> + */
> +void mem_cgroup_update_page_stat_unlocked(struct page *page,
> +			enum mem_cgroup_write_page_stat_item idx, bool charge)
> +{
> +	struct page_cgroup *pc;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!pc) || !PageCgroupUsed(pc))
> +		return;
> +	lock_page_cgroup(pc);
> +	mem_cgroup_update_page_stat(pc, idx, charge);
>  	unlock_page_cgroup(pc);
>  }
> +EXPORT_SYMBOL_GPL(mem_cgroup_update_page_stat_unlocked);
>  
IIUC, test_clear_page_writeback(at least) can be called under interrupt context.
This means lock_page_cgroup() is called under interrupt context, that is,
the case b) above can happen.
hmm... I don't have any good idea for now except disabling irq around page cgroup lock
to avoid all of these mess things.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 26 Feb 2008 10:48:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/15] memcg: simplify force_empty and move_lists
Message-Id: <20080226104834.5bbd7f20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252349100.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252349100.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Claim again ;)
On Mon, 25 Feb 2008 23:50:27 +0000 (GMT)
Hugh Dickins <hugh@veritas.com>, Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> +		get_page(page);
How about this?
> +		spin_unlock_irqrestore(&mz->lru_lock, flags);
		local_irq_save(flags):
		if (TestSetPageLocked(page)) {
	> +		mem_cgroup_uncharge_page(page);
	> +		put_page(page);
	> +		if (--count <= 0) {
	> +			count = FORCE_UNCHARGE_BATCH;
	> +			cond_resched();
	>  		}
	> +		spin_lock_irqsave(&mz->lru_lock, flags);
			unlock_page(page);
		}
		local_irq_restore(flags);

page's lock bit guarantees 100% safe against page migration.
(And most of other charging/uncharging callers.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

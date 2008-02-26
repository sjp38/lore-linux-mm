Date: Tue, 26 Feb 2008 10:30:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 05/15] memcg: fix VM_BUG_ON from page migration
Message-Id: <20080226103049.71aefbbe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252338080.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252338080.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:39:23 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Page migration gave me free_hot_cold_page's VM_BUG_ON page->page_cgroup.
> remove_migration_pte was calling mem_cgroup_charge on the new page whenever
> it found a swap pte, before it had determined it to be a migration entry.
> That left a surplus reference count on the page_cgroup, so it was still
> attached when the page was later freed.
> 
> Move that mem_cgroup_charge down to where we're sure it's a migration entry.
> We were already under i_mmap_lock or anon_vma->lock, so its GFP_KERNEL was
> already inappropriate: change that to GFP_ATOMIC.
> 
> It's essential that remove_migration_pte removes all the migration entries,
> other crashes follow if not.  So proceed even when the charge fails: normally
> it cannot, but after a mem_cgroup_force_empty it might - comment in the code.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---

make sense

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

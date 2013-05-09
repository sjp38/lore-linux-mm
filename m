Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 57BD66B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 18:13:35 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 9 May 2013 18:13:34 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id CDAE138C804D
	for <linux-mm@kvack.org>; Thu,  9 May 2013 18:13:31 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r49MDVgp307434
	for <linux-mm@kvack.org>; Thu, 9 May 2013 18:13:32 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r49MDVjE028816
	for <linux-mm@kvack.org>; Thu, 9 May 2013 19:13:31 -0300
Date: Thu, 9 May 2013 17:13:27 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/7] create __remove_mapping_batch()
Message-ID: <20130509221327.GB14840@cerebellum>
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
 <20130507212001.49F5E197@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130507212001.49F5E197@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Tue, May 07, 2013 at 02:20:01PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> __remove_mapping_batch() does logically the same thing as
> __remove_mapping().
> 
> We batch like this so that several pages can be freed with a
> single mapping->tree_lock acquisition/release pair.  This reduces
> the number of atomic operations and ensures that we do not bounce
> cachelines around.
> 
> It has shown some substantial performance benefits on
> microbenchmarks.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  linux.git-davehans/mm/vmscan.c |   50 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 50 insertions(+)
> 
> diff -puN mm/vmscan.c~create-remove_mapping_batch mm/vmscan.c
> --- linux.git/mm/vmscan.c~create-remove_mapping_batch	2013-05-07 14:00:01.432361260 -0700
> +++ linux.git-davehans/mm/vmscan.c	2013-05-07 14:19:32.341148892 -0700
> @@ -555,6 +555,56 @@ int remove_mapping(struct address_space
>  	return 0;
>  }
> 
> +/*
> + * pages come in here (via remove_list) locked and leave unlocked
> + * (on either ret_pages or free_pages)
> + *
> + * We do this batching so that we free batches of pages with a
> + * single mapping->tree_lock acquisition/release.  This optimization
> + * only makes sense when the pages on remove_list all share a
> + * page->mapping.  If this is violated you will BUG_ON().
> + */
> +static int __remove_mapping_batch(struct list_head *remove_list,
> +				  struct list_head *ret_pages,
> +				  struct list_head *free_pages)
> +{
> +	int nr_reclaimed = 0;
> +	struct address_space *mapping;
> +	struct page *page;
> +	LIST_HEAD(need_free_mapping);
> +
> +	if (list_empty(remove_list))
> +		return 0;
> +
> +	mapping = lru_to_page(remove_list)->mapping;

This doesn't work for pages in the swap cache as mapping is overloaded to
hold... something else that I can't remember of the top of my head.  Anyway,
this happens:

[   70.027984] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
[   70.028010] IP: [<ffffffff81077de8>] __lock_acquire.isra.24+0x188/0xd10
[   70.028010] PGD 1ab99067 PUD 671e5067 PMD 0 
[   70.028010] Oops: 0000 [#1] PREEMPT SMP 
[   70.028010] Modules linked in:
[   70.028010] CPU: 1 PID: 11494 Comm: cc1 Not tainted 3.9.0+ #6
[   70.028010] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   70.028010] task: ffff88007c708f70 ti: ffff88001aa28000 task.ti: ffff88001aa28000
[   70.028010] RIP: 0010:[<ffffffff81077de8>]  [<ffffffff81077de8>] __lock_acquire.isra.24+0x188/0xd10
[   70.028010] RSP: 0000:ffff88001aa29658  EFLAGS: 00010097
[   70.028010] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
[   70.028010] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[   70.028010] RBP: ffff88001aa296c8 R08: 0000000000000001 R09: 0000000000000000
[   70.028010] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007c708f70
[   70.028010] R13: 0000000000000001 R14: 0000000000000030 R15: ffff88001aa29758
[   70.028010] FS:  00007fe676f32700(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
[   70.028010] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   70.028010] CR2: 0000000000000038 CR3: 000000001b7ba000 CR4: 00000000000006a0
[   70.028010] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   70.028010] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   70.028010] Stack:
[   70.028010]  0000000000000001 ffffffff8165d910 ffff88001aa296e8 ffffffff8107e925
[   70.028010]  ffff88001aa296a8 0000000000000000 0000000000000002 0000000000000046
[   70.028010]  dead000000200200 ffff88007c708f70 0000000000000046 0000000000000000
[   70.028010] Call Trace:
[   70.028010]  [<ffffffff8107e925>] ? smp_call_function_single+0xd5/0x180
[   70.028010]  [<ffffffff81078ea2>] lock_acquire+0x52/0x70
[   70.028010]  [<ffffffff810b7468>] ? __remove_mapping_batch+0x48/0x140
[   70.028010]  [<ffffffff813b3cf7>] _raw_spin_lock_irq+0x37/0x50
[   70.028010]  [<ffffffff810b7468>] ? __remove_mapping_batch+0x48/0x140
[   70.028010]  [<ffffffff810b7468>] __remove_mapping_batch+0x48/0x140
[   70.028010]  [<ffffffff810b88b0>] shrink_page_list+0x680/0x9f0
[   70.028010]  [<ffffffff810b910f>] shrink_inactive_list+0x13f/0x380
[   70.028010]  [<ffffffff810b9590>] shrink_lruvec+0x240/0x4e0
[   70.028010]  [<ffffffff810b9896>] shrink_zone+0x66/0x1a0
[   70.028010]  [<ffffffff810ba43b>] do_try_to_free_pages+0xeb/0x570
[   70.028010]  [<ffffffff810eba29>] ? lookup_page_cgroup_used+0x9/0x20
[   70.028010]  [<ffffffff810ba9ef>] try_to_free_pages+0x9f/0xc0
[   70.028010]  [<ffffffff810b1357>] __alloc_pages_nodemask+0x5a7/0x970
[   70.028010]  [<ffffffff810cb4fe>] handle_pte_fault+0x65e/0x880
[   70.028010]  [<ffffffff810cca19>] handle_mm_fault+0x139/0x1e0
[   70.028010]  [<ffffffff81027920>] __do_page_fault+0x160/0x460
[   70.028010]  [<ffffffff811121f1>] ? mntput+0x21/0x30
[   70.028010]  [<ffffffff810f56c1>] ? __fput+0x191/0x250
[   70.028010]  [<ffffffff81212bc9>] ? lockdep_sys_exit_thunk+0x35/0x67
[   70.028010]  [<ffffffff81027c49>] do_page_fault+0x9/0x10
[   70.028010]  [<ffffffff813b4cb2>] page_fault+0x22/0x30
[   70.028010] Code: 48 c7 c1 65 1b 50 81 48 c7 c2 3d 07 50 81 31 c0 be fb 0b 00 00 48 c7 c7 a8 58 50 81 e8 62 89 fb ff e9 d7 01 00 00 0f 1f 44 00 00 <4d> 8b 6c c6 08 4d 85 ed 0f 84 cc fe ff ff f0 41 ff 85 98 01 00 
[   70.028010] RIP  [<ffffffff81077de8>] __lock_acquire.isra.24+0x188/0xd10
[   70.028010]  RSP <ffff88001aa29658>
[   70.028010] CR2: 0000000000000038
[   70.028010] ---[ end trace 94be6276375f6199 ]---

The solution is to use page_mapping() which has logic to handle swap cache page
mapping.

I got by it with:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 43b4da8..897eb5f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -576,13 +576,15 @@ static int __remove_mapping_batch(struct list_head *remove_list,
        if (list_empty(remove_list))
                return 0;
 
-       mapping = lru_to_page(remove_list)->mapping;
+       page = lru_to_page(remove_list);
+       mapping = page_mapping(page);
+       BUG_ON(mapping == NULL);
        spin_lock_irq(&mapping->tree_lock);
        while (!list_empty(remove_list)) {
                int freed;
                page = lru_to_page(remove_list);
                BUG_ON(!PageLocked(page));
-               BUG_ON(page->mapping != mapping);
+               BUG_ON(page_mapping(page) != mapping);
                list_del(&page->lru);
 
                freed = __remove_mapping_nolock(mapping, page);

Seth

> +	spin_lock_irq(&mapping->tree_lock);
> +	while (!list_empty(remove_list)) {
> +		int freed;
> +		page = lru_to_page(remove_list);
> +		BUG_ON(!PageLocked(page));
> +		BUG_ON(page->mapping != mapping);
> +		list_del(&page->lru);
> +
> +		freed = __remove_mapping_nolock(mapping, page);
> +		if (freed) {
> +			list_add(&page->lru, &need_free_mapping);
> +		} else {
> +			unlock_page(page);
> +			list_add(&page->lru, ret_pages);
> +		}
> +	}
> +	spin_unlock_irq(&mapping->tree_lock);
> +
> +	while (!list_empty(&need_free_mapping)) {
> +		page = lru_to_page(&need_free_mapping);
> +		list_move(&page->list, free_pages);
> +		free_mapping_page(mapping, page);
> +		unlock_page(page);
> +		nr_reclaimed++;
> +	}
> +	return nr_reclaimed;
> +}
> +
>  /**
>   * putback_lru_page - put previously isolated page onto appropriate LRU list
>   * @page: page to be put back to appropriate lru list
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

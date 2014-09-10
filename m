Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id E79AE6B0070
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:06:39 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id q9so3153903ykb.39
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:06:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b35si12875033yha.9.2014.09.10.12.06.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 12:06:39 -0700 (PDT)
Message-ID: <5410A118.9080803@oracle.com>
Date: Wed, 10 Sep 2014 15:06:00 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com> <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <20140910124732.GT17501@suse.de>
In-Reply-To: <20140910124732.GT17501@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 09/10/2014 08:47 AM, Mel Gorman wrote:
> migrate: debug patch to try identify race between migration completion and mprotect
> 
> A migration entry is marked as write if pte_write was true at the
> time the entry was created. The VMA protections are not double checked
> when migration entries are being removed but mprotect itself will mark
> write-migration-entries as read to avoid problems. It means we potentially
> take a spurious fault to mark these ptes write again but otherwise it's
> harmless.  Still, one dump indicates that this situation can actually
> happen so this debugging patch spits out a warning if the situation occurs
> and hopefully the resulting warning will contain a clue as to how exactly
> it happens
> 
> Not-signed-off
> ---
>  mm/migrate.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 09d489c..631725c 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -146,8 +146,16 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
>  	if (pte_swp_soft_dirty(*ptep))
>  		pte = pte_mksoft_dirty(pte);
> -	if (is_write_migration_entry(entry))
> -		pte = pte_mkwrite(pte);
> +	if (is_write_migration_entry(entry)) {
> +		/*
> +		 * This WARN_ON_ONCE is temporary for the purposes of seeing if
> +		 * it's a case encountered by trinity in Sasha's testing
> +		 */
> +		if (!(vma->vm_flags & (VM_WRITE)))
> +			WARN_ON_ONCE(1);
> +		else
> +			pte = pte_mkwrite(pte);
> +	}
>  #ifdef CONFIG_HUGETLB_PAGE
>  	if (PageHuge(new)) {
>  		pte = pte_mkhuge(pte);

I seem to have hit this warning:

[ 4782.617806] WARNING: CPU: 10 PID: 21180 at mm/migrate.c:155 remove_migration_pte+0x3f7/0x420()
[ 4782.619315] Modules linked in:
[ 4782.622189]
[ 4782.622501] CPU: 10 PID: 21180 Comm: trinity-main Tainted: G        W      3.17.0-rc4-next-20140910-sasha-00032-g6825fb5-dirty #1137
[ 4782.624344]  0000000000000009 ffff8800193eb770 ffffffffa04c742a 0000000000000000
[ 4782.627801]  ffff8800193eb7a8 ffffffff9d16e55d 00007f2458d89000 ffff880120959600
[ 4782.629283]  ffff88012b02c000 ffffea002abeab00 ffff88063118da90 ffff8800193eb7b8
[ 4782.631353] Call Trace:
[ 4782.633789]  [<ffffffffa04c742a>] dump_stack+0x4e/0x7a
[ 4782.634314]  [<ffffffff9d16e55d>] warn_slowpath_common+0x7d/0xa0
[ 4782.634877]  [<ffffffff9d16e63a>] warn_slowpath_null+0x1a/0x20
[ 4782.635430]  [<ffffffff9d315487>] remove_migration_pte+0x3f7/0x420
[ 4782.636042]  [<ffffffff9d2e99cf>] rmap_walk+0xef/0x380
[ 4782.636544]  [<ffffffff9d3147f1>] remove_migration_ptes+0x41/0x50
[ 4782.637130]  [<ffffffff9d315090>] ? __migration_entry_wait.isra.24+0x160/0x160
[ 4782.639928]  [<ffffffff9d3154b0>] ? remove_migration_pte+0x420/0x420
[ 4782.640616]  [<ffffffff9d31671b>] move_to_new_page+0x16b/0x230
[ 4782.641251]  [<ffffffff9d2e9e8c>] ? try_to_unmap+0x6c/0xf0
[ 4782.643950]  [<ffffffff9d2e88a0>] ? try_to_unmap_nonlinear+0x5c0/0x5c0
[ 4782.644690]  [<ffffffff9d2e70a0>] ? invalid_migration_vma+0x30/0x30
[ 4782.645273]  [<ffffffff9d2e82e0>] ? page_remove_rmap+0x320/0x320
[ 4782.646072]  [<ffffffff9d31717c>] migrate_pages+0x85c/0x930
[ 4782.646701]  [<ffffffff9d2d0e20>] ? isolate_freepages_block+0x410/0x410
[ 4782.647407]  [<ffffffff9d2cfa60>] ? arch_local_save_flags+0x30/0x30
[ 4782.648114]  [<ffffffff9d2d1803>] compact_zone+0x4d3/0x8a0
[ 4782.650157]  [<ffffffff9d2d1c2f>] compact_zone_order+0x5f/0xa0
[ 4782.651014]  [<ffffffff9d2d1f87>] try_to_compact_pages+0x127/0x2f0
[ 4782.651656]  [<ffffffff9d2b0c98>] __alloc_pages_direct_compact+0x68/0x200
[ 4782.652313]  [<ffffffff9d2b17ca>] __alloc_pages_nodemask+0x99a/0xd90
[ 4782.652916]  [<ffffffff9d300a1c>] alloc_pages_vma+0x13c/0x270
[ 4782.653618]  [<ffffffff9d31d914>] ? do_huge_pmd_wp_page+0x494/0xc90
[ 4782.654487]  [<ffffffff9d31d914>] do_huge_pmd_wp_page+0x494/0xc90
[ 4782.656045]  [<ffffffff9d320d20>] ? __mem_cgroup_count_vm_event+0xd0/0x240
[ 4782.657089]  [<ffffffff9d2dcb7d>] handle_mm_fault+0x8bd/0xc50
[ 4782.660931]  [<ffffffff9d1d26e6>] ? __lock_is_held+0x56/0x80
[ 4782.662695]  [<ffffffff9d0c7bc7>] __do_page_fault+0x1b7/0x660
[ 4782.663259]  [<ffffffff9d1cdc5e>] ? put_lock_stats.isra.13+0xe/0x30
[ 4782.663851]  [<ffffffff9d1abf41>] ? vtime_account_user+0x91/0xa0
[ 4782.664419]  [<ffffffff9d2a2c35>] ? context_tracking_user_exit+0xb5/0x1b0
[ 4782.665119]  [<ffffffff9db6e103>] ? __this_cpu_preempt_check+0x13/0x20
[ 4782.665969]  [<ffffffff9d1ce2e2>] ? trace_hardirqs_off_caller+0xe2/0x1b0
[ 4782.666634]  [<ffffffff9d0c8141>] trace_do_page_fault+0x51/0x2b0
[ 4782.667257]  [<ffffffff9d0bee83>] do_async_page_fault+0x63/0xd0
[ 4782.667871]  [<ffffffffa0511018>] async_page_fault+0x28/0x30

Although it wasn't followed by anything else, and I've seen the original issue
getting triggered without this WARN showing up, so it seems like a different,
unrelated issue?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4922D6B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 23:16:24 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so4413443qae.3
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:16:24 -0800 (PST)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id q18si1841673qeu.6.2013.12.18.20.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 20:16:23 -0800 (PST)
Received: by mail-vc0-f178.google.com with SMTP id lh4so340439vcb.37
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:16:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1387424720-22826-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1387424720-22826-1-git-send-email-liwanp@linux.vnet.ibm.com>
Date: Thu, 19 Dec 2013 12:16:22 +0800
Message-ID: <CAA_GA1dA0Yohqx9=HRUJWWcbwp==n3uY5auuB-LRMHWtKJ3QBQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/rmap: fix BUG at rmap_walk
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Dec 19, 2013 at 11:45 AM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> page_get_anon_vma() called in page_referenced_anon() will lock and increase
> the refcount of anon_vma, page won't be locked for anonymous page if the page
> is not locked by the caller. This patch fix the BUG_ON by reuse referenced
> field in page_referenced_arg to capture locked anonymous page for page_referenced(),
> if the anonymous page is locked by the caller, the referenced field will remember
> it, rmap_walk_anon will check if page locked if caller lock it.
>

Better commit log, please.
This bug is introduced by  commit 37f093cdf(mm/rmap: use rmap_walk()
in page_referenced()).
PageLocked is not required by page_referenced_anon() and there is not
any assertion before, commit 37f093cdf introduced this extra BUG_ON()
checking for anon page by mistake.

> [  588.698828] kernel BUG at mm/rmap.c:1663!
> [  588.699380] invalid opcode: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
> [  588.700347] Dumping ftrace buffer:
> [  588.701186]    (ftrace buffer empty)
> [  588.702062] Modules linked in:
> [  588.702759] CPU: 0 PID: 4647 Comm: kswapd0 Tainted: G      D W    3.13.0-rc4-next-20131218-sasha-00012-g1962367-dirty #4155
> [  588.704330] task: ffff880062bcb000 ti: ffff880062450000 task.ti: ffff880062450000
> [  588.705507] RIP: 0010:[<ffffffff81289c80>]  [<ffffffff81289c80>] rmap_walk+0x10/0x50
> [  588.706800] RSP: 0018:ffff8800624518d8  EFLAGS: 00010246
> [  588.707515] RAX: 000fffff80080048 RBX: ffffea00000227c0 RCX: 0000000000000000
> [  588.707515] RDX: 0000000000000000 RSI: ffff8800624518e8 RDI: ffffea00000227c0
> [  588.707515] RBP: ffff8800624518d8 R08: ffff8800624518e8 R09: 0000000000000000
> [  588.707515] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800624519d8
> [  588.707515] R13: 0000000000000000 R14: ffffea00000227e0 R15: 0000000000000000
> [  588.707515] FS:  0000000000000000(0000) GS:ffff880065200000(0000) knlGS:0000000000000000
> [  588.707515] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  588.707515] CR2: 00007fec40cbe0f8 CR3: 00000000c2382000 CR4: 00000000000006f0
> [  588.707515] Stack:
> [  588.707515]  ffff880062451958 ffffffff81289f4b ffff880062451918 ffffffff81289f80
> [  588.707515]  0000000000000000 0000000000000000 ffffffff8128af60 0000000000000000
> [  588.707515]  0000000000000024 0000000000000000 0000000000000000 0000000000000286
> [  588.707515] Call Trace:
> [  588.707515]  [<ffffffff81289f4b>] page_referenced+0xcb/0x100
> [  588.707515]  [<ffffffff81289f80>] ? page_referenced+0x100/0x100
> [  588.707515]  [<ffffffff8128af60>] ? invalid_page_referenced_vma+0x170/0x170
> [  588.707515]  [<ffffffff81264302>] shrink_active_list+0x212/0x330
> [  588.707515]  [<ffffffff81260e23>] ? inactive_file_is_low+0x33/0x50
> [  588.707515]  [<ffffffff812646f5>] shrink_lruvec+0x2d5/0x300
> [  588.707515]  [<ffffffff812647b6>] shrink_zone+0x96/0x1e0
> [  588.707515]  [<ffffffff81265b06>] kswapd_shrink_zone+0xf6/0x1c0
> [  588.707515]  [<ffffffff81265f43>] balance_pgdat+0x373/0x550
> [  588.707515]  [<ffffffff81266d63>] kswapd+0x2f3/0x350
> [  588.707515]  [<ffffffff81266a70>] ? perf_trace_mm_vmscan_lru_isolate_template+0x120/0x120
> [  588.707515]  [<ffffffff8115c9c5>] kthread+0x105/0x110
> [  588.707515]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
> [  588.707515]  [<ffffffff843a6a7c>] ret_from_fork+0x7c/0xb0
> [  588.707515]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
> [  588.707515] Code: c0 48 83 c4 18 89 d0 5b 41 5c 41 5d 41 5e 41 5f c9 c3 66 0f 1f 84
> 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 48 8b 07 a8 01 75 10 <0f> 0b 66 0f 1f 44 00 0
> 0 eb fe 66 0f 1f 44 00 00 f6 47 08 01 74
> [  588.707515] RIP  [<ffffffff81289c80>] rmap_walk+0x10/0x50
> [  588.707515]  RSP <ffff8800624518d8>
>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/ksm.c  |  5 +++++
>  mm/rmap.c | 20 ++++++++++++++++++--
>  2 files changed, 23 insertions(+), 2 deletions(-)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index c9a28dd..76d96df 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1899,6 +1899,11 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
>         int search_new_forks = 0;
>
>         VM_BUG_ON(!PageKsm(page));
> +
> +       /*
> +        * Rely on the page lock to protect against concurrent modifications
> +        * to that page's node of the stable tree.
> +        */
>         VM_BUG_ON(!PageLocked(page));
>
>         stable_node = page_stable_node(page);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index d792e71..db83961 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -769,6 +769,10 @@ int page_referenced(struct page *page,
>         struct page_referenced_arg pra = {
>                 .mapcount = page_mapcount(page),
>                 .memcg = memcg,
> +               /*
> +                * reuse referenced field for the locked anonymous page check
> +                */
> +               .referenced = is_locked && PageAnon(page) && !PageKsm(page),
>         };
>         struct rmap_walk_control rwc = {
>                 .rmap_one = page_referenced_one,
> @@ -1587,6 +1591,12 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
>         pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>         struct anon_vma_chain *avc;
>         int ret = SWAP_AGAIN;
> +       struct page_referenced_arg *pra = rwc->arg;
> +
> +       if (pra->referenced) {
> +               VM_BUG_ON(!PageLocked(page));
> +               pra->referenced = 0;
> +       }
>

I don't this is needed.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

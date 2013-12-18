Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 343136B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 04:36:33 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so3425481eei.0
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:36:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m44si8528530eeo.205.2013.12.18.01.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 01:36:32 -0800 (PST)
Message-ID: <52B16C9C.9060201@suse.cz>
Date: Wed, 18 Dec 2013 10:36:28 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, walken@google.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, sasha.levin@oracle.com, stable@kernel.org, gregkh@linuxfoundation.org, Bob Liu <bob.liu@oracle.com>

On 12/18/2013 01:42 AM, Bob Liu wrote:
> This BUG_ON() was triggered when called from try_to_unmap_cluster() which
> didn't lock the page.
> And it's safe to mlock_vma_page() without PageLocked, so this patch fix this
> issue by removing that BUG_ON() simply.

I think it might be correct, but needs better explanation why it's safe. 
The check appeared in both mlock_vma_page and munlock_vma_page since the 
original commit b291f0003. Munlock definitely needs it for 
try_to_munlock(), but mlock doesn't seem to be doing anything that would 
need it.

In case it's really not needed, it might be useful to remove the 
now-useless lock from the callers, if they acquire it just for this call.
I quickly checked:
- follow_trans_huge_pmd only rechecks page->mapping besides calling this
   so it might be a candidate?
- try_to_merge_one_page is definitely a candidate
- follow_page_mask checks page->mapping only outside of the lock, which
   seems strangely different from follow_trans_huge_pmd at first glance.
   So it only does lru_add_drain() under the lock and is probably a
   candidate. Or, it should be rechecking page->mapping as well.


> [  253.869145] kernel BUG at mm/mlock.c:82!
> [  253.869549] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  253.870098] Dumping ftrace buffer:
> [  253.870098]    (ftrace buffer empty)
> [  253.870098] Modules linked in:
> [  253.870098] CPU: 10 PID: 9162 Comm: trinity-child75 Tainted: G        W
> 3.13.0-rc4-next-20131216-sasha-00011-g5f105ec-dirty #4137
> [  253.873310] task: ffff8800c98cb000 ti: ffff8804d34e8000 task.ti:
> ffff8804d34e8000
> [  253.873310] RIP: 0010:[<ffffffff81281f28>]  [<ffffffff81281f28>]
> mlock_vma_page+0x18/0xc0
> [  253.873310] RSP: 0000:ffff8804d34e99e8  EFLAGS: 00010246
> [  253.873310] RAX: 006fffff8038002c RBX: ffffea00474944c0 RCX:
> ffff880807636000
> [  253.873310] RDX: ffffea0000000000 RSI: 00007f17a9bca000 RDI:
> ffffea00474944c0
> [  253.873310] RBP: ffff8804d34e99f8 R08: ffff880807020000 R09:
> 0000000000000000
> [  253.873310] R10: 0000000000000001 R11: 0000000000002000 R12:
> 00007f17a9bca000
> [  253.873310] R13: ffffea00474944c0 R14: 00007f17a9be0000 R15:
> ffff880807020000
> [  253.873310] FS:  00007f17aa31a700(0000) GS:ffff8801c9c00000(0000)
> knlGS:0000000000000000
> [  253.873310] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  253.873310] CR2: 00007f17a94fa000 CR3: 00000004d3b02000 CR4:
> 00000000000006e0
> [  253.873310] DR0: 00007f17a74ca000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  253.873310] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000600
> [  253.873310] Stack:
> [  253.873310]  0000000b3de28067 ffff880b3de28e50 ffff8804d34e9aa8
> ffffffff8128bc31
> [  253.873310]  0000000000000301 ffffea0011850220 ffff8809a4039000
> ffffea0011850238
> [  253.873310]  ffff8804d34e9aa8 ffff880807636060 0000000000000001
> ffff880807636348
> [  253.873310] Call Trace:
> [  253.873310]  [<ffffffff8128bc31>] try_to_unmap_cluster+0x1c1/0x340
> [  253.873310]  [<ffffffff8128c60a>] try_to_unmap_file+0x20a/0x2e0
> [  253.873310]  [<ffffffff8128c7b3>] try_to_unmap+0x73/0x90
> [  253.873310]  [<ffffffff812b526d>] __unmap_and_move+0x18d/0x250
> [  253.873310]  [<ffffffff812b53e9>] unmap_and_move+0xb9/0x180
> [  253.873310]  [<ffffffff812b559b>] migrate_pages+0xeb/0x2f0
> [  253.873310]  [<ffffffff812a0660>] ? queue_pages_pte_range+0x1a0/0x1a0
> [  253.873310]  [<ffffffff812a193c>] migrate_to_node+0x9c/0xc0
> [  253.873310]  [<ffffffff812a30b8>] do_migrate_pages+0x1b8/0x240
> [  253.873310]  [<ffffffff812a3456>] SYSC_migrate_pages+0x316/0x380
> [  253.873310]  [<ffffffff812a31ec>] ? SYSC_migrate_pages+0xac/0x380
> [  253.873310]  [<ffffffff811763c6>] ? vtime_account_user+0x96/0xb0
> [  253.873310]  [<ffffffff812a34ce>] SyS_migrate_pages+0xe/0x10
> [  253.873310]  [<ffffffff843c4990>] tracesys+0xdd/0xe2
> [  253.873310] Code: 0f 1f 00 65 48 ff 04 25 10 25 1d 00 48 83 c4 08
> 5b c9 c3 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 48 8b 07 48 89 fb
> a8 01 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 f0 0f ba
> 2f 15
> [  253.873310] RIP  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
> [  253.873310]  RSP <ffff8804d34e99e8>
> [  253.904194] ---[ end trace be59c4a7f8edab3f ]---
>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>   mm/mlock.c |    2 --
>   1 file changed, 2 deletions(-)
>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index d480cd6..5488d44 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -79,8 +79,6 @@ void clear_page_mlock(struct page *page)
>    */
>   void mlock_vma_page(struct page *page)
>   {
> -	BUG_ON(!PageLocked(page));
> -
>   	if (!TestSetPageMlocked(page)) {
>   		mod_zone_page_state(page_zone(page), NR_MLOCK,
>   				    hpage_nr_pages(page));
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

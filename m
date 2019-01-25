Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6D918E00B5
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 23:31:49 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q33so9214972qte.23
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 20:31:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor3379271qvh.26.2019.01.24.20.31.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 20:31:48 -0800 (PST)
Subject: Re: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
References: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw>
 <20190123093002.GP4087@dhcp22.suse.cz>
 <alpine.LSU.2.11.1901241909180.2158@eggly.anvils>
From: Qian Cai <cai@lca.pw>
Message-ID: <921c752d-8806-b9b5-8bb6-d570a3fec33d@lca.pw>
Date: Thu, 24 Jan 2019 23:31:46 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1901241909180.2158@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, vbabka@suse.cz, akpm@linux-foundation.org, Linux-MM <linux-mm@kvack.org>



On 1/24/19 11:19 PM, Hugh Dickins wrote:
> On Wed, 23 Jan 2019, Michal Hocko wrote:
>> On Tue 22-01-19 23:29:04, Qian Cai wrote:
>>> Running LTP migrate_pages03 [1] a few times triggering BUG() below on an arm64
>>> ThunderX2 server. Reverted the commit 9a1ea439b16b9 ("mm:
>>> put_and_wait_on_page_locked() while page is migrated") allows it to run
>>> continuously.
>>>
>>> put_and_wait_on_page_locked
>>>   wait_on_page_bit_common
>>>     put_page
>>>       put_page_testzero
>>>         VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
>>>
>>> [1]
>>> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/migrate_pages/migrate_pages03.c
>>>
>>> [ 1304.643587] page:ffff7fe0226ff000 count:2 mapcount:0 mapping:ffff8095c3406d58 index:0x7
>>> [ 1304.652082] xfs_address_space_operations [xfs]
>> [...]
>>> [ 1304.682652] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
>>
>> This looks like a page reference countimbalance to me. The page seemed
>> to be freed at the the migration code (wait_on_page_bit_common) called
>> put_page and immediatelly got reused for xfs allocation and that is why
>> we see its ref count==2. But I fail to see how that is possible as
>> __migration_entry_wait already does get_page_unless_zero so the
>> imbalance must have been preexisting.
> 
> This report worried me, but I've thought around it, and agree with
> Michal that it must be reflecting a preexisting refcount imbalance -
> preexisting in the sense that the imbalance occurred sometime before
> reaching put_and_wait_on_page_locked(), and in the sense that the bug
> causing the imbalance came in before the put_and_wait_on_page_locked()
> commit, perhaps even long ago.
> 
> If it is a software bug at all - I wonder if any other hardware shows
> the same issue - I have not seen it on x86 (though I wasn't using xfs),
> nor heard of anyone else reporting it - but thank you for doing so,
> it could be important.
> 
> But I (probably) disagree with Michal about the page being freed and
> reused for xfs allocation. I have no proof, but I think the likelihood
> is that the page shown is the old xfs page (from libc-2.28.so, I see)
> which is currently being migrated.
> 
> I realize that "last migrate reason: syscall_or_cpuset" would not get 
> set until later, but I think it's left over from the previous migration:
> migrate_pages03 looks like it's migrating pages back and forth repeatedly.
> 
> What I think happened is that something at some time earlier did a
> mistaken put_page() on the page.  Then __migration_entry_wait() raced
> with migrate_page_move_mapping(), in such a way that get_page_unless_zero()
> then briefly raised the page's refcount to expected_count, so migration was
> able to freeze the page (set its refcount transiently to 0).  Then put_and
> _wait_on_page_locked() reached the put_page() in wait_on_page_bit_common()
> while migration still had the refcount frozen at 0, and bang, your crash.
> 
> But how come reverting the put_and_wait commit appears to fix it for you?
> That puzzled me, for a while I expected you then to see an equally visible
> crash in the old put_page() after wait_on_page_locked(), or else at the
> migration end where it puts the page afterwards (putback_lru_page perhaps).
> 
> I guess the answer comes from that "libc-2.28.so".  This page is one of
> those very popular pages which were next-to-impossible to migrate before
> the put_and_wait commit, because they are so widely mapped, and their
> migration entries so frequently faulted, that migration could not freeze
> them.  (With enough migration waiters to outweigh the off-by-one of the
> incorrect refcount.)
> 
> Being so widely used, the refcount imbalance on that page would (I think)
> only show up when unmounting the root at shutdown: easily missed.
> 
> So I think you've identified that the put_and_wait commit has exposed
> an existing bug, and it may be very tedious to track down where that is.
> Maybe the bug is itself triggered by migrate_pages03, but quite likely not.

It looks like the put_and_wait commit just make the bug easier to reproduce, as
it has finally been able to reproduce it (via a different path) after 50+ runs
of migrate_pages03 on one of the affected machines even with the commit reverted.

[17890.870176] page:ffff7fe02563c780 count:0 mapcount:0 mapping:ffff800803ce6d58
index:0x1
[17890.879190] xfs_address_space_operations [xfs]
[17890.879196] name:"ld-2.28.so"
[17890.883724] flags: 0x17ffffc00000807(locked|referenced|uptodate|arch_1)
[17890.893376] raw: 017ffffc00000807 ffff8094df8a7c40 ffff7fe02561a948
0000000000000000
[17890.901111] raw: 0000000000000001 0000000000000000 00000002ffffffff
ffff80082039b080
[17890.908845] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[17890.915710] page->mem_cgroup:ffff80082039b080
[17890.920065] page allocated via order 0, migratetype Movable, gfp_mask
0x62124a(GFP_NOFS|__GFP_HIGHMEM|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE)
[17890.934245]  get_page_from_freelist+0x2d34/0x310c
[17890.938943]  __alloc_pages_nodemask+0x350/0x22d0
[17890.943559]  alloc_pages_current+0x154/0x158
[17890.947821]  __page_cache_alloc+0x274/0x27c
[17890.952002]  __do_page_cache_readahead+0x1e4/0x380
[17890.956785]  ondemand_readahead+0x790/0x97c
[17890.960961]  page_cache_sync_readahead+0x2c8/0x2cc
[17890.965743]  generic_file_buffered_read+0x2b4/0x143c
[17890.970700]  generic_file_read_iter+0x298/0x2e4
[17890.975433]  xfs_file_buffered_aio_read+0x5a0/0x5d0 [xfs]
[17890.981034]  xfs_file_read_iter+0x574/0x580 [xfs]
[17890.985735]  __vfs_read+0x478/0x4e8
[17890.989216]  vfs_read+0xe4/0x1fc
[17890.992436]  kernel_read+0xa8/0x110
[17890.995923]  load_elf_binary+0x92c/0x1b28
[17890.999932]  search_binary_handler+0x138/0x4dc
[17891.004368] page has been migrated, last migrate reason: syscall_or_cpuset
[17891.011294] ------------[ cut here ]------------
[17891.015903] kernel BUG at include/linux/mm.h:546!
[17891.020860] Internal error: Oops - BUG: 0 [#1] SMP
[17891.025645] Modules linked in: thunderx2_pmu ip_tables xfs libcrc32c sd_mod
ahci mlx5_core libahci libata dm_mirror dm_region_hash dm_log dm_mod efivarfs
[17891.039390] CPU: 230 PID: 10606 Comm: bash Kdump: loaded Not tainted
5.0.0-rc3+ #3
[17891.046950] Hardware name: HPE Apollo 70             /C01_APACHE_MB         ,
BIOS L50_5.13_1.0.6 07/10/2018
[17891.056767] pstate: 10400089 (nzcV daIf +PAN -UAO)
[17891.061553] pc : release_pages+0x1e8/0xdbc
[17891.065641] lr : release_pages+0x1e8/0xdbc
[17891.069727] sp : ffff8095580574d0
[17891.073032] x29: ffff8095580574d0 x28: 1fffeffc04afb720
[17891.078336] x27: 0000000000000001 x26: ffff7fe025602848
[17891.083639] x25: 0000000000000000 x24: 0000000000000034
[17891.088942] x23: ffff8095580575a0 x22: ffff80977c3b8400
[17891.094245] x21: ffff7fe02563c7b4 x20: dfff200000000000
[17891.099548] x19: ffff7fe02563c780 x18: 0000000000000000
[17891.104851] x17: 0000000000000000 x16: 0000000000000000
[17891.110153] x15: 0000000000000000 x14: 4f4d5f5046475f5f
[17891.115455] x13: 7c4c4c4157445241 x12: ffff0400026894e1
[17891.120758] x11: 1fffe400026894e1 x10: 5046475f5f7c4e52
[17891.126061] x9 : dfff200000000000 x8 : 737973203a6e6f73
[17891.131364] x7 : 0000000000000000 x6 : ffff20001021cc54
[17891.136666] x5 : 0000000000000000 x4 : 0000000000000000
[17891.141969] x3 : 0000000000000000 x2 : 29c8834f768b6d00
[17891.147275] x1 : 29c8834f768b6d00 x0 : 0000000000000000
[17891.152585] Process bash (pid: 10606, stack limit = 0x0000000036931683)
[17891.159190] Call trace:
[17891.161633]  release_pages+0x1e8/0xdbc
[17891.165379]  free_pages_and_swap_cache+0x60/0x200
[17891.170081]  tlb_flush_mmu_free+0xac/0xe4
[17891.174083]  tlb_flush_mmu+0x22c/0x37c
[17891.177824]  arch_tlb_finish_mmu+0x158/0x260
[17891.182086]  tlb_finish_mmu+0x8c/0xcc
[17891.185741]  exit_mmap+0x268/0x334
[17891.189139]  mmput+0x118/0x2c8
[17891.192187]  flush_old_exec+0x3a8/0x4fc
[17891.196016]  load_elf_binary+0x430/0x1b28
[17891.200019]  search_binary_handler+0x138/0x4dc
[17891.204454]  load_script+0x45c/0x484
[17891.208022]  search_binary_handler+0x138/0x4dc
[17891.212459]  __do_execve_file+0x1144/0x1808
[17891.216634]  do_execve+0x40/0x50
[17891.219855]  __arm64_sys_execve+0x8c/0xa0
[17891.223867]  el0_svc_handler+0x258/0x304
[17891.227785]  el0_svc+0x8/0xc
[17891.230660] Code: 91168021 911d0021 aa1303e0 9401a40a (d4210000)

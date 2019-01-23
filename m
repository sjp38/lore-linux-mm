Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 389508E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 23:29:08 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id y83so896765qka.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 20:29:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9sor106743037qvc.39.2019.01.22.20.29.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 20:29:07 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
Message-ID: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw>
Date: Tue, 22 Jan 2019 23:29:04 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, torvalds@linux-foundation.org, vbabka@suse.cz, akpm@linux-foundation.org
Cc: Linux-MM <linux-mm@kvack.org>

Running LTP migrate_pages03 [1] a few times triggering BUG() below on an arm64
ThunderX2 server. Reverted the commit 9a1ea439b16b9 ("mm:
put_and_wait_on_page_locked() while page is migrated") allows it to run
continuously.

put_and_wait_on_page_locked
  wait_on_page_bit_common
    put_page
      put_page_testzero
        VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);

[1]
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/migrate_pages/migrate_pages03.c

[ 1304.643587] page:ffff7fe0226ff000 count:2 mapcount:0 mapping:ffff8095c3406d58
index:0x7
[ 1304.652082] xfs_address_space_operations [xfs]
[ 1304.652104] name:"libc-2.28.so"
[ 1304.656653] flags: 0x7ffffc00000887(locked|waiters|referenced|uptodate|arch_1)
[ 1304.667134] raw: 007ffffc00000887 ffff7fe0227bac88 ffff7fe02261cd88
0000000000000000
[ 1304.674894] raw: 0000000000000007 0000000000000000 00000002ffffffff
ffff80082039b080
[ 1304.682652] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[ 1304.689553] page->mem_cgroup:ffff80082039b080
[ 1304.693932] page allocated via order 0, migratetype Movable, gfp_mask
0x62124a(GFP_NOFS|__GFP_HIGHMEM|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE)
[ 1304.708137]  get_page_from_freelist+0x2cec/0x30c0
[ 1304.712864]  __alloc_pages_nodemask+0x350/0x22d0
[ 1304.717504]  alloc_pages_current+0x154/0x158
[ 1304.721795]  __page_cache_alloc+0x274/0x27c
[ 1304.726001]  __do_page_cache_readahead+0x1e4/0x380
[ 1304.730812]  filemap_fault+0x540/0x1204
[ 1304.734882]  __xfs_filemap_fault+0x714/0x734 [xfs]
[ 1304.739893]  xfs_filemap_fault+0xe4/0xfc [xfs]
[ 1304.744440]  __do_fault+0x294/0x5dc
[ 1304.747950]  do_fault+0x324/0x1360
[ 1304.751370]  __handle_mm_fault+0x9a8/0xb90
[ 1304.755481]  handle_mm_fault+0x610/0x614
[ 1304.759423]  do_page_fault+0x530/0x818
[ 1304.763188]  do_translation_fault+0x88/0xe8
[ 1304.767388]  do_mem_abort+0x78/0x168
[ 1304.770979]  do_el0_ia_bp_hardening+0x7c/0x8c
[ 1304.775351] page has been migrated, last migrate reason: syscall_or_cpuset
[ 1304.782294] ------------[ cut here ]------------
[ 1304.786904] kernel BUG at include/linux/mm.h:546!
[ 1304.791728] Internal error: Oops - BUG: 0 [#1] SMP
[ 1304.796513] Modules linked in: thunderx2_pmu ip_tables xfs libcrc32c sd_mod
ahci libahci mlx5_core libata dm_mirror dm_region_hash dm_log dm_mod efivarfs
[ 1304.810256] CPU: 248 PID: 10307 Comm: 0anacron Kdump: loaded Not tainted
5.0.0-rc3+ #1
[ 1304.818163] Hardware name: HPE Apollo 70             /C01_APACHE_MB         ,
BIOS L50_5.13_1.0.6 07/10/2018
[ 1304.827980] pstate: 10400009 (nzcV daif +PAN -UAO)
[ 1304.832764] pc : put_and_wait_on_page_locked+0x4c8/0x5f0
[ 1304.838067] lr : put_and_wait_on_page_locked+0x4c8/0x5f0
[ 1304.843369] sp : ffff8094fbf57960
[ 1304.846674] x29: ffff8094fbf57960 x28: ffff2000117f7f90
[ 1304.851978] x27: ffff2000117f7f88 x26: ffff2000117fd6c8
[ 1304.857281] x25: 0000000000000001 x24: ffff8094fbf579f0
[ 1304.862584] x23: 1ffff0129f7eaf3a x22: ffff2000117f7f50
[ 1304.867887] x21: dfff200000000000 x20: ffff7fe0226ff034
[ 1304.873190] x19: ffff7fe0226ff000 x18: 0000000000000000
[ 1304.878493] x17: 0000000000000000 x16: 0000000000000000
[ 1304.883795] x15: 0000000000000000 x14: 46475f5f7c4c4c41
[ 1304.889098] x13: 57445241485f5046 x12: ffff0400025bb4d9
[ 1304.894401] x11: 1fffe400025bb4d9 x10: 5f7c4e5241574f4e
[ 1304.899703] x9 : dfff200000000000 x8 : 6c6c616373797320
[ 1304.905006] x7 : 0000000000000000 x6 : ffff20001021b024
[ 1304.910309] x5 : 0000000000000000 x4 : 0000000000000000
[ 1304.915612] x3 : 0000000000000000 x2 : 29c8834f768b6d00
[ 1304.920914] x1 : 29c8834f768b6d00 x0 : 0000000000000000
[ 1304.926220] Process 0anacron (pid: 10307, stack limit = 0x00000000e3061c7a)
[ 1304.933172] Call trace:
[ 1304.935610]  put_and_wait_on_page_locked+0x4c8/0x5f0
[ 1304.940577]  __migration_entry_wait+0x238/0x260
[ 1304.945098]  migration_entry_wait+0xfc/0x110
[ 1304.949361]  do_swap_page+0x1b0/0x198c
[ 1304.953101]  __handle_mm_fault+0x9a0/0xb90
[ 1304.957188]  handle_mm_fault+0x610/0x614
[ 1304.961102]  do_page_fault+0x530/0x818
[ 1304.964842]  do_translation_fault+0x88/0xe8
[ 1304.969016]  do_mem_abort+0x78/0x168
[ 1304.972583]  do_el0_ia_bp_hardening+0x7c/0x8c
[ 1304.976931]  el0_ia+0x1c/0x20
[ 1304.979893] Code: 91298021 91128021 aa1303e0 940282fb (d4210000)

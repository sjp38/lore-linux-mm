Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 228EB8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 15:30:08 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s70so38387484qks.4
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 12:30:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y5si2056113qvk.5.2019.01.02.12.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 12:30:06 -0800 (PST)
Date: Wed, 2 Jan 2019 15:30:04 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <1323128903.93005102.1546461004635.JavaMail.zimbra@redhat.com>
In-Reply-To: <1038135449.92986364.1546459244292.JavaMail.zimbra@redhat.com>
Subject: [bug] problems with migration of huge pages with
 v4.20-10214-ge1ef035d272e
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com
Cc: "ltp@lists.linux.it" <ltp@lists.linux.it>, mhocko@kernel.org, Rachel Sibley <rasibley@redhat.com>, hughd@google.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, dave@stgolabs.net, prakash.sangappa@oracle.com, colin.king@canonical.com

Hi,

LTP move_pages12 [1] started failing recently.

The test maps/unmaps some anonymous private huge pages
and migrates them between 2 nodes. This now reliably
hits NULL ptr deref:

[  194.819357] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[  194.864410] #PF error: [WRITE]
[  194.881502] PGD 22c758067 P4D 22c758067 PUD 235177067 PMD 0
[  194.913833] Oops: 0002 [#1] SMP NOPTI
[  194.935062] CPU: 0 PID: 865 Comm: move_pages12 Not tainted 4.20.0+ #1
[  194.972993] Hardware name: HP ProLiant SL335s G7/, BIOS A24 12/08/2012
[  195.005359] RIP: 0010:down_write+0x1b/0x40
[  195.028257] Code: 00 5c 01 00 48 83 c8 03 48 89 43 20 5b c3 90 0f 1f 44 00 00 53 48 89 fb e8 d2 d7 ff ff 48 89 d8 48 ba 01 00 00 00 ff ff
ff ff <f0> 48 0f c1 10 85 d2 74 05 e8 07 26 ff ff 65 48 8b 04 25 00 5c 01
[  195.121836] RSP: 0018:ffffb87e4224fd00 EFLAGS: 00010246
[  195.147097] RAX: 0000000000000030 RBX: 0000000000000030 RCX: 0000000000000000
[  195.185096] RDX: ffffffff00000001 RSI: ffffffffa69d30f0 RDI: 0000000000000030
[  195.219251] RBP: 0000000000000030 R08: ffffe7d4889d8008 R09: 0000000000000003
[  195.258291] R10: 000000000000000f R11: ffffe7d4889d8008 R12: ffffe7d4889d0008
[  195.294547] R13: ffffe7d490b78000 R14: ffffe7d4889d0000 R15: ffff8be9b2ba4580
[  195.332532] FS:  00007f1670112b80(0000) GS:ffff8be9b7a00000(0000) knlGS:0000000000000000
[  195.373888] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  195.405938] CR2: 0000000000000030 CR3: 000000023477e000 CR4: 00000000000006f0
[  195.443579] Call Trace:
[  195.456876]  migrate_pages+0x833/0xcb0
[  195.478070]  ? __ia32_compat_sys_migrate_pages+0x20/0x20
[  195.506027]  do_move_pages_to_node.isra.63.part.64+0x2a/0x50
[  195.536963]  kernel_move_pages+0x667/0x8c0
[  195.559616]  ? __handle_mm_fault+0xb95/0x1370
[  195.588765]  __x64_sys_move_pages+0x24/0x30
[  195.611439]  do_syscall_64+0x5b/0x160
[  195.631901]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  195.657790] RIP: 0033:0x7f166f5ff959
[  195.676365] Code: 00 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08
0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 17 45 2c 00 f7 d8 64 89 01 48
[  195.772938] RSP: 002b:00007ffd8d77bb48 EFLAGS: 00000246 ORIG_RAX: 0000000000000117
[  195.810207] RAX: ffffffffffffffda RBX: 0000000000000400 RCX: 00007f166f5ff959
[  195.847522] RDX: 0000000002303400 RSI: 0000000000000400 RDI: 0000000000000360
[  195.882327] RBP: 0000000000000400 R08: 0000000002306420 R09: 0000000000000004
[  195.920017] R10: 0000000002305410 R11: 0000000000000246 R12: 0000000002303400
[  195.958053] R13: 0000000002305410 R14: 0000000002306420 R15: 0000000000000003
[  195.997028] Modules linked in: sunrpc amd64_edac_mod ipmi_ssif edac_mce_amd kvm_amd ipmi_si igb ipmi_devintf k10temp kvm pcspkr ipmi_msgha
ndler joydev irqbypass sp5100_tco dca hpwdt hpilo i2c_piix4 xfs libcrc32c radeon i2c_algo_bit drm_kms_helper ttm ata_generic pata_acpi drm se
rio_raw pata_atiixp
[  196.134162] CR2: 0000000000000030
[  196.152788] ---[ end trace 4420ea5061342d3e ]---

Suspected commit is:
  b43a99900559 ("hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization")
which adds to unmap_and_move_huge_page():
+               struct address_space *mapping = page_mapping(hpage);
+
+               /*
+                * try_to_unmap could potentially call huge_pmd_unshare.
+                * Because of this, take semaphore in write mode here and
+                * set TTU_RMAP_LOCKED to let lower levels know we have
+                * taken the lock.
+                */
+               i_mmap_lock_write(mapping);

If I'm reading this right, 'mapping' will be NULL for anon mappings.

Running same test with s/MAP_PRIVATE/MAP_SHARED/ leads to user-space
hanging at:

# cat /proc/23654/stack
[<0>] io_schedule+0x12/0x40
[<0>] __lock_page+0x13c/0x200
[<0>] remove_inode_hugepages+0x275/0x300
[<0>] hugetlbfs_evict_inode+0x2e/0x60
[<0>] evict+0xcb/0x190
[<0>] __dentry_kill+0xce/0x160
[<0>] dentry_kill+0x47/0x170
[<0>] dput.part.33+0xc6/0x100
[<0>] __fput+0x105/0x230
[<0>] task_work_run+0x84/0xa0
[<0>] exit_to_usermode_loop+0xd3/0xe0
[<0>] do_syscall_64+0x14d/0x160
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
[<0>] 0xffffffffffffffff

# cat /proc/23655/stack
[<0>] call_rwsem_down_read_failed+0x14/0x30
[<0>] rmap_walk_file+0x1c1/0x2f0
[<0>] remove_migration_ptes+0x6d/0x80
[<0>] migrate_pages+0x86a/0xcb0
[<0>] do_move_pages_to_node.isra.63.part.64+0x2a/0x50
[<0>] kernel_move_pages+0x667/0x8c0
[<0>] __x64_sys_move_pages+0x24/0x30
[<0>] do_syscall_64+0x5b/0x160
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
[<0>] 0xffffffffffffffff

Regards,
Jan

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/move_pages/move_pages12.c

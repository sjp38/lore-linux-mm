Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9723A6B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 18:39:40 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so36564530pac.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 15:39:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 62si5173853pff.27.2016.05.10.15.39.39
        for <linux-mm@kvack.org>;
        Tue, 10 May 2016 15:39:39 -0700 (PDT)
Date: Tue, 10 May 2016 16:39:37 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Message-ID: <20160510223937.GA10222@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <20160506203308.GA12506@linux.intel.com>
 <20160509093828.GF11897@quack2.suse.cz>
 <20160510152814.GQ11897@quack2.suse.cz>
 <20160510203003.GA5314@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160510203003.GA5314@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Tue, May 10, 2016 at 02:30:03PM -0600, Ross Zwisler wrote:
> On Tue, May 10, 2016 at 05:28:14PM +0200, Jan Kara wrote:
> > On Mon 09-05-16 11:38:28, Jan Kara wrote:
> > Somehow, I'm not able to reproduce the warnings... Anyway, I think I see
> > what's going on. Can you check whether the warning goes away when you
> > change the condition at the end of page_cache_tree_delete() to:
> > 
> >         if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
> >             list_empty(&node->private_list)) {
> 
> Yep, this took care of both of the issues that I reported.  I'll restart my
> testing with this in my baseline, but as of this fix I don't have any more
> open testing issues. :)

Well, looks like I spoke too soon.  The two tests that were failing for me are
now passing, but I can still create what looks like a related failure using
XFS, DAX, and the two xfstests generic/231 and generic/232 run back-to-back.

Here's the shell:

  # ./check generic/231 generic/232
  FSTYP         -- xfs (debug)
  PLATFORM      -- Linux/x86_64 alara 4.6.0-rc5jan_testing_2+
  MKFS_OPTIONS  -- -f -bsize=4096 /dev/pmem0p2
  MOUNT_OPTIONS -- -o dax -o context=system_u:object_r:nfs_t:s0 /dev/pmem0p2 /mnt/xfstests_scratch
  
  generic/231 88s ... 88s
  generic/232 2s ..../check: line 543:  9105 Segmentation fault      ./$seq > $tmp.rawout 2>&1
   [failed, exit status 139] - output mismatch (see /root/xfstests/results//generic/232.out.bad)
      --- tests/generic/232.out	2015-10-02 10:19:36.806795894 -0600
      +++ /root/xfstests/results//generic/232.out.bad	2016-05-10 16:17:54.805637876 -0600
      @@ -3,5 +3,3 @@
       Testing fsstress
       
       seed = S
      -Comparing user usage
      -Comparing group usage
      ...
      (Run 'diff -u tests/generic/232.out /root/xfstests/results//generic/232.out.bad'  to see the entire diff)
  
and the serial log:

  run fstests generic/232 at 2016-05-10 16:17:53
  XFS (pmem0p2): DAX enabled. Warning: EXPERIMENTAL, use at your own risk
  XFS (pmem0p2): Mounting V5 Filesystem
  XFS (pmem0p2): Ending clean mount
  XFS (pmem0p2): Quotacheck needed: Please wait.
  XFS (pmem0p2): Quotacheck: Done.
  ------------[ cut here ]------------
  kernel BUG at mm/workingset.c:423!
  invalid opcode: 0000 [#1] SMP
  Modules linked in: nd_pmem nd_btt nd_e820 libnvdimm
  CPU: 1 PID: 9105 Comm: 232 Not tainted 4.6.0-rc5jan_testing_2+ #6
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
  task: ffff8801f4eb98c0 ti: ffff88040e5f0000 task.ti: ffff88040e5f0000
  RIP: 0010:[<ffffffff81207b93>]  [<ffffffff81207b93>] shadow_lru_isolate+0x183/0x1a0
  RSP: 0018:ffff88040e5f3be8  EFLAGS: 00010006
  RAX: ffff880401f68270 RBX: ffff880401f68260 RCX: ffff880401f68470
  RDX: 000000000000006c RSI: 0000000000000000 RDI: ffff880410b2bd80
  RBP: ffff88040e5f3c10 R08: 0000000000000008 R09: 0000000000000000
  R10: ffff8800b59eb840 R11: 0000000000000080 R12: ffff880410b2bd80
  R13: ffff8800b59eb828 R14: ffff8800b59eb810 R15: ffff880410b2bdc8
  FS:  00007fb73c58c700(0000) GS:ffff88041a200000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007fb73c5a4000 CR3: 000000040e139000 CR4: 00000000000006e0
  Stack:
   ffff880410b2bd80 ffff880410b2bdc8 ffff88040e5f3d18 ffff880410b2bdc8
   ffff880401f68260 ffff88040e5f3c60 ffffffff81206c7f 0000000000000000
   0000000000000000 ffffffff81207a10 ffff88040e5f3d10 0000000000000000
  Call Trace:
   [<ffffffff81206c7f>] __list_lru_walk_one.isra.3+0x9f/0x150 mm/list_lru.c:223
   [<ffffffff81206d53>] list_lru_walk_one+0x23/0x30 mm/list_lru.c:263
   [<     inline     >] list_lru_shrink_walk include/linux/list_lru.h:170
   [<ffffffff81207bea>] scan_shadow_nodes+0x3a/0x50 mm/workingset.c:457
   [<     inline     >] do_shrink_slab mm/vmscan.c:344
   [<ffffffff811ea37e>] shrink_slab.part.40+0x1fe/0x420 mm/vmscan.c:442
   [<ffffffff811ea5c9>] shrink_slab+0x29/0x30 mm/vmscan.c:406
   [<ffffffff811ec831>] drop_slab_node+0x31/0x60 mm/vmscan.c:460
   [<ffffffff811ec89f>] drop_slab+0x3f/0x70 mm/vmscan.c:471
   [<ffffffff812d8c39>] drop_caches_sysctl_handler+0x69/0xb0 fs/drop_caches.c:58
   [<ffffffff812f2937>] proc_sys_call_handler+0xe7/0x100 fs/proc/proc_sysctl.c:543
   [<ffffffff812f2964>] proc_sys_write+0x14/0x20 fs/proc/proc_sysctl.c:561
   [<ffffffff81269aa7>] __vfs_write+0x37/0x120 fs/read_write.c:529
   [<ffffffff8126a3fc>] vfs_write+0xac/0x1a0 fs/read_write.c:578
   [<     inline     >] SYSC_write fs/read_write.c:625
   [<ffffffff8126b8d8>] SyS_write+0x58/0xd0 fs/read_write.c:617
   [<ffffffff81a92a3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd arch/x86/entry/entry_64.S:207
  Code: 66 90 66 66 90 e8 4e 53 88 00 fa 66 66 90 66 66 90 e8 52 5c ef ff 4c 89 e7 e8 ba a1 88 00 89 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 <0f> 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 66 66 66 66 66 66 2e
  RIP  [<ffffffff81207b93>] shadow_lru_isolate+0x183/0x1a0 mm/workingset.c:448
   RSP <ffff88040e5f3be8>
  ---[ end trace c4ff9bc94605ec45 ]---

This was against a tree with your most recent fix.  The full tree can be found
here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=jan_testing

This only recreates on about 1/2 of the runs of these tests in my system.

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

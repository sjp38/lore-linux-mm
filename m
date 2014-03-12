Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 23A7F6B00B3
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 10:56:16 -0400 (EDT)
Received: by mail-bk0-f52.google.com with SMTP id my13so1444530bkb.11
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 07:56:15 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id no8si10580476bkb.250.2014.03.12.07.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 07:56:14 -0700 (PDT)
Date: Wed, 12 Mar 2014 10:56:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/8] mm: memcg: push !mm handling out to page cache
 charge function
Message-ID: <20140312145611.GD14688@cmpxchg.org>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
 <1394587714-6966-5-git-send-email-hannes@cmpxchg.org>
 <20140312131152.GC11831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140312131152.GC11831@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 12, 2014 at 02:11:52PM +0100, Michal Hocko wrote:
> On Tue 11-03-14 21:28:30, Johannes Weiner wrote:
> [...]
> > @@ -4070,6 +4061,12 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >  		return 0;
> >  
> >  	if (!PageSwapCache(page)) {
> > +		/*
> > +		 * Page cache insertions can happen without an actual
> > +		 * task context, e.g. during disk probing on boot.
> 
> We read a page cache during disk probing? I have tried to find such a
> code path but failed. Could you point me to such a path, please?
> I thought that such probing is done from udev context but I am not
> familiar with this area TBH.

Yes, I tried to remove the !mm case entirely and hit the following
during boot:

[    1.869561] BUG: unable to handle kernel NULL pointer dereference at 0000000000000320
[    1.869565] IP: [<ffffffff811369a2>] get_mem_cgroup_from_mm+0x32/0x80
[    1.869566] PGD 0
[    1.869567] Oops: 0000 [#1] SMP
[    1.869569] CPU: 3 PID: 65 Comm: kworker/u8:6 Not tainted 3.14.0-rc6-00007-g3856318f53a0-dirty #133
[    1.869569] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./H61M-DGS, BIOS P1.30 05/10/2012
[    1.869573] Workqueue: events_unbound async_run_entry_fn
[    1.869573] task: ffff8800ce82d3c0 ti: ffff8800ce8c6000 task.ti: ffff8800ce8c6000
[    1.869575] RIP: 0010:[<ffffffff811369a2>]  [<ffffffff811369a2>] get_mem_cgroup_from_mm+0x32/0x80
[    1.869576] RSP: 0000:ffff8800ce8c78f8  EFLAGS: 00010246
[    1.869576] RAX: 003fffc000000001 RBX: 0000000000000000 RCX: 0000000000000001
[    1.869577] RDX: 00000000000000d0 RSI: 0000000000000000 RDI: 0000000000000000
[    1.869577] RBP: ffff8800ce8c7908 R08: ffffffff81713232 R09: ffffea00033a1680
[    1.869578] R10: 0000000000001723 R11: ffffc90004e4dfff R12: 0000000000000000
[    1.869578] R13: 0000000000000001 R14: 0000000000000000 R15: 00000000000000d0
[    1.869579] FS:  0000000000000000(0000) GS:ffff88021f380000(0000) knlGS:0000000000000000
[    1.869579] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.869580] CR2: 0000000000000320 CR3: 00000000017a5000 CR4: 00000000000407e0
[    1.869580] Stack:
[    1.869581]  0000000000000000 ffffea00033a1640 ffff8800ce8c7948 ffffffff8113a112
[    1.869582]  00000001ce8c7978 0000000000000000 ffffea00033a1640 00000000000200d0
[    1.869583]  0000000000000000 ffffffff81174520 ffff8800ce8c7970 ffffffff8113be0a
[    1.869583] Call Trace:
[    1.869586]  [<ffffffff8113a112>] mem_cgroup_charge_common+0x42/0xf0
[    1.869589]  [<ffffffff81174520>] ? blkdev_write_begin+0x30/0x30
[    1.869590]  [<ffffffff8113be0a>] mem_cgroup_cache_charge+0x7a/0xb0
[    1.869592] sd 1:0:0:0: [sdb] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
[    1.869594]  [<ffffffff810db06d>] add_to_page_cache_locked+0x3d/0x150
[    1.869595]  [<ffffffff810db19a>] add_to_page_cache_lru+0x1a/0x40
[    1.869597]  [<ffffffff810dbdef>] do_read_cache_page+0x6f/0x1a0
[    1.869598]  [<ffffffff810dce79>] read_cache_page+0x19/0x30
[    1.869601]  [<ffffffff8123952d>] read_dev_sector+0x2d/0x90
[    1.869603]  [<ffffffff8123a21f>] read_lba+0xef/0x1a0
[    1.869604]  [<ffffffff8123a663>] ? find_valid_gpt+0xc3/0x640
[    1.869605]  [<ffffffff8123a681>] find_valid_gpt+0xe1/0x640
[    1.869607]  [<ffffffff81249e6b>] ? string.isra.4+0x3b/0xf0
[    1.869609]  [<ffffffff8123abe0>] ? find_valid_gpt+0x640/0x640
[    1.869610]  [<ffffffff8123ac56>] efi_partition+0x76/0x3f0
[    1.869611]  [<ffffffff8124aec4>] ? vsnprintf+0x1f4/0x610
[    1.869612]  [<ffffffff8124b799>] ? snprintf+0x39/0x40
[    1.869613]  [<ffffffff8123abe0>] ? find_valid_gpt+0x640/0x640
[    1.869615]  [<ffffffff812396c8>] check_partition+0x108/0x240
[    1.869616]  [<ffffffff81239264>] rescan_partitions+0xb4/0x2c0
[    1.869617]  [<ffffffff8117584c>] __blkdev_get+0x2dc/0x400
[    1.869618]  [<ffffffff81175b1d>] blkdev_get+0x1ad/0x320
[    1.869619] sd 1:0:0:0: [sdb] Write Protect is off
[    1.869621]  [<ffffffff81157603>] ? unlock_new_inode+0x43/0x70
[    1.869622] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    1.869622]  [<ffffffff81174f66>] ? bdget+0x136/0x150
[    1.869624]  [<ffffffff81236b34>] add_disk+0x394/0x4a0
[    1.869627]  [<ffffffff8135b327>] sd_probe_async+0x127/0x1d0
[    1.869628]  [<ffffffff81065c87>] async_run_entry_fn+0x37/0x130
[    1.869629]  [<ffffffff810595fe>] process_one_work+0x16e/0x3e0
[    1.869630]  [<ffffffff81059991>] worker_thread+0x121/0x3a0
[    1.869631]  [<ffffffff81059870>] ? process_one_work+0x3e0/0x3e0
[    1.869633]  [<ffffffff810602c2>] kthread+0xd2/0xf0
[    1.869634] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.869636]  [<ffffffff810601f0>] ? __kthread_parkme+0x70/0x70
[    1.869638]  [<ffffffff815dbaac>] ret_from_fork+0x7c/0xb0
[    1.869639]  [<ffffffff810601f0>] ? __kthread_parkme+0x70/0x70
[    1.869648] Code: 89 e5 41 54 49 89 fc 53 eb 21 0f 1f 80 00 00 00 00 f6 43 48 01 75 52 48 8b 43 18 a8 03 75 52 65 ff 00 b8 01 00 00 00 84 c0 75 3e <49> 8b 84 24 20 03 00 00 48 85 c0 74 10 48 8b 80 98 06 00 00 48
[    1.869650] RIP  [<ffffffff811369a2>] get_mem_cgroup_from_mm+0x32/0x80
[    1.869650]  RSP <ffff8800ce8c78f8>
[    1.869650] CR2: 0000000000000320
[    1.869653] ---[ end trace 4cda1f5484a90d6d ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

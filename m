Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id B9D6D6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:49:12 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so5708227qae.24
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:49:12 -0800 (PST)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id f91si4101173qge.98.2014.02.07.09.49.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:49:11 -0800 (PST)
Received: by mail-qc0-f179.google.com with SMTP id e16so6445371qcx.38
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:49:10 -0800 (PST)
Date: Fri, 7 Feb 2014 12:49:07 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [cgroup] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000080
Message-ID: <20140207174907.GA12815@htj.dyndns.org>
References: <20140207022850.GB11051@localhost>
 <20140207023333.GB11369@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207023333.GB11369@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: cgroups@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hello, Fengguang.

On Fri, Feb 07, 2014 at 10:33:33AM +0800, Fengguang Wu wrote:
> Tejun,
> 
> Here is another bisect.
> 
> The first bad commit could be any of:
> 5a87728c4502d0a99f53346545605360fce1e91e cgroup: factor out cgroup_setup_root() from cgroup_mount()
> 6a9fc7f859a24754999ff9096015583b70dfa162 cgroup: update cgroup name handling
> bb7a2fa01329b0afc2307011d634c4bde5ef10f1 cgroup: restructure locking and error handling in cgroup_mount()
> 0571b870aa584093000cc9a2925db1463813212f cgroup: make cgroup_subsys->base_cftypes use cgroup_add_cftypes()
> 4e6a3a2aae35039751d88a567a0346660f01a1a1 cgroup: release cgroup_mutex over file removals
> 43b48e8041f0bfaf295e796d9157b40dfac798f0 cgroup: update the meaning of cftype->max_write_len
> 9c92986924852946840aa265c66325790e926a36 cgroup: introduce cgroup_tree_mutex
> 0be500347039f5ef658fd3045ca42afa72583e2d cgroup: improve css_from_dir() into css_tryget_from_dir()
> ed6d28fc60daadf1f445ab439e4da86fd363f2bb cgroup: introduce cgroup_init/exit_cftypes()
> 80f9567b80a645d67f332bc6707ac4d859f05e19 Merge branch 'review-kernfs-cgroup-prep' into review-kernfs-conversion
> c48b4c28016fdf927148616940279291d028cbc2 cgroup: introduce cgroup_ino()
> 455447a2486bc982c7aae2bb0cf93c810da5faae cgroup: misc preps for kernfs conversion
> 7bac9560a270d2fca5b65893851aa29676db2f4e kernfs: add CONFIG_KERNFS
> 8d4bee55479f18cbbcbdd3a1c9a3331b90932f05 cgroup: relocate functions in preparation of kernfs conversion
> ad1521d8543336ac7acf14f918f467ec27e765b9 kernfs: implement kernfs_get_parent(), kernfs_name/path() and friends
> 7c87a9de3197667e64401fdba77cb641b93d9d90 cgroup: convert to kernfs
> We cannot bisect more!
> 
> +------------------------------------------------------------+----+
> |                                                            |    |
> +------------------------------------------------------------+----+
> | boot_successes                                             | 0  |
> | boot_failures                                              | 19 |
> | BUG:unable_to_handle_kernel_NULL_pointer_dereference_at    | 19 |
> | Oops:SMP_DEBUG_PAGEALLOC                                   | 19 |
> | RIP:kobject_add_internal                                   | 19 |
> | WARNING:CPU:PID:at_kernel/smp.c:smp_call_function_single() | 19 |
> | Kernel_panic-not_syncing:Attempted_to_kill_init_exitcode=  | 19 |
> | backtrace:__class_register                                 | 10 |
> | backtrace:netdev_kobject_init                              | 10 |
> | backtrace:net_dev_init                                     | 10 |
> | backtrace:kernel_init_freeable                             | 10 |
> +------------------------------------------------------------+----+
> 
> [    0.413902] PCI: pci_cache_line_size set to 64 bytes
> [    0.417267] BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
> [    0.418531] IP: [<ffffffff81437700>] kobject_add_internal+0x720/0x940
...
> [    0.420000]  [<ffffffff81437958>] kset_register+0x38/0x80
> [    0.420000]  [<ffffffff8190473f>] __class_register+0x1cf/0x390
> [    0.420000]  [<ffffffff82edebcc>] netdev_kobject_init+0x31/0x3a
> [    0.420000]  [<ffffffff82ede3d8>] net_dev_init+0x77/0x292
> [    0.420000]  [<ffffffff82e787c5>] do_one_initcall+0x14f/0x27b
> [    0.420000]  [<ffffffff82e78c02>] kernel_init_freeable+0x311/0x404
> [    0.420000]  [<ffffffff81fa6b16>] kernel_init+0x16/0x1e0
> [    0.420000]  [<ffffffff81fd817c>] ret_from_fork+0x7c/0xb0
> [    0.420000]  [<ffffffff81fa6b00>] ? rest_init+0x140/0x140
> [    0.420000] Code: ff e9 33 fe ff ff b8 fe ff ff ff e9 29 fe ff ff 48 83 05 b3 1c 42 02 01 48 c7 c7 f8 90 df 82 4c 8b 63 30 48 83 05 60 16 42 02 01 <41> 0f b7 84 24 80 00 00 00 83 e0 0f 66 83 e8 01 41 0f 95 c5 31 
> [    0.420000] RIP  [<ffffffff81437700>] kobject_add_internal+0x720/0x940
> [    0.420000]  RSP <ffff88000035fdb8>
> [    0.420000] CR2: 0000000000000080
> [    0.420000] ---[ end trace ec833e17e878915c ]---
> [    0.420000] swapper/0 (1) used greatest stack depth: 4760 bytes left

> CONFIG_KERNFS=y
> # CONFIG_SYSFS is not set

Heh heh, it's 7bac9560a270 ("add CONFIG_KERNFS") allowing !SYSFS &&
KERNFS. kobject is getting nullops from sysfs but it also invokes
kernfs functions directly which expects its inputs to be valid leading
to the oops.  The only thing necessary is adding matching wrappers in
sysfs so that they can be noop too if !SYSFS.

Will fix it.  Thank you very much!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

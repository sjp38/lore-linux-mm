Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0576B0072
	for <linux-mm@kvack.org>; Thu, 28 May 2015 07:53:43 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so143588842wic.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 04:53:42 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id iz17si29191530wic.26.2015.05.28.04.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 04:53:41 -0700 (PDT)
Received: by wicmc15 with SMTP id mc15so121160143wic.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 04:53:41 -0700 (PDT)
Date: Thu, 28 May 2015 07:53:32 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: swap: nfs: Sleeping function called from an rcu read section in
 nfs_swap_activate
Message-ID: <20150528075332.6945fd09@synchrony.poochiereds.net>
In-Reply-To: <5564732E.4090607@redhat.com>
References: <5564732E.4090607@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/VPZ066Oa6ok3CTMlO2eJBgV"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Jeff Layton <jlayton@primarydata.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org

--MP_/VPZ066Oa6ok3CTMlO2eJBgV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tue, 26 May 2015 15:20:46 +0200
Jerome Marchand <jmarchan@redhat.com> wrote:

> 
> Commit dad2b015 added an rcu read lock around the call to xs_swapper()
> in nfs_activate()/deactivate(), which can sleep, thus raising a bug at
> each swapon and swapoff over NFS.
> I'm not sure if this is related or not, but swapoff also triggers the
> WARN_ON(sk->sk_forward_alloc) in sk_clear_memalloc().
> 
> [  243.668067] ===============================
> [  243.668665] [ INFO: suspicious RCU usage. ]
> [  243.669293] 4.1.0-rc1-lock_stat-dbg-next-20150430+ #235 Not tainted
> [  243.670301] -------------------------------
> [  243.670905] include/linux/rcupdate.h:570 Illegal context switch in RCU read-side critical section!
> [  243.672163] 
> other info that might help us debug this:
> 
> [  243.673025] 
> rcu_scheduler_active = 1, debug_locks = 0
> [  243.673565] 2 locks held by swapon/1176:
> [  243.673893]  #0:  (&sb->s_type->i_mutex_key#17){+.+.+.}, at: [<ffffffff812385e0>] SyS_swapon+0x2b0/0x1000
> [  243.674758]  #1:  (rcu_read_lock){......}, at: [<ffffffffa036fd75>] nfs_swap_activate+0x5/0x180 [nfs]
> [  243.675591] 
> stack backtrace:
> [  243.675957] CPU: 0 PID: 1176 Comm: swapon Not tainted 4.1.0-rc1-lock_stat-dbg-next-20150430+ #235
> [  243.676687] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  243.677179]  0000000000000000 00000000ef88d841 ffff88003327bcd8 ffffffff818861f0
> [  243.677854]  0000000000000000 ffff880078e38000 ffff88003327bd08 ffffffff8110d237
> [  243.678514]  0000000000000000 ffffffff81c650e4 0000000000000268 ffff880078e38000
> [  243.679171] Call Trace:
> [  243.679383]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  243.679811]  [<ffffffff8110d237>] lockdep_rcu_suspicious+0xe7/0x120
> [  243.680348]  [<ffffffff810df1bf>] ___might_sleep+0xaf/0x250
> [  243.680815]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> [  243.681279]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> [  243.681762]  [<ffffffff811e409c>] static_key_slow_inc+0x7c/0xc0
> [  243.682264]  [<ffffffff8171afa7>] sk_set_memalloc+0x27/0x30
> [  243.682736]  [<ffffffffa012f824>] xs_swapper+0x54/0x60 [sunrpc]
> [  243.683238]  [<ffffffffa036fe03>] nfs_swap_activate+0x93/0x180 [nfs]
> [  243.683760]  [<ffffffffa036fd75>] ? nfs_swap_activate+0x5/0x180 [nfs]
> [  243.684316]  [<ffffffff81238e04>] SyS_swapon+0xad4/0x1000
> [  243.684766]  [<ffffffff818911b0>] ? syscall_return+0x16/0x59
> [  243.685245]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  243.685743] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:616
> [  243.686439] in_atomic(): 1, irqs_disabled(): 0, pid: 1176, name: swapon
> [  243.687053] INFO: lockdep is turned off.
> [  243.687429] CPU: 0 PID: 1176 Comm: swapon Not tainted 4.1.0-rc1-lock_stat-dbg-next-20150430+ #235
> [  243.688313] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  243.688845]  0000000000000000 00000000ef88d841 ffff88003327bd08 ffffffff818861f0
> [  243.689570]  0000000000000000 ffff880078e38000 ffff88003327bd38 ffffffff810df29c
> [  243.690353]  ffff880000000001 ffffffff81c650e4 0000000000000268 0000000000000000
> [  243.691057] Call Trace:
> [  243.691315]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  243.691785]  [<ffffffff810df29c>] ___might_sleep+0x18c/0x250
> [  243.692306]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> [  243.692807]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> [  243.693346]  [<ffffffff811e409c>] static_key_slow_inc+0x7c/0xc0
> [  243.693887]  [<ffffffff8171afa7>] sk_set_memalloc+0x27/0x30
> [  243.694416]  [<ffffffffa012f824>] xs_swapper+0x54/0x60 [sunrpc]
> [  243.694959]  [<ffffffffa036fe03>] nfs_swap_activate+0x93/0x180 [nfs]
> [  243.695535]  [<ffffffffa036fd75>] ? nfs_swap_activate+0x5/0x180 [nfs]
> [  243.696193]  [<ffffffff81238e04>] SyS_swapon+0xad4/0x1000
> [  243.696699]  [<ffffffff818911b0>] ? syscall_return+0x16/0x59
> [  243.697299]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  243.702101] Adding 524284k swap on /mnt/swapfile512.  Priority:-2 extents:1 across:524284k FS
> [  325.151350] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:616
> [  325.152688] in_atomic(): 1, irqs_disabled(): 0, pid: 1199, name: swapoff
> [  325.153737] INFO: lockdep is turned off.
> [  325.154457] CPU: 1 PID: 1199 Comm: swapoff Not tainted 4.1.0-rc1-lock_stat-dbg-next-20150430+ #235
> [  325.156204] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  325.157120]  0000000000000000 00000000a7682b83 ffff88007ac3fce8 ffffffff818861f0
> [  325.158361]  0000000000000000 ffff880032434c00 ffff88007ac3fd18 ffffffff810df29c
> [  325.159592]  0000000000000000 ffffffff81c650e4 0000000000000268 0000000000000000
> [  325.160798] Call Trace:
> [  325.161251]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  325.162071]  [<ffffffff810df29c>] ___might_sleep+0x18c/0x250
> [  325.163073]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> [  325.163934]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> [  325.164927]  [<ffffffff8110a00f>] atomic_dec_and_mutex_lock+0x4f/0x70
> [  325.166020]  [<ffffffff811e4107>] __static_key_slow_dec+0x27/0xc0
> [  325.166942]  [<ffffffff811e41c6>] static_key_slow_dec+0x26/0x50
> [  325.167955]  [<ffffffff8171db3f>] sk_clear_memalloc+0x2f/0x80
> [  325.169075]  [<ffffffffa012f811>] xs_swapper+0x41/0x60 [sunrpc]
> [  325.170241]  [<ffffffffa0370447>] nfs_swap_deactivate+0x87/0x170 [nfs]
> [  325.171276]  [<ffffffffa03703c5>] ? nfs_swap_deactivate+0x5/0x170 [nfs]
> [  325.172349]  [<ffffffff81237547>] destroy_swap_extents+0x77/0x90
> [  325.173754]  [<ffffffff8123b225>] SyS_swapoff+0x215/0x600
> [  325.174726]  [<ffffffff81434deb>] ? trace_hardirqs_on_thunk+0x17/0x19
> [  325.175971]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  325.178052] ------------[ cut here ]------------
> [  325.178892] WARNING: CPU: 1 PID: 1199 at net/core/sock.c:364 sk_clear_memalloc+0x51/0x80()
> [  325.180363] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw iosf_mbi crct10dif_pclmul crc32_pclmul crc32c_intel ppdev ghash_clmulni_intel joydev nfsd parport_pc pcspkr virtio_console serio_raw virtio_balloon parport pvpanic i2c_piix4 acpi_cpufreq auth_rpcgss nfs_acl lockd grace sunrpc virtio_blk qxl virtio_net drm_kms_helper ttm drm virtio_pci virtio_ring virtio ata_generic pata_acpi floppy
> [  325.192279] CPU: 1 PID: 1199 Comm: swapoff Not tainted 4.1.0-rc1-lock_stat-dbg-next-20150430+ #235
> [  325.193605] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  325.194491]  0000000000000000 00000000a7682b83 ffff88007ac3fdf8 ffffffff818861f0
> [  325.195692]  0000000000000000 0000000000000000 ffff88007ac3fe38 ffffffff810af5ca
> [  325.196891]  ffff88007ac3fe78 ffff88007b068000 ffff88007b484a00 ffff88007b484aa8
> [  325.198119] Call Trace:
> [  325.198555]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  325.199380]  [<ffffffff810af5ca>] warn_slowpath_common+0x8a/0xc0
> [  325.200601]  [<ffffffff810af6fa>] warn_slowpath_null+0x1a/0x20
> [  325.201536]  [<ffffffff8171db61>] sk_clear_memalloc+0x51/0x80
> [  325.202468]  [<ffffffffa012f811>] xs_swapper+0x41/0x60 [sunrpc]
> [  325.203398]  [<ffffffffa0370447>] nfs_swap_deactivate+0x87/0x170 [nfs]
> [  325.204426]  [<ffffffffa03703c5>] ? nfs_swap_deactivate+0x5/0x170 [nfs]
> [  325.205456]  [<ffffffff81237547>] destroy_swap_extents+0x77/0x90
> [  325.206406]  [<ffffffff8123b225>] SyS_swapoff+0x215/0x600
> [  325.207287]  [<ffffffff81434deb>] ? trace_hardirqs_on_thunk+0x17/0x19
> [  325.208300]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  325.209248] ---[ end trace 13f1014b56e5e711 ]---
> 

Jerome,

Can you test the attached patch and let me know if this fixes the
problem? If so, then I'll send it on "officially" to Trond.

Thanks,
-- 
Jeff Layton <jeff.layton@primarydata.com>

--MP_/VPZ066Oa6ok3CTMlO2eJBgV
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-nfs-don-t-hold-rcu_read_lock-over-xs_swapper-call.patch


--MP_/VPZ066Oa6ok3CTMlO2eJBgV--

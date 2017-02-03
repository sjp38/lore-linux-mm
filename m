Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0766B0253
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 09:50:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so4197603wmu.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 06:50:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si32685690wra.300.2017.02.03.06.50.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 06:50:12 -0800 (PST)
Date: Fri, 3 Feb 2017 15:50:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170203145009.GB19325@dhcp22.suse.cz>
References: <20170125130014.GO32377@dhcp22.suse.cz>
 <20170127144906.GB4148@dhcp22.suse.cz>
 <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org

[Let's CC more xfs people]

On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
[...]
> (1) I got an assertion failure.

I suspect this is a result of
http://lkml.kernel.org/r/20170201092706.9966-2-mhocko@kernel.org
I have no idea what the assert means though.

> 
> [  969.626518] Killed process 6262 (oom-write) total-vm:2166856kB, anon-rss:1128732kB, file-rss:4kB, shmem-rss:0kB
> [  969.958307] oom_reaper: reaped process 6262 (oom-write), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  972.114644] XFS: Assertion failed: oldlen > newlen, file: fs/xfs/libxfs/xfs_bmap.c, line: 2867
> [  972.125085] ------------[ cut here ]------------
> [  972.129261] WARNING: CPU: 0 PID: 6280 at fs/xfs/xfs_message.c:105 asswarn+0x33/0x40 [xfs]
> [  972.136146] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack coretemp crct10dif_pclmul ppdev crc32_pclmul ghash_clmulni_intel ip_set nfnetlink ebtable_nat aesni_intel crypto_simd cryptd ebtable_broute glue_helper vmw_balloon bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 pcspkr nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter sg parport_pc parport shpchp i2c_piix4 vmw_vsock_vmci_transport vsock vmw_vmci ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect
> [  972.163630]  sysimgblt fb_sys_fops ttm drm ata_piix ahci libahci mptspi scsi_transport_spi mptscsih e1000 libata i2c_core mptbase
> [  972.172535] CPU: 0 PID: 6280 Comm: write Not tainted 4.10.0-rc6-next-20170202 #498
> [  972.175126] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> [  972.178381] Call Trace:
> [  972.180003]  dump_stack+0x85/0xc9
> [  972.181682]  __warn+0xd1/0xf0
> [  972.183374]  warn_slowpath_null+0x1d/0x20
> [  972.185223]  asswarn+0x33/0x40 [xfs]
> [  972.186950]  xfs_bmap_add_extent_hole_delay+0xb7f/0xdf0 [xfs]
> [  972.189055]  xfs_bmapi_reserve_delalloc+0x297/0x440 [xfs]
> [  972.191263]  ? xfs_ilock+0x1c9/0x360 [xfs]
> [  972.193414]  xfs_file_iomap_begin+0x880/0x1140 [xfs]
> [  972.195300]  ? iomap_write_end+0x80/0x80
> [  972.196980]  iomap_apply+0x6c/0x130
> [  972.198539]  iomap_file_buffered_write+0x68/0xa0
> [  972.200316]  ? iomap_write_end+0x80/0x80
> [  972.201950]  xfs_file_buffered_aio_write+0x132/0x390 [xfs]
> [  972.203868]  ? _raw_spin_unlock+0x27/0x40
> [  972.205470]  xfs_file_write_iter+0x90/0x130 [xfs]
> [  972.207167]  __vfs_write+0xe5/0x140
> [  972.208752]  vfs_write+0xc7/0x1f0
> [  972.210233]  ? syscall_trace_enter+0x1d0/0x380
> [  972.211809]  SyS_write+0x58/0xc0
> [  972.213166]  do_int80_syscall_32+0x6c/0x1f0
> [  972.214676]  entry_INT80_compat+0x38/0x50
> [  972.216168] RIP: 0023:0x8048076
> [  972.217494] RSP: 002b:00000000ff997020 EFLAGS: 00000202 ORIG_RAX: 0000000000000004
> [  972.219635] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 0000000008048000
> [  972.221679] RDX: 0000000000001000 RSI: 0000000000000000 RDI: 0000000000000000
> [  972.223774] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
> [  972.225905] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> [  972.227946] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> [  972.230064] ---[ end trace d498098daec56c11 ]---
> [  984.210890] vmtoolsd invoked oom-killer: gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null),  order=0, oom_score_adj=0
> [  984.224191] vmtoolsd cpuset=/ mems_allowed=0
> [  984.231022] CPU: 0 PID: 689 Comm: vmtoolsd Tainted: G        W       4.10.0-rc6-next-20170202 #498
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

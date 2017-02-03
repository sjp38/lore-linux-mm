Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 056946B025E
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 12:24:08 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d15so3133483qke.1
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 09:24:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m65si19678241qtd.323.2017.02.03.09.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 09:24:06 -0800 (PST)
Date: Fri, 3 Feb 2017 12:24:04 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170203172403.GG45388@bfoster.bfoster>
References: <20170125130014.GO32377@dhcp22.suse.cz>
 <20170127144906.GB4148@dhcp22.suse.cz>
 <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
 <20170203145009.GB19325@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170203145009.GB19325@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org

On Fri, Feb 03, 2017 at 03:50:09PM +0100, Michal Hocko wrote:
> [Let's CC more xfs people]
> 
> On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
> [...]
> > (1) I got an assertion failure.
> 
> I suspect this is a result of
> http://lkml.kernel.org/r/20170201092706.9966-2-mhocko@kernel.org
> I have no idea what the assert means though.
> 
> > 
> > [  969.626518] Killed process 6262 (oom-write) total-vm:2166856kB, anon-rss:1128732kB, file-rss:4kB, shmem-rss:0kB
> > [  969.958307] oom_reaper: reaped process 6262 (oom-write), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  972.114644] XFS: Assertion failed: oldlen > newlen, file: fs/xfs/libxfs/xfs_bmap.c, line: 2867

Indirect block reservation underrun on delayed allocation extent merge.
These are extra blocks are used for the inode bmap btree when a delalloc
extent is converted to physical blocks. We're in a case where we expect
to only ever free excess blocks due to a merge of extents with
independent reservations, but a situation occurs where we actually need
blocks and hence the assert fails. This can occur if an extent is merged
with one that has a reservation less than the expected worst case
reservation for its size (due to previous extent splits due to hole
punches, for example). Therefore, I think the core expectation that
xfs_bmap_add_extent_hole_delay() will always have enough blocks
pre-reserved is invalid.

Can you describe the workload that reproduces this? FWIW, I think the
way xfs_bmap_add_extent_hole_delay() currently works is likely broken
and have a couple patches to fix up indlen reservation that I haven't
posted yet. The diff that deals with this particular bit is appended.
Care to give that a try?

Brian

> > [  972.125085] ------------[ cut here ]------------
> > [  972.129261] WARNING: CPU: 0 PID: 6280 at fs/xfs/xfs_message.c:105 asswarn+0x33/0x40 [xfs]
> > [  972.136146] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack coretemp crct10dif_pclmul ppdev crc32_pclmul ghash_clmulni_intel ip_set nfnetlink ebtable_nat aesni_intel crypto_simd cryptd ebtable_broute glue_helper vmw_balloon bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 pcspkr nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter sg parport_pc parport shpchp i2c_piix4 vmw_vsock_vmci_transport vsock vmw_vmci ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect
> > [  972.163630]  sysimgblt fb_sys_fops ttm drm ata_piix ahci libahci mptspi scsi_transport_spi mptscsih e1000 libata i2c_core mptbase
> > [  972.172535] CPU: 0 PID: 6280 Comm: write Not tainted 4.10.0-rc6-next-20170202 #498
> > [  972.175126] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> > [  972.178381] Call Trace:
...

---8<---

diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
index bfc00de..d2e48ed 100644
--- a/fs/xfs/libxfs/xfs_bmap.c
+++ b/fs/xfs/libxfs/xfs_bmap.c
@@ -2809,7 +2809,8 @@ xfs_bmap_add_extent_hole_delay(
 		oldlen = startblockval(left.br_startblock) +
 			startblockval(new->br_startblock) +
 			startblockval(right.br_startblock);
-		newlen = xfs_bmap_worst_indlen(ip, temp);
+		newlen = XFS_FILBLKS_MIN(xfs_bmap_worst_indlen(ip, temp),
+					 oldlen);
 		xfs_bmbt_set_startblock(xfs_iext_get_ext(ifp, *idx),
 			nullstartblock((int)newlen));
 		trace_xfs_bmap_post_update(ip, *idx, state, _THIS_IP_);
@@ -2830,7 +2831,8 @@ xfs_bmap_add_extent_hole_delay(
 		xfs_bmbt_set_blockcount(xfs_iext_get_ext(ifp, *idx), temp);
 		oldlen = startblockval(left.br_startblock) +
 			startblockval(new->br_startblock);
-		newlen = xfs_bmap_worst_indlen(ip, temp);
+		newlen = XFS_FILBLKS_MIN(xfs_bmap_worst_indlen(ip, temp),
+					 oldlen);
 		xfs_bmbt_set_startblock(xfs_iext_get_ext(ifp, *idx),
 			nullstartblock((int)newlen));
 		trace_xfs_bmap_post_update(ip, *idx, state, _THIS_IP_);
@@ -2846,7 +2848,8 @@ xfs_bmap_add_extent_hole_delay(
 		temp = new->br_blockcount + right.br_blockcount;
 		oldlen = startblockval(new->br_startblock) +
 			startblockval(right.br_startblock);
-		newlen = xfs_bmap_worst_indlen(ip, temp);
+		newlen = XFS_FILBLKS_MIN(xfs_bmap_worst_indlen(ip, temp),
+					 oldlen);
 		xfs_bmbt_set_allf(xfs_iext_get_ext(ifp, *idx),
 			new->br_startoff,
 			nullstartblock((int)newlen), temp, right.br_state);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA0C6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:02:02 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id o10so5286277eaj.25
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 12:02:01 -0800 (PST)
Received: from trent.utfs.org (trent.utfs.org. [2a03:3680:0:3::67])
        by mx.google.com with ESMTP id x3si6033359eea.139.2014.02.13.12.02.00
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 12:02:00 -0800 (PST)
Date: Thu, 13 Feb 2014 12:01:56 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: 3.14.0-rc2: WARNING: at mm/slub.c:1007
In-Reply-To: <alpine.DEB.2.19.4.1402131144390.6233@trent.utfs.org>
Message-ID: <alpine.DEB.2.19.4.1402131158590.6233@trent.utfs.org>
References: <alpine.DEB.2.19.4.1402131144390.6233@trent.utfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com
Cc: linux-mm@kvack.org

On Thu, 13 Feb 2014 at 11:53, Christian Kujau wrote:
> after upgrading from 3.13-rc8 to 3.14.0-rc2 on this PowerPC G4 machine, 
> the WARNING below was printed.
> 
> Shortly after, a lockdep warning appeared (possibly related to my 
> post to the XFS list yesterday[0]).

Sigh, only _after_ sending the email, I came across an earlier posting on 
lkml: http://marc.info/?l=linux-mm&m=139145788623391

Sorry for the noise. These out-of-memory messages below appeared without 
the WARNING though and started somewhere in 3.13, but are impossible to 
bisect, as they're happening only every few days / weeks.

Christian.

> Even later in the log an out-of-memory error appeared, that may or may not 
> be relatd to that WARNING at all but which I'm trying to chase down ever 
> since 3.13, but which tends to appear more often lately.
> 
> Can anyone take a look if this is something to worry about?
> 
> Full dmesg & .config: http://nerdbynature.de/bits/3.14-rc2/mm/
> 
> Thanks,
> Christian.
> 
> [0] http://oss.sgi.com/pipermail/xfs/2014-February/034054.html
> 
>  ------------[ cut here ]------------
>  WARNING: at /usr/local/src/linux-git/mm/slub.c:1007
>  Modules linked in: md5 ecb nfs i2c_powermac therm_adt746x ecryptfs arc4 
> firewire_sbp2 b43 usb_storage mac80211 cfg80211
>  CPU: 0 PID: 9025 Comm: nfsd Not tainted 3.14.0-rc2 #1
>  task: efbf8000 ti: ed2a0000 task.ti: ed2a0000
>  NIP: c00ccc28 LR: c00ccc20 CTR: 00000000
>  REGS: ed2a1980 TRAP: 0700   Not tainted  (3.14.0-rc2)
>  MSR: 00021032 <ME,IR,DR,RI>  CR: 22f82b82  XER: 20000000
>  
>  GPR00: c00ccc20 ed2a1a30 efbf8000 00000000 ef96e550 00000000 00000000 
> 00002ce0 
>  GPR08: 00000000 00000001 efbf86f8 000005e7 82fc2b88 00000000 00000001 
> 00080011 
>  GPR16: 00000000 00000000 c0760000 00000000 ef96e564 00100100 00200200 
> c1203914 
>  GPR24: 00000000 ef96e540 00000002 ef96fa80 00000000 00000000 ed2a0000 
> c1203900 
>  NIP [c00ccc28] deactivate_slab+0x4c0/0x538
>  LR [c00ccc20] deactivate_slab+0x4b8/0x538
>  Call Trace:
>  [ed2a1a30] [c00ccc20] deactivate_slab+0x4b8/0x538 (unreliable)
>  [ed2a1ae0] [c055d5f0] __slab_alloc.constprop.77+0x260/0x38c
>  [ed2a1b50] [c00cd524] kmem_cache_alloc+0x118/0x140
>  [ed2a1b70] [c01de4bc] kmem_zone_alloc+0x94/0x108
>  [ed2a1ba0] [c01cccd4] xfs_inode_alloc+0x2c/0xd4
>  [ed2a1bc0] [c01cd7a4] xfs_iget+0x2e4/0x584
>  [ed2a1c30] [c020e664] xfs_lookup+0xc8/0xe4
>  [ed2a1c70] [c01d3c28] xfs_vn_lookup+0x64/0xbc
>  [ed2a1c90] [c00db3ac] lookup_real+0x30/0x70
>  [ed2a1ca0] [c00dc384] __lookup_hash+0x3c/0x58
>  [ed2a1cc0] [c00e1438] lookup_one_len+0x10c/0x15c
>  [ed2a1ce0] [c01a170c] nfsd4_encode_dirent+0xb4/0x328
>  [ed2a1d10] [c018f580] nfsd_readdir+0x1d4/0x288
>  [ed2a1d90] [c019d648] nfsd4_encode_readdir+0x138/0x1f4
>  [ed2a1dd0] [c01a1b18] nfsd4_encode_operation+0x8c/0xf0
>  [ed2a1df0] [c019aa4c] nfsd4_proc_compound+0x1b8/0x4f8
>  [ed2a1e30] [c0189d20] nfsd_dispatch+0x90/0x1a0
>  [ed2a1e50] [c0536b04] svc_process+0x3d0/0x698
>  [ed2a1e90] [c01895bc] nfsd+0xc0/0x120
>  [ed2a1eb0] [c004f8fc] kthread+0xbc/0xd0
>  [ed2a1f40] [c0010ae4] ret_from_kernel_thread+0x5c/0x64
>  Instruction dump:
>  7fe4fb78 800100b4 b9c10068 7d810120 7d808120 7c0803a6 382100b0 4bfffb00 
>  80610048 4bf95dc5 2f830000 40beff4c <0fe00000> 4bffff44 815e000c 394a0001 
>  ---[ end trace 1f5ed3ea8b3e4403 ]---
> 
> 
> -- 
> BOFH excuse #65:
> 
> system needs to be rebooted
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs
> 

-- 
BOFH excuse #65:

system needs to be rebooted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

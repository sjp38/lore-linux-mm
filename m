Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id B313B6B00FC
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 02:46:16 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so2336783pbc.1
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 23:46:16 -0800 (PST)
Received: from psmtp.com ([74.125.245.203])
        by mx.google.com with SMTP id bc2si18855105pad.274.2013.11.11.23.46.14
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 23:46:15 -0800 (PST)
Message-ID: <5281DC82.8010704@redhat.com>
Date: Tue, 12 Nov 2013 15:45:06 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: WARNING: CPU: 8 PID: 12860 at net/core/sock.c:313 sk_clear_memalloc+0x49/0x70()
References: <988917896.22733181.1384226183266.JavaMail.root@redhat.com>
In-Reply-To: <988917896.22733181.1384226183266.JavaMail.root@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, netdev@vger.kernel.org

CC'ing netdev@ to make more relative people know it.

On 11/12/2013 11:16 AM, Zhouping Liu wrote:
> Hi All,
>
> I found the WARNING in the latest mainline with commint 8b5baa460b.
>
> [61323.305424] ------------[ cut here ]------------
> [61323.310562] WARNING: CPU: 8 PID: 12860 at net/core/sock.c:313 sk_clear_memalloc+0x49/0x70()
> [61323.319779] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache sg nfsd netxen_nic hpilo sp5100_tco auth_rpcgss hpwdt amd64_edac_mod edac_mce_amd microcode pcspkr shpchp serio_raw i2c_piix4 edac_core ipmi_si k10temp nfs_acl lockd ipmi_msghandler acpi_power_meter acpi_cpufreq sunrpc xfs libcrc32c radeon i2c_algo_bit drm_kms_helper ttm sd_mod crc_t10dif ata_generic crct10dif_common drm pata_acpi ahci libahci pata_atiixp libata i2c_core hpsa dm_mirror dm_region_hash dm_log dm_mod
> [61323.368625] CPU: 8 PID: 12860 Comm: swapoff Not tainted 3.12.0+ #1
> [61323.375452] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/17/2012
> [61323.382463]  0000000000000009 ffff882dfce43e68 ffffffff816204b7 0000000000000000
> [61323.390692]  ffff882dfce43ea0 ffffffff8106495d ffff88190b551d00 ffff88080ff0b600
> [61323.398940]  ffff88080ff0b650 0000000000000001 ffff880810fe64a0 ffff882dfce43eb0
> [61323.407188] Call Trace:
> [61323.409916]  [] dump_stack+0x45/0x56
> [61323.415616]  [] warn_slowpath_common+0x7d/0xa0
> [61323.422257]  [] warn_slowpath_null+0x1a/0x20
> [61323.428705]  [] sk_clear_memalloc+0x49/0x70
> [61323.435094]  [] xs_swapper+0x41/0x60 [sunrpc]
> [61323.441671]  [] nfs_swap_deactivate+0x2d/0x30 [nfs]
> [61323.448796]  [] destroy_swap_extents+0x61/0x70
> [61323.455436]  [] SyS_swapoff+0x220/0x610
> [61323.461420]  [] ? do_page_fault+0x1a/0x70
> [61323.467582]  [] system_call_fastpath+0x16/0x1b
> [61323.474215] ---[ end trace 919f685513b38356 ]---
>
> I found the warning during doing swapoff the swap over NFS mount, so if you need to reproduce it,
> you should do the following:
> 1. Open CONFIG_NFS_SWAP in testing machine
> 2. Create a NFS server, and create a swap file in NFS server
>     in NFS server: # dd if=/dev/zero of=/NFS_FOLDER/swapfile bs=1M count=1024; mkswap swapfile
> 3. Inside testing machine, setup a swap over NFS, then swapoff it, the swapoff action will
>     trigger the WARNING.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

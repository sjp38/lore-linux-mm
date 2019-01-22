Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 617308E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 18:47:12 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id l7so224224ywh.16
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 15:47:12 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id z18si9681810ybg.481.2019.01.22.15.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 15:47:11 -0800 (PST)
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
References: <20190122154407.18417-1-osalvador@suse.de>
From: Anthony Yznaga <anthony.yznaga@oracle.com>
Message-ID: <064eddf2-abc2-a089-f6c9-490ca3145647@oracle.com>
Date: Tue, 22 Jan 2019 15:47:00 -0800
MIME-Version: 1.0
In-Reply-To: <20190122154407.18417-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com, david@redhat.com



On 1/22/19 7:44 AM, Oscar Salvador wrote:
> This is the same sort of error we saw in [1].
>
> Gigantic hugepages crosses several memblocks, so it can be
> that the page we get in scan_movable_pages() is a page-tail
> belonging to a 1G-hugepage.
> If that happens, page_hstate()->size_to_hstate() will return NULL,
> and we will blow up in hugepage_migration_supported().
>
> The splat is as follows:
>
> kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> kernel: #PF error: [normal kernel read fault]
> kernel: PGD 0 P4D 0
> kernel: Oops: 0000 [#1] SMP PTI
> kernel: CPU: 1 PID: 1350 Comm: bash Tainted: G            E     5.0.0-rc1-mm1-1-default+ #27
> kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
> kernel: RIP: 0010:__offline_pages+0x6ae/0x900
> kernel: Code: 48 c7 c6 d0 3e a4 81 e8 44 c8 ad ff 49 8b 04 24 bf 00 10 00 00 a9 00 00 01 00 74 09 41 0f b6 4c 24 51 48 d3 e7 e8 42 2a c1 ff <8b> 40 08 83 f8 09 0f 84 b0 fc ff ff 83 f8 12 0f 84 a7 fc ff ff 83
> kernel: RSP: 0018:ffffc900008e3d20 EFLAGS: 00010246
> kernel: RAX: 0000000000000000 RBX: ffffea0000000000 RCX: 0000000000000009
> kernel: RDX: ffffffff825c64f0 RSI: 0000000000001000 RDI: 0000000000001000
> kernel: RBP: ffffc900008e3d68 R08: 0000000000200000 R09: 00000000000001e4
> kernel: R10: 0000000000000058 R11: ffffffff8254a854 R12: ffffea0004200000
> kernel: R13: 0000000000108000 R14: 0000000000110000 R15: 0000000000000000
> kernel: FS:  00007ff172339b80(0000) GS:ffff88803eb00000(0000) knlGS:0000000000000000
> kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> kernel: CR2: 0000000000000008 CR3: 0000000038d78006 CR4: 00000000003606a0
> kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> kernel: Call Trace:
> kernel:  ? klist_next+0x79/0xe0
> kernel:  memory_subsys_offline+0x42/0x60
> kernel:  device_offline+0x80/0xa0
> kernel:  state_store+0xab/0xc0
> kernel:  kernfs_fop_write+0x102/0x180
> kernel:  __vfs_write+0x26/0x190
> kernel:  ? set_close_on_exec+0x49/0x70
> kernel:  vfs_write+0xad/0x1b0
> kernel:  ksys_write+0x42/0x90
> kernel:  do_syscall_64+0x5b/0x180
> kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> kernel: RIP: 0033:0x7ff1719febe4
> kernel: Code: 00 f7 d8 64 89 02 48 c7 c0 ff ff ff ff eb b7 0f 1f 80 00 00 00 00 8b 05 4a fc 2c 00 48 63 ff 85 c0 75 13 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 54 f3 c3 66 90 55 53 48 89 d5 48 89 f3 48 83
> kernel: RSP: 002b:00007ffd50b7ddc8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> kernel: RAX: ffffffffffffffda RBX: 0000000000000008 RCX: 00007ff1719febe4
> kernel: RDX: 0000000000000008 RSI: 00005556e9216b20 RDI: 0000000000000001
> kernel: RBP: 00005556e9216b20 R08: 000000000000000a R09: 0000000000000000
> kernel: R10: 000000000000000a R11: 0000000000000246 R12: 0000000000000008
> kernel: R13: 0000000000000001 R14: 00007ff171cca720 R15: 0000000000000008
> kernel: Modules linked in: af_packet(E) xt_tcpudp(E) ipt_REJECT(E) xt_conntrack(E) nf_conntrack(E) nf_defrag_ipv4(E) ip_set(E) nfnetlink(E) ebtable_nat(E) ebtable_broute(E) bridge(E) stp(E) llc(E) iptable_mangle(E) iptable_raw(E) iptable_security(E) ebtable_filter(E) ebtables(E) iptable_filter(E) ip_tables(E) x_tables(E) kvm_intel(E) kvm(E) irqbypass(E) crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) bochs_drm(E) ttm(E) aesni_intel(E) drm_kms_helper(E) aes_x86_64(E) crypto_simd(E) cryptd(E) glue_helper(E) drm(E) virtio_net(E) syscopyarea(E) sysfillrect(E) net_failover(E) sysimgblt(E) pcspkr(E) failover(E) i2c_piix4(E) fb_sys_fops(E) parport_pc(E) parport(E) button(E) btrfs(E) libcrc32c(E) xor(E) zstd_decompress(E) zstd_compress(E) xxhash(E) raid6_pq(E) sd_mod(E) ata_generic(E) ata_piix(E) ahci(E) libahci(E) libata(E) crc32c_intel(E) serio_raw(E) virtio_pci(E) virtio_ring(E) virtio(E) sg(E) scsi_mod(E) autofs4(E)
> kernel: CR2: 0000000000000008
> kernel: ---[ end trace bdb71590872849fb ]---
> kernel: RIP: 0010:__offline_pages+0x6ae/0x900
> kernel: Code: 48 c7 c6 d0 3e a4 81 e8 44 c8 ad ff 49 8b 04 24 bf 00 10 00 00 a9 00 00 01 00 74 09 41 0f b6 4c 24 51 48 d3 e7 e8 42 2a c1 ff <8b> 40 08 83 f8 09 0f 84 b0 fc ff ff 83 f8 12 0f 84 a7 fc ff ff 83
> kernel: RSP: 0018:ffffc900008e3d20 EFLAGS: 00010246
> kernel: RAX: 0000000000000000 RBX: ffffea0000000000 RCX: 0000000000000009
> kernel: RDX: ffffffff825c64f0 RSI: 0000000000001000 RDI: 0000000000001000
> kernel: RBP: ffffc900008e3d68 R08: 0000000000200000 R09: 00000000000001e4
> kernel: R10: 0000000000000058 R11: ffffffff8254a854 R12: ffffea0004200000
> kernel: R13: 0000000000108000 R14: 0000000000110000 R15: 0000000000000000
> kernel: FS:  00007ff172339b80(0000) GS:ffff88803eb00000(0000) knlGS:0000000000000000
> kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> kernel: CR2: 0000000000000008 CR3: 0000000038d78006 CR4: 00000000003606a0
> kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>
> Fix this by getting the head page and testing against it.
>
> [1] https://patchwork.kernel.org/patch/10739963/
>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Looks good.

Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>

> ---
>  mm/memory_hotplug.c | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index ec22c86d9f89..25aee4f04a72 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1335,12 +1335,17 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  			if (__PageMovable(page))
>  				return pfn;
>  			if (PageHuge(page)) {
> -				if (hugepage_migration_supported(page_hstate(page)) &&
> -				    page_huge_active(page))
> +				struct page *head = compound_head(page);
> +
> +				if (hugepage_migration_supported(page_hstate(head)) &&
> +				    page_huge_active(head))
>  					return pfn;
> -				else
> -					pfn = round_up(pfn + 1,
> -						1 << compound_order(page)) - 1;
> +				else {
> +					unsigned long skip;
> +
> +					skip = (1 << compound_order(head)) - (page - head);
> +					pfn += skip - 1;
> +				}
>  			}
>  		}
>  	}

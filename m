Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 046906B02E6
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 23:55:47 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id m39so4405355plg.19
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 20:55:46 -0800 (PST)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id q24si5122385pfi.54.2018.01.05.20.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 20:55:45 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <ac54449b-feeb-58d2-45e6-5ebb9784ed13@huawei.com>
Date: Sat, 6 Jan 2018 12:54:36 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

Hi Jiri,

Thanks for the fix, comments inline.

On 2018/1/6 2:19, Jiri Kosina wrote:
> 
> [ adding Hugh ]
> 
> On Thu, 4 Jan 2018, Dave Hansen wrote:
> 
>>> BTW, we have just reported a bug caused by kaiser[1], which looks like
>>> caused by SMEP. Could you please help to have a look?
>>>
>>> [1] https://lkml.org/lkml/2018/1/5/3
>>
>> Please report that to your kernel vendor.  Your EFI page tables have the
>> NX bit set on the low addresses.  There have been a bunch of iterations
>> of this, but you need to make sure that the EFI kernel mappings don't
>> get _PAGE_NX set on them.  Look at what __pti_set_user_pgd() does in
>> mainline.
> 
> Unfortunately this is more complicated.
> 
> The thing is -- efi=old_memmap is broken even upstream. We will probably 
> not receive too many reports about this against upstream PTI, as most of 
> the machines are using classic high-mapping of EFI regions; but older 
> kernels force on certain machines stil old_memmap (or it can be specified 
> manually on kernel cmdline), where EFI has all its mapping in the 
> userspace range.
> 
> And that explodes, as those get marked NX in the kernel pagetables.
> 
> I've spent most of today tracking this down (the legacy EFI mmap is 
> horrid); the patch below is confirmed to fix it both on current upstream 
> kernel, as well as on original-KAISER based kernels (Hugh's backport) in 
> cases old_memmap is used by EFI.
> 
> I am not super happy about this, but I din't really want to extend the 
> _set_pgd() code to always figure out whether it's dealing wih low EFI 
> mapping or not, as that would be way too much overhead just for this 
> one-off call during boot.
> 
> 
> 
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] PTI: unbreak EFI old_memmap
> 
> old_memmap's efi_call_phys_prolog() calls set_pgd() with swapper PGD that 
> has PAGE_USER set, which makes PTI set NX on it, and therefore EFI can't 
> execute it's code.
> 
> Fix that by forcefully clearing _PAGE_NX from the PGD (this can't be done
> by the pgprot API).
> 
> _PAGE_NX will be automatically reintroduced in efi_call_phys_epilog(), as 
> _set_pgd() will again notice that this is _PAGE_USER, and set _PAGE_NX on 
> it.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  arch/x86/platform/efi/efi_64.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> --- a/arch/x86/platform/efi/efi_64.c
> +++ b/arch/x86/platform/efi/efi_64.c
> @@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
>  		save_pgd[pgd] = *pgd_offset_k(pgd * PGDIR_SIZE);
>  		vaddress = (unsigned long)__va(pgd * PGDIR_SIZE);
>  		set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress));
> +		/*
> +		 * pgprot API doesn't clear it for PGD
> +		 *
> +		 * Will be brought back automatically in _epilog()
> +		 */
> +		pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;

Do you mean NX bit will be brought back later? I'm asking this because
I tested this patch which it fixed the boot panic issue but the system
will hang when rebooting the system, because rebooting will also call efi
then panic as NS bit is set.

[ 1911.622675] BUG: unable to handle kernel paging request at 00000000008041c0
[ 1911.629880] IP: [<00000000008041c0>] 0x8041bf
[ 1911.634389] PGD 80000010272cb067 PUD 2025178067 PMD 10272d8067 PTE 804063
[ 1911.641472] Oops: 0011 [#1] SMP
[ 1911.711748] Modules linked in: bum(O) ip_set nfnetlink prio(O) nat(O) vport_vxlan(O) openvswitch(O) nf_defrag_ipv6 gre kboxdriver(O) kbox(O) signo_catch(O) vfat fat tg3 intel_powerclamp coretemp intel_rapl crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel i2c_i801 kvm_intel(O) ptp lrw gf128mul i2c_core glue_helper ablk_helper pps_core kvm(O) cryptd iTCO_wdt iTCO_vendor_support sg pcspkr lpc_ich mfd_core sb_edac mei_me edac_core mei shpchp acpi_power_meter acpi_pad remote_trigger(O) nf_conntrack_ipv4 nf_defrag_ipv4 vhost_net(O) tun(O) vhost(O) macvtap macvlan vfio_pci irqbypass vfio_iommu_type1 vfio xt_sctp nf_conntrack_proto_sctp nf_nat_proto_sctp nf_nat nf_conntrack sctp libcrc32c ip_tables ext3 mbcache jbd sr_mod sd_mod cdrom lpfc crc_t10dif ahci crct10dif_generic crct10dif_pclmul libahci scsi_transport_fc scsi_tgt crct10dif_common libata usb_storage megaraid_sas dm_mod [last unloaded: dev_connlimit]
[ 1911.796711] CPU: 0 PID: 12033 Comm: reboot Tainted: G           OE  ---- -------   3.10.0-327.61.59.66_22.x86_64 #1
[ 1911.807449] Hardware name: Huawei RH2288H V3/BC11HGSA0, BIOS 3.79 11/07/2017
[ 1911.814702] task: ffff881025a91700 ti: ffff8810267fc000 task.ti: ffff8810267fc000
[ 1911.822401] RIP: 0010:[<00000000008041c0>]  [<00000000008041c0>] 0x8041bf
[ 1911.829407] RSP: 0018:ffff8810267ffd50  EFLAGS: 00010086
[ 1911.834877] RAX: 00000000008041c0 RBX: 0000000000000000 RCX: ffffffffff425000
[ 1911.842220] RDX: ffff8820a4e40000 RSI: 000000000000c000 RDI: 0000002024e40000
[ 1911.849563] RBP: ffff8810267ffd60 R08: ffff882024e40000 R09: 0000000000000000
[ 1911.856908] R10: ffffffff81a8f300 R11: ffff8810267ffaae R12: 0000000028121969
[ 1911.864250] R13: ffffffff819aa8a0 R14: 0000000000000cf9 R15: 0000000000000000
[ 1911.871596] FS:  00007f89d6143880(0000) GS:ffff881040400000(0000) knlGS:0000000000000000
[ 1911.879921] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1911.885836] CR2: 00000000008041c0 CR3: 0000002024e40000 CR4: 00000000001607f0
[ 1911.893180] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1911.900522] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1911.907863] Call Trace:
[ 1911.910384]  [<ffffffff810241ab>] ? tboot_shutdown+0x5b/0x140
[ 1911.916298]  [<ffffffff8104723c>] native_machine_emergency_restart+0x4c/0x250
[ 1911.923641]  [<ffffffff8104c102>] ? disconnect_bsp_APIC+0x82/0xc0
[ 1911.929913]  [<ffffffff81046e17>] native_machine_restart+0x37/0x40
[ 1911.936273]  [<ffffffff810470ef>] machine_restart+0xf/0x20
[ 1911.941923]  [<ffffffff8109af95>] kernel_restart+0x45/0x60
[ 1911.947570]  [<ffffffff8109b1d9>] SYSC_reboot+0x229/0x260
[ 1911.953132]  [<ffffffff811ef665>] ? vfs_writev+0x35/0x60
[ 1911.958603]  [<ffffffff8109b27e>] SyS_reboot+0xe/0x10
[ 1911.963806]  [<ffffffff8165e43d>] system_call_fastpath+0x16/0x1b
[ 1911.969987] Code:  Bad RIP value.
[ 1911.973448] RIP  [<00000000008041c0>] 0x8041bf
[ 1911.978044]  RSP <ffff8810267ffd50>
[ 1911.990106] CR2: 00000000008041c0
[ 1912.001889] ---[ end trace e8475aee26ff7d9f ]---
[ 1912.408111] Kernel panic - not syncing: Fatal exception

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

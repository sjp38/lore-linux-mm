Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0F72A6B0255
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 17:02:38 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so53786525pab.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 14:02:37 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id ro16si7214322pab.99.2015.12.02.14.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 14:02:37 -0800 (PST)
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
 <562AA15E.3010403@deltatee.com>
 <CAPcyv4gQ-8-tL-rhAPzPxKzBLmWKnFcqSFVy4KVOM56_9gn6RA@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <565F6A7A.4040302@deltatee.com>
Date: Wed, 2 Dec 2015 15:02:34 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gQ-8-tL-rhAPzPxKzBLmWKnFcqSFVy4KVOM56_9gn6RA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2 00/20] get_user_pages() for dax mappings
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Stephen Bates <Stephen.Bates@pmcs.com>

On 30/11/15 03:15 PM, Dan Williams wrote:
> I appreciate the test report.  I appreciate it so much I wonder if
> you'd be willing to re-test the current state of:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending


Hi Dan,

I've had some mixed success with the above branch. Many of my tests are 
working but I have the following two issues which I didn't see previously:

* When trying to do RDMA transfers to a mmaped DAX file I get a kernel 
panic while de-registering the memory region. (The panic message is at 
the end of this email.) addr2line puts it around dax.c:723 for the first 
line in the call trace, the address where the failure occurs doesn't 
seem to map to a line of code.

* Less important: my tests no longer work inside qemu because I'm using 
a region in the PCI bar space which is not on a section boundary. The 
latest code enforces that restriction which makes it harder to use with 
PCI memory. (I'm talking memremap.c:311). Presently, if I comment out 
the check, my VM tests work fine. This hasn't been a problem on real 
hardware as we are using a 64bit address space and thus the BAR 
addresses are better aligned.


I don't have much time at the moment to dig into the kernel panic myself 
so hopefully what I've provided will help you find the issue. If you 
need any more information let me know.

Thanks,

Logan





> [ 1542.406591] BUG: unable to handle kernel paging request at 00000000300000d1
> [ 1542.406627] IP: [<ffffffffa033be40>] ext4_end_io_unwritten+0x10/0x60 [ext4]
> [ 1542.406661] PGD 260d27067 PUD 2602aa067 PMD 0
> [ 1542.406701] Oops: 0000 [#1] SMP
> [ 1542.406729] Modules linked in: mem_map(O) mtramonb(O) xt_conntrack ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter ip_tables x_tables br_netfilter nf_nat nf_conntrack bridge stp llc dm_thin_pool dm_persistent_data dm_bio_prison dm_bufio libcrc32c binfmt_misc nfsd auth_rpcgss oid_registry nfs_acl nfs lockd grace fscache sunrpc ext2 x86_pkg_temp_thermal coretemp kvm_intel kvm irqbypass sha256_generic iTCO_wdt iTCO_vendor_support hmac drbg ansi_cprng aesni_intel aes_x86_64 ablk_helper cryptd lrw sb_edac nvme gf128mul glue_helper ipmi_si edac_core psmouse joydev evdev lpc_ich i2c_i801 pcspkr serio_raw mfd_core wmi ipmi_msghandler acpi_cpufreq tpm_tis tpm ioatdma processor shpchp button iw_cxgb4 cxgb4 rdma_ucm ib_uverbs rdma_cm
> [ 1542.407293] iw_cm ib_ipoib ib_cm ib_umad mlx4_ib ib_sa ib_mad ib_core ib_addr msr loop fuse autofs4 ext4 mbcache jbd2 btrfs xor raid6_pq dm_mod md_mod ohci_hcd uhci_hcd xhci_hcd sg sd_mod hid_generic usbhid hid isci ahci libsas libahci igb i2c_algo_bit dca scsi_transport_sas ehci_pci libata ehci_hcd ptp crc32c_intel pps_core scsi_mod usbcore i2c_core usb_common mlx4_core
> [ 1542.407612] CPU: 5 PID: 4740 Comm: client Tainted: G O 4.4.0-rc3+donard2.4+ #78
> [ 1542.407682] Hardware name: Supermicro SYS-7047GR-TRF/X9DRG-QF, BIOS 3.0a 12/05/2013
> [ 1542.407749] task: ffff8802767445c0 ti: ffff8802601fc000 task.ti: ffff8802601fc000
> [ 1542.407816] RIP: 0010:[<ffffffffa033be40>] [<ffffffffa033be40>] ext4_end_io_unwritten+0x10/0x60 [ext4]
> [ 1542.407895] RSP: 0000:ffff8802601ffcf8 EFLAGS: 00010246
> [ 1542.407935] RAX: 00000000300000d1 RBX: 0000000000000800 RCX: 0000000000000000
> [ 1542.407981] RDX: 00000000ffffffff RSI: 0000000000000000 RDI: ffff8802601ffd68
> [ 1542.408025] RBP: 0000000000000000 R08: ffffffffa0342a9c R09: ffffffffa033be30
> [ 1542.408070] R10: 0000000000000001 R11: 0000000000000246 R12: ffff880464dd4230
> [ 1542.408114] R13: ffff88026030b858 R14: ffff880464dd40c8 R15: 0000000000000800
> [ 1542.408160] FS: 00007f5662bde740(0000) GS:ffff88047fc80000(0000) knlGS:0000000000000000
> [ 1542.408228] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1542.408269] CR2: 00000000300000d1 CR3: 0000000260dbb000 CR4: 00000000000406e0
> [ 1542.408314] Stack:
> [ 1542.408347] 0000000000000800 ffff8804716af018 ffff880464dd4230 ffff88026030b858
> [ 1542.408431] ffffffff81169652 000000008113ac16 00007f56617ee000 ffff8802601ffde0
> [ 1542.408516] ffffffff8113df6c ffffffffa033be30 00000024767445c0 ffff880200000041
> [ 1542.408601] Call Trace:
> [ 1542.408641] [<ffffffff81169652>] ? __dax_pmd_fault+0x3c0/0x3eb
> [ 1542.408686] [<ffffffff8113df6c>] ? path_openat+0xb33/0xc16
> [ 1542.408731] [<ffffffffa033be30>] ? ext4_dax_mkwrite+0x13/0x13 [ext4]
> [ 1542.408776] [<ffffffffa041dcbf>] ? ib_uverbs_dereg_mr+0xad/0xbb [ib_uverbs]
> [ 1542.408823] [<ffffffff8110795f>] ? vma_gap_callbacks_propagate+0x16/0x2c
> [ 1542.408868] [<ffffffff81108475>] ? vma_link+0x71/0x7e
> [ 1542.408910] [<ffffffff81109010>] ? vma_set_page_prot+0x33/0x50
> [ 1542.408955] [<ffffffffa033c081>] ? ext4_dax_pmd_fault+0xa7/0xee [ext4]
> [ 1542.409000] [<ffffffff8110560b>] ? handle_mm_fault+0x236/0xe95
> [ 1542.409043] [<ffffffff810f6fdc>] ? vm_mmap_pgoff+0x80/0xab
> [ 1542.409086] [<ffffffff81039c12>] ? __do_page_fault+0x239/0x3f2
> [ 1542.409131] [<ffffffff813e0722>] ? page_fault+0x22/0x30
> [ 1542.409171] Code: 5c 41 5d 41 5e 41 5f c3 48 c7 c1 30 be 33 a0 48 c7 c2 9c 2a 34 a0 e9 86 de e2 e0 41 55 41 54 85 f6 55 53 48 8b 47 58 48 8b 6f 40 <4c> 8b 20 45 8b ac 24 90 00 00 00 74 3c 48 8b 07 48 89 fb f6 c4
> [ 1542.409609] RIP [<ffffffffa033be40>] ext4_end_io_unwritten+0x10/0x60 [ext4]
> [ 1542.409661] RSP <ffff8802601ffcf8>
> [ 1542.409696] CR2: 00000000300000d1
> [ 1542.410353] ---[ end trace c43bed51af8ba585 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

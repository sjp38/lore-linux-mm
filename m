Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 61BE86B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 22:26:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 864553EE0AE
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:26:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E5B845DE52
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:26:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FF3145DE4E
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:26:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3129C1DB802C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:26:05 +0900 (JST)
Received: from g01jpexchyt02.g01.fujitsu.local (g01jpexchyt02.g01.fujitsu.local [10.128.194.41])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D64361DB803C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:26:04 +0900 (JST)
Message-ID: <50B432A2.2040600@jp.fujitsu.com>
Date: Tue, 27 Nov 2012 12:25:22 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mm/vmemmap: fix wrong use of virt_to_page
References: <50B422A9.7050103@huawei.com>
In-Reply-To: <50B422A9.7050103@huawei.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, shangw@linux.vnet.ibm.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, qiuxishi <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

2012/11/27 11:17, Jianguo Wu wrote:
> I enable CONFIG_DEBUG_VIRTUAL and CONFIG_SPARSEMEM_VMEMMAP, when doing memory hotremove,
> there is a kernel BUG at arch/x86/mm/physaddr.c:20.
>
> It is caused by free_section_usemap()->virt_to_page(),
> virt_to_page() is only used for kernel direct mapping address,
> but sparse-vmemmap uses vmemmap address, so it is going wrong here.
>
> [  517.727381] ------------[ cut here ]------------
> [  517.728851] kernel BUG at arch/x86/mm/physaddr.c:20!
> [  517.728851] invalid opcode: 0000 [#1] SMP
> [  517.740170] Modules linked in: acpihp_drv acpihp_slot edd cpufreq_conservativ
> e cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf fuse vfat fat loop dm_m
> od coretemp kvm crc32c_intel ipv6 ixgbe igb iTCO_wdt i7core_edac edac_core pcspk
> r iTCO_vendor_support ioatdma microcode joydev sr_mod i2c_i801 dca lpc_ich mfd_c
> ore mdio tpm_tis i2c_core hid_generic tpm cdrom sg tpm_bios rtc_cmos button ext3
>   jbd mbcache usbhid hid uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif p
> rocessor thermal_sys hwmon scsi_dh_alua scsi_dh_hp_sw scsi_dh_rdac scsi_dh_emc s
> csi_dh ata_generic ata_piix libata megaraid_sas scsi_mod
> [  517.740170] CPU 39
> [  517.740170] Pid: 6454, comm: sh Not tainted 3.7.0-rc1-acpihp-final+ #45 QCI Q
> SSC-S4R/QSSC-S4R
> [  517.740170] RIP: 0010:[<ffffffff8103c908>]  [<ffffffff8103c908>] __phys_addr+
> 0x88/0x90
> [  517.740170] RSP: 0018:ffff8804440d7c08  EFLAGS: 00010006
> [  517.740170] RAX: 0000000000000006 RBX: ffffea0012000000 RCX: 000000000000002c
>
> [  517.740170] RDX: 0000620012000000 RSI: 0000000000000000 RDI: ffffea0012000000
>
> [  517.740170] RBP: ffff8804440d7c08 R08: 0070000000000400 R09: 0000000000488000
>
> [  517.740170] R10: 0000000000000091 R11: 0000000000000001 R12: ffff88047fb87800
>
> [  517.740170] R13: ffffea0000000000 R14: ffff88047ffb3440 R15: 0000000000480000
>
> [  517.740170] FS:  00007f0462b49700(0000) GS:ffff8804570c0000(0000) knlGS:00000
> 00000000000
> [  517.740170] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  517.740170] CR2: 00007f006dc5fd14 CR3: 0000000440e85000 CR4: 00000000000007e0
>
> [  517.740170] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>
> [  517.896799] DR3: 0000000000000000 DR6
>
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>   mm/sparse.c |   10 ++++------
>   1 files changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fac95f2..a83de2f 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -617,7 +617,7 @@ static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
>   {
>   	return; /* XXX: Not implemented yet */
>   }
> -static void free_map_bootmem(struct page *page, unsigned long nr_pages)
> +static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
>   {
>   }
>   #else
> @@ -658,10 +658,11 @@ static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
>   			   get_order(sizeof(struct page) * nr_pages));
>   }
>
> -static void free_map_bootmem(struct page *page, unsigned long nr_pages)
> +static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
>   {
>   	unsigned long maps_section_nr, removing_section_nr, i;
>   	unsigned long magic;
> +	struct page *page = virt_to_page(memmap);
>
>   	for (i = 0; i < nr_pages; i++, page++) {
>   		magic = (unsigned long) page->lru.next;
> @@ -710,13 +711,10 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
>   	 */
>
>   	if (memmap) {
> -		struct page *memmap_page;
> -		memmap_page = virt_to_page(memmap);
> -
>   		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
>   			>> PAGE_SHIFT;
>
> -		free_map_bootmem(memmap_page, nr_pages);
> +		free_map_bootmem(memmap, nr_pages);
>   	}
>   }
>
>

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

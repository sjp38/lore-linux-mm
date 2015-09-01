Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 68C186B0255
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 03:16:02 -0400 (EDT)
Received: by qgp105 with SMTP id 105so32315738qgp.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 00:16:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m90si20318575qge.103.2015.09.01.00.16.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 00:16:00 -0700 (PDT)
Date: Tue, 1 Sep 2015 15:15:53 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH 2/2] drivers/base/node.c: skip non-present sections in
 register_mem_sect_under_node
Message-ID: <20150901071553.GD23114@localhost.localdomain>
References: <1a7c81db42986a6fa27260fe189890bffc8a9cce.1440665740.git.jstancek@redhat.com>
 <b12da2996a30cb739146a5eccd068bbe650092a1.1440665740.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b12da2996a30cb739146a5eccd068bbe650092a1.1440665740.git.jstancek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/27/15 at 04:43pm, Jan Stancek wrote:
> Skip non-present sections in mem_blk to avoid crashing during boot
> at register_mem_sect_under_node()->get_nid_for_pfn():
> 
>   Unable to handle kernel paging request for data at address 0xf000000000080020
>   Faulting instruction address: 0xc00000000866b480
>   Oops: Kernel access of bad area, sig: 11 [#1]
>   SMP NR_CPUS=2048 NUMA pSeries
>   Modules linked in:
>   CPU: 14 PID: 1 Comm: swapper/14 Not tainted 4.2.0-rc8+ #6
>   task: c00000001e480000 ti: c00000001e500000 task.ti: c00000001e500000
>   NIP: c00000000866b480 LR: c00000000851aecc CTR: 0000000000000400
>   ...
>   NIP [c00000000866b480] get_nid_for_pfn+0x10/0x30
>   LR [c00000000851aecc] register_mem_sect_under_node+0x9c/0x190
>   Call Trace:
>   [c00000001e503b10] [c0000000084f89a4] put_device+0x24/0x40 (unreliable)
>   [c00000001e503b60] [c00000000851b3d4] register_one_node+0x2b4/0x390
>   [c00000001e503bc0] [c000000008ae7a50] topology_init+0x4c/0x1e8
>   [c00000001e503c30] [c00000000800b3bc] do_one_initcall+0x10c/0x260
>   [c00000001e503d00] [c000000008ae41b4] kernel_init_freeable+0x27c/0x364
>   [c00000001e503dc0] [c00000000800bc14] kernel_init+0x24/0x130
>   [c00000001e503e30] [c000000008009530] ret_from_kernel_thread+0x5c/0xac
>   Instruction dump:
>   4e800020 60000000 60000000 60420000 3b80ffed 4bffffc8 00000000 00000000
>   3920ffff 78633664 792900c4 7d434a14 <e94a0020> 2faa0000 41de0010 7c63482a
>   ---[ end trace e9ab4a173e0cee14 ]---
> 
> This has been observed during kdump kernel boot on ppc64le KVM guest
> (page size: 65536, sections_per_block: 16, PAGES_PER_SECTION: 256)
> where kdump adds "rtas" to list of usable regions:
>   # hexdump -C /sys/firmware/devicetree/base/rtas/linux,rtas-base
>   00000000  2f ff 00 00                                       |/...|
> 
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000000000-0x000000001fffffff]
> [    0.000000]   node   0: [mem 0x000000002fff0000-0x000000002fffffff]
> 
> Crash happens when register_mem_sect_under_node goes over mem_blk that
> spans sections 32-47, 32-46 are not present, 47 is present:
>   32 * 256 * 65536 == 0x20000000
>   47 * 256 * 65536 == 0x2f000000
> It tries to access page for first pfn of this mem_blk (8192 == 32 * 256)
> and crashes.
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
>  drivers/base/node.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 4c7423a4b5f4..e638cfde7486 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -390,6 +390,9 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>  		sect_no <= mem_blk->end_section_nr;
>  		sect_no++) {
>  
> +		if (!present_section_nr(sect_no))
> +			continue;
> +
>  		sect_start_pfn = section_nr_to_pfn(sect_no);
>  		sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>  
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

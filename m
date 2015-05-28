Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED256B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:31:53 -0400 (EDT)
Received: by qcxw10 with SMTP id w10so18058267qcx.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:31:52 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id z129si3220246qkz.79.2015.05.28.11.31.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:31:52 -0700 (PDT)
Received: by qchk10 with SMTP id k10so18040660qch.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:31:52 -0700 (PDT)
Message-ID: <55675f17.48958c0a.6412.77de@mx.google.com>
Date: Thu, 28 May 2015 11:31:51 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH] mm/memory_hotplug: set zone->wait_table to null after
 free it
In-Reply-To: <1432775003-21473-1-git-send-email-guz.fnst@cn.fujitsu.com>
References: <1432775003-21473-1-git-send-email-guz.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, tangchen@cn.fujitsu.com, izumi.taku@jp.fujitsu.com, linux-kernel@vger.kernel.org, Stable <stable@vger.kernel.org>


On Thu, 28 May 2015 09:03:23 +0800
Gu Zheng <guz.fnst@cn.fujitsu.com> wrote:

> Izumi found the following oops when hot re-add a node:
> [ 1481.759192] BUG: unable to handle kernel paging request at ffffc90008963690
> [ 1481.760192] IP: [<ffffffff810dff80>] __wake_up_bit+0x20/0x70
> [ 1481.770098] PGD 86e919067 PUD 207cf003067 PMD 20796d3b067 PTE 0
> [ 1481.770098] Oops: 0000 [#1] SMP
> [ 1481.770098] CPU: 68 PID: 1237 Comm: rs:main Q:Reg Not tainted 4.1.0-rc5 #80
> [ 1481.770098] Hardware name: FUJITSU PRIMEQUEST2800E/SB, BIOS PRIMEQUEST 2000 Series BIOS Version 1.87 04/28/2015
> [ 1481.770098] task: ffff880838df8000 ti: ffff880017b94000 task.ti: ffff880017b94000
> [ 1481.770098] RIP: 0010:[<ffffffff810dff80>]  [<ffffffff810dff80>] __wake_up_bit+0x20/0x70
> [ 1481.770098] RSP: 0018:ffff880017b97be8  EFLAGS: 00010246
> [ 1481.770098] RAX: ffffc90008963690 RBX: 00000000003c0000 RCX: 000000000000a4c9
> [ 1481.770098] RDX: 0000000000000000 RSI: ffffea101bffd500 RDI: ffffc90008963648
> [ 1481.770098] RBP: ffff880017b97c08 R08: 0000000002000020 R09: 0000000000000000
> [ 1481.770098] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8a0797c73800
> [ 1481.770098] R13: ffffea101bffd500 R14: 0000000000000001 R15: 00000000003c0000
> [ 1481.770098] FS:  00007fcc7ffff700(0000) GS:ffff880874800000(0000) knlGS:0000000000000000
> [ 1481.770098] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1481.770098] CR2: ffffc90008963690 CR3: 0000000836761000 CR4: 00000000001407e0
> [ 1481.770098] Stack:
> [ 1481.770098]  ffff8a0797c73800 ffffea1000000000 0000100000000000 0000000069c53212
> [ 1481.770098]  ffff880017b97c18 ffffffff811c2a5d ffff880017b97c68 ffffffff8128a0e3
> [ 1481.770098]  0000000000000001 000000281bffd500 00000000003c0000 0000000000000028
> [ 1481.770098] Call Trace:
> [ 1481.770098]  [<ffffffff811c2a5d>] unlock_page+0x6d/0x70
> [ 1481.770098]  [<ffffffff8128a0e3>] generic_write_end+0x53/0xb0
> [ 1481.770098]  [<ffffffffa0496559>] xfs_vm_write_end+0x29/0x80 [xfs]
> [ 1481.770098]  [<ffffffff811c25da>] generic_perform_write+0x10a/0x1e0
> [ 1481.770098]  [<ffffffffa04acb4d>] xfs_file_buffered_aio_write+0x14d/0x3e0 [xfs]
> [ 1481.770098]  [<ffffffffa04ace59>] xfs_file_write_iter+0x79/0x120 [xfs]
> [ 1481.770098]  [<ffffffff8124aac4>] __vfs_write+0xd4/0x110
> [ 1481.770098]  [<ffffffff8124b1ac>] vfs_write+0xac/0x1c0
> [ 1481.770098]  [<ffffffff8124c0a8>] SyS_write+0x58/0xd0
> [ 1481.770098]  [<ffffffff8177eb6e>] system_call_fastpath+0x12/0x76
> [ 1481.770098] Code: 5d c3 66 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5
>  48 83 ec 20 65 48 8b 04 25 28 00 00 00 48 89 45 f8 31 c0 48 8d 47 48 <48> 39 47
>  48 48 c7 45 e8 00 00 00 00 48 c7 45 f0 00 00 00 00 48
> [ 1481.770098] RIP  [<ffffffff810dff80>] __wake_up_bit+0x20/0x70
> [ 1481.770098]  RSP <ffff880017b97be8>
> [ 1481.770098] CR2: ffffc90008963690
> [ 1481.770098] ---[ end trace 25c9882ad3f72923 ]---
> [ 1481.770098] Kernel panic - not syncing: Fatal exception
> [ 1481.770098] Kernel Offset: disabled
> [ 1481.770098] drm_kms_helper: panic occurred, switching back to text console
> [ 1481.770098] ---[ end Kernel panic - not syncing: Fatal exception
> 
> Reproduce method (re-add a node):
> Hot-add nodeA --> remove nodeA --> hot-add nodeA (panic)
> 
> This seems an use-after-free problem, and the root cause is zone->wait_table
> was not set to *NULL* after free it in try_offline_node.
> 
> When hot re-add a node, we will reuse the pgdat of it, so does
> the zone struct, and when add pages to the target zone, it will init the
> zone first (including the wait_table) if the zone is not initialized.
> The judgement of zone initialized is based on zone->wait_table:
> 	static inline bool zone_is_initialized(struct zone *zone)
> 	{
> 		return !!zone->wait_table;
> 	},
> so if we do not set the zone->wait_table to *NULL* after free it, the memory
> hotplug routine will skip the init of new zone when hot re-add the node, and
> the wait_table still points to the freed memory, then we will access the invalid
> address when trying to wake up the waiting people after the i/o operation with
> the page is done, such as mentioned above.
> 
> Reported-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> Cc: Stable <stable@vger.kernel.org>
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> ---

Hi Gu,

The patch looks good to me.

Reviewed by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>  mm/memory_hotplug.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 457bde5..9e88f74 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1969,8 +1969,10 @@ void try_offline_node(int nid)
>  		 * wait_table may be allocated from boot memory,
>  		 * here only free if it's allocated by vmalloc.
>  		 */
> -		if (is_vmalloc_addr(zone->wait_table))
> +		if (is_vmalloc_addr(zone->wait_table)) {
>  			vfree(zone->wait_table);
> +			zone->wait_table = NULL;
> +		}
>  	}
>  }
>  EXPORT_SYMBOL(try_offline_node);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

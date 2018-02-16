Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 750B76B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:40:08 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id n50so2234667wrn.20
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:40:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v17si3270135wmh.154.2018.02.16.12.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 12:40:07 -0800 (PST)
Date: Fri, 16 Feb 2018 12:40:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND v2] mm: don't defer struct page initialization for Xen
 pv guests
Message-Id: <20180216124004.8465f643a5539125d77ba79f@linux-foundation.org>
In-Reply-To: <20180216154101.22865-1-jgross@suse.com>
References: <20180216154101.22865-1-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, mhocko@suse.com, stable@vger.kernel.org, Pavel Tatashin <pasha.tatashin@oracle.com>

On Fri, 16 Feb 2018 16:41:01 +0100 Juergen Gross <jgross@suse.com> wrote:

> Commit f7f99100d8d95dbcf09e0216a143211e79418b9f ("mm: stop zeroing
> memory during allocation in vmemmap") broke Xen pv domains in some
> configurations, as the "Pinned" information in struct page of early
> page tables could get lost. This will lead to the kernel trying to
> write directly into the page tables instead of asking the hypervisor
> to do so. The result is a crash like the following:

Let's cc Pavel, who authored f7f99100d8d95d.

> [    0.004000] BUG: unable to handle kernel paging request at ffff8801ead19008
> [    0.004000] IP: xen_set_pud+0x4e/0xd0
> [    0.004000] PGD 1c0a067 P4D 1c0a067 PUD 23a0067 PMD 1e9de0067 PTE 80100001ead19065
> [    0.004000] Oops: 0003 [#1] PREEMPT SMP
> [    0.004000] Modules linked in:
> [    0.004000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.14.0-default+ #271
> [    0.004000] Hardware name: Dell Inc. Latitude E6440/0159N7, BIOS A07 06/26/2014
> [    0.004000] task: ffffffff81c10480 task.stack: ffffffff81c00000
> [    0.004000] RIP: e030:xen_set_pud+0x4e/0xd0
> [    0.004000] RSP: e02b:ffffffff81c03cd8 EFLAGS: 00010246
> [    0.004000] RAX: 002ffff800000800 RBX: ffff88020fd31000 RCX: 0000000000000000
> [    0.004000] RDX: ffffea0000000000 RSI: 00000001b8308067 RDI: ffff8801ead19008
> [    0.004000] RBP: ffff8801ead19008 R08: aaaaaaaaaaaaaaaa R09: 00000000063f4c80
> [    0.004000] R10: aaaaaaaaaaaaaaaa R11: 0720072007200720 R12: 00000001b8308067
> [    0.004000] R13: ffffffff81c8a9cc R14: ffff88018fd31000 R15: 000077ff80000000
> [    0.004000] FS:  0000000000000000(0000) GS:ffff88020f600000(0000) knlGS:0000000000000000
> [    0.004000] CS:  e033 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.004000] CR2: ffff8801ead19008 CR3: 0000000001c09000 CR4: 0000000000042660
> [    0.004000] Call Trace:
> [    0.004000]  __pmd_alloc+0x128/0x140
> [    0.004000]  ? acpi_os_map_iomem+0x175/0x1b0
> [    0.004000]  ioremap_page_range+0x3f4/0x410
> [    0.004000]  ? acpi_os_map_iomem+0x175/0x1b0
> [    0.004000]  __ioremap_caller+0x1c3/0x2e0
> [    0.004000]  acpi_os_map_iomem+0x175/0x1b0
> [    0.004000]  acpi_tb_acquire_table+0x39/0x66
> [    0.004000]  acpi_tb_validate_table+0x44/0x7c
> [    0.004000]  acpi_tb_verify_temp_table+0x45/0x304
> [    0.004000]  ? acpi_ut_acquire_mutex+0x12a/0x1c2
> [    0.004000]  acpi_reallocate_root_table+0x12d/0x141
> [    0.004000]  acpi_early_init+0x4d/0x10a
> [    0.004000]  start_kernel+0x3eb/0x4a1
> [    0.004000]  ? set_init_arg+0x55/0x55
> [    0.004000]  xen_start_kernel+0x528/0x532
> [    0.004000] Code: 48 01 e8 48 0f 42 15 a2 fd be 00 48 01 d0 48 ba 00 00 00 00 00 ea ff ff 48 c1 e8 0c 48 c1 e0 06 48 01 d0 48 8b 00 f6 c4 02 75 5d <4c> 89 65 00 5b 5d 41 5c c3 65 8b 05 52 9f fe 7e 89 c0 48 0f a3
> [    0.004000] RIP: xen_set_pud+0x4e/0xd0 RSP: ffffffff81c03cd8
> [    0.004000] CR2: ffff8801ead19008
> [    0.004000] ---[ end trace 38eca2e56f1b642e ]---
> 
> Avoid this problem by not deferring struct page initialization when
> running as Xen pv guest.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -347,6 +347,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  	/* Always populate low zones for address-constrained allocations */
>  	if (zone_end < pgdat_end_pfn(pgdat))
>  		return true;
> +	/* Xen PV domains need page structures early */
> +	if (xen_pv_domain())
> +		return true;
>  	(*nr_initialised)++;
>  	if ((*nr_initialised > pgdat->static_init_pgcnt) &&
>  	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {

I'm OK with applying the patch as a short-term regression fix but I do
wonder whether it's the correct fix.  What is special about Xen (in
some configurations!) that causes it to find a hole in deferred
initialization?

I'd like us to delve further please.  Because if Xen found a hole in
the implementation, others might do so.  Or perhaps Xen is doing
something naughty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

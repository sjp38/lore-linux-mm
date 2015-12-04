Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DDF656B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 15:46:53 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so91910544pac.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 12:46:53 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l17si21497645pfb.53.2015.12.04.12.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 12:46:52 -0800 (PST)
Subject: Re: mm: BUG in __munlock_pagevec
References: <565C5C38.3040705@oracle.com>
 <20151201213801.GA138207@black.fi.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5661FBB6.6050307@oracle.com>
Date: Fri, 4 Dec 2015 15:46:46 -0500
MIME-Version: 1.0
In-Reply-To: <20151201213801.GA138207@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/01/2015 04:38 PM, Kirill A. Shutemov wrote:
> On Mon, Nov 30, 2015 at 09:24:56AM -0500, Sasha Levin wrote:
>> > Hi all,
>> > 
>> > I've hit the following while fuzzing with trinity on the latest -next kernel:
>> > 
>> > 
>> > [  850.305385] page:ffffea001a5a0f00 count:0 mapcount:1 mapping:dead000000000400 index:0x1ffffffffff
>> > [  850.306773] flags: 0x2fffff80000000()
>> > [  850.307175] page dumped because: VM_BUG_ON_PAGE(1 && PageTail(page))
>> > [  850.308027] page_owner info is not active (free page?)
> Could you check this completely untested patch:
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index af421d8bd6da..9197b6721a1e 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -393,6 +393,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>  		if (!page || page_zone_id(page) != zoneid)
>  			break;
>  
> +		/*
> +		 * Do not use pagevec for PTE-mapped THP,
> +		 * munlock_vma_pages_range() will handle them.
> +		 */
> +		if (PageTransCompound(page))
> +			break;
> +
>  		get_page(page);
>  		/*
>  		 * Increase the address that will be returned *before* the

I've started seeing:

[ 1197.233931] BUG: Bad page state in process trinity-subchil  pfn:110600
[ 1197.234002] page:ffffea0004418000 count:0 mapcount:0 mapping:          (null) index:0x2a00 compound_mapcount: 0
[ 1197.234013] flags: 0x6fffff80144008(uptodate|head|swapbacked|mlocked)
[ 1197.234035] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[ 1197.234040] bad because of flags: 0x100000:(mlocked)
[ 1197.234051] Modules linked in:
[ 1197.234070] CPU: 23 PID: 4958 Comm: trinity-subchil Tainted: G    B           4.4.0-rc3-next-20151203-sasha-00025-gf813aca-dirty #2691
[ 1197.234076]  1ffff1003e1a4eb2 000000003cc27d3f ffff8801f0d27610 ffffffffa2fb13f2
[ 1197.234092]  0000000041b58ab3 ffffffffae036b9b ffffffffa2fb1327 0000000000100000
[ 1197.234108]  ffffffffa169ab93 000000003cc27d3f 0100000000000000 000000000018bce1
[ 1197.234124] Call Trace:
[ 1197.234142]  [<ffffffffa2fb13f2>] dump_stack+0xcb/0x149
[ 1197.234156]  [<ffffffffa2fb1327>] ? _atomic_dec_and_lock+0xf7/0xf7
[ 1197.234170]  [<ffffffffa169ab93>] ? dump_page_badflags+0x4a3/0x590
[ 1197.234185]  [<ffffffffa161d673>] bad_page+0x263/0x310
[ 1197.234206]  [<ffffffffa161d410>] ? set_page_refcounted+0x1a0/0x1a0
[ 1197.234221]  [<ffffffffa1777fb0>] ? mem_cgroup_move_charge_pte_range+0xa60/0xa60
[ 1197.234237]  [<ffffffffa1620ef9>] free_pages_prepare+0x489/0x1700
[ 1197.234255]  [<ffffffffa1778a80>] ? uncharge_list+0x590/0x5a0
[ 1197.234270]  [<ffffffffa1620a70>] ? build_zonelists+0x1920/0x1920
[ 1197.234286]  [<ffffffffa30247b2>] ? __list_del_entry+0x172/0x2b0
[ 1197.234299]  [<ffffffffa1629053>] __free_pages_ok+0x43/0x230
[ 1197.234312]  [<ffffffffa16292d2>] free_compound_page+0x92/0xa0
[ 1197.234326]  [<ffffffffa17685f6>] free_transhuge_page+0x96/0xa0
[ 1197.234340]  [<ffffffffa1643637>] __put_compound_page+0xc7/0xd0
[ 1197.234353]  [<ffffffffa1643bef>] release_pages+0x35f/0xb10
[ 1197.234373]  [<ffffffffa1643890>] ? put_pages_list+0x190/0x190
[ 1197.234428]  [<ffffffffa16477fc>] ? lru_add_drain_cpu+0x49c/0x4b0
[ 1197.234442]  [<ffffffffa16eecc9>] free_pages_and_swap_cache+0x49/0x410
[ 1197.234455]  [<ffffffffa16a0547>] tlb_flush_mmu_free+0x97/0x130
[ 1197.234467]  [<ffffffffa16a7447>] unmap_page_range+0x1877/0x1bd0
[ 1197.234480]  [<ffffffffa16a5bd0>] ? vm_normal_page+0x1f0/0x1f0
[ 1197.234493]  [<ffffffffa17616ee>] ? __khugepaged_exit+0x2ee/0x3a0
[ 1197.234506]  [<ffffffffa16a79d7>] unmap_single_vma+0x237/0x250
[ 1197.234518]  [<ffffffffa16a9e96>] unmap_vmas+0x126/0x1b0
[ 1197.234532]  [<ffffffffa16c9fd0>] exit_mmap+0x2b0/0x420
[ 1197.234547]  [<ffffffffa17616ee>] ? __khugepaged_exit+0x2ee/0x3a0
[ 1197.234563]  [<ffffffffa16c9d20>] ? SyS_remap_file_pages+0x630/0x630
[ 1197.234575]  [<ffffffffa174185d>] ? kmem_cache_free+0x26d/0x2d0
[ 1197.234592]  [<ffffffffa13cf532>] ? __might_sleep+0x1f2/0x220
[ 1197.234606]  [<ffffffffa13509d5>] mmput+0xe5/0x320
[ 1197.234620]  [<ffffffffa13508f0>] ? sighand_ctor+0x70/0x70
[ 1197.234635]  [<ffffffffa1362a39>] ? mm_update_next_owner+0x5c9/0x600
[ 1197.234649]  [<ffffffffa13dde39>] ? preempt_count_add+0xe9/0x140
[ 1197.234664]  [<ffffffffa13638fd>] do_exit+0xe8d/0x1540
[ 1197.234678]  [<ffffffffa11693a4>] ? sched_clock+0x44/0x50
[ 1197.234693]  [<ffffffffa13f058c>] ? local_clock+0x1c/0x20
[ 1197.234709]  [<ffffffffa1362a70>] ? mm_update_next_owner+0x600/0x600
[ 1197.234724]  [<ffffffffa1607721>] ? __context_tracking_exit+0xb1/0xc0
[ 1197.234738]  [<ffffffffa160784b>] ? context_tracking_exit+0x11b/0x120
[ 1197.234754]  [<ffffffffa1005e5a>] ? syscall_trace_enter_phase1+0x4aa/0x4f0
[ 1197.234771]  [<ffffffffa10059b0>] ? enter_from_user_mode+0x80/0x80
[ 1197.234800]  [<ffffffffa3024353>] ? check_preemption_disabled+0x233/0x250
[ 1197.234813]  [<ffffffffa1364209>] do_group_exit+0x1e9/0x330
[ 1197.234825]  [<ffffffffa136436d>] SyS_exit_group+0x1d/0x20
[ 1197.234842]  [<ffffffffab9178d5>] entry_SYSCALL_64_fastpath+0x35/0x99


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

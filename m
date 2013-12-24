Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id D438B6B0031
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 05:58:11 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so6353978pbc.21
        for <linux-mm@kvack.org>; Tue, 24 Dec 2013 02:58:11 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id o7si4113054pbb.130.2013.12.24.02.58.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Dec 2013 02:58:10 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 24 Dec 2013 16:25:20 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B3D86394004E
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 16:25:11 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBOAt9mX61341746
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 16:25:09 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBOAsAbK015593
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 16:24:10 +0530
Date: Tue, 24 Dec 2013 18:54:07 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/thp: fix vmas tear down race with thp splitting
Message-ID: <52b968c2.470b440a.3fc0.ffff8012SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387850059-18525-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131224102640.GA31495@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131224102640.GA31495@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kirill,
On Tue, Dec 24, 2013 at 12:26:40PM +0200, Kirill A. Shutemov wrote:
>On Tue, Dec 24, 2013 at 09:54:19AM +0800, Wanpeng Li wrote:
>> Sasha reports unmap_page_range tears down pmd range which is race with thp 
>> splitting during page reclaim. Transparent huge page will be splitting 
>> during page reclaim. However, split pmd lock which held by __split_trans_huge_lock
>> can't prevent __split_huge_page_refcount running in parallel. This patch fix 
>> it by hold compound lock to check if __split_huge_page_refcount is running 
>> underneath, in that case zap huge pmd range should be fallback.
>
>I try to understand what's going on. IIUC, you assume race is following:
>
>	CPU0					CPU1
>__split_huge_page()
>  __split_huge_page_splitting()
>  __split_huge_page_refcount()		zap_huge_pmd()
>    compound_lock()			  __pmd_trans_huge_lock() == 1
>    ClearPageCompound()
>					    VM_BUG_ON(!PageHead(page)); <- Compound flags have been cleared already
>    compound_unlock()
>
>Right?
>
>I don't see how it can happen:
>  - __split_huge_page_splitting() marks pmd as splitting under pmd ptlock
>  - __pmd_trans_huge_lock() checks for pmd_trans_splitting() under the
>    same pmd ptlock, before returning 1;
>  - zap_huge_pmd() only hits the VM_BUG_ON() if __pmd_trans_huge_lock()
>    returned one, and it holds pmd ptlock all the time.
>
>Could you describe in details what scenario you have in mind.
>

I make a mistake here. I think you are right and we need to continue to
fight out the root issue. ;-)

Regards,
Wanpeng Li 

>> 
>> [  265.474585] kernel BUG at mm/huge_memory.c:1440!
>> [  265.475129] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> [  265.476684] Dumping ftrace buffer:
>> [  265.477144]    (ftrace buffer empty)
>> [  265.478398] Modules linked in:
>> [  265.478807] CPU: 8 PID: 11344 Comm: trinity-c206 Tainted: G        W    3.13.0-rc5-next-20131223-sasha-00015-gec22156-dirty #8
>> [  265.480172] task: ffff8801cb573000 ti: ffff8801cbd3a000 task.ti: ffff8801cbd3a000
>> [  265.480172] RIP: 0010:[<ffffffff812c7f70>]  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0x1f0
>> [  265.480172] RSP: 0000:ffff8801cbd3bc78  EFLAGS: 00010246
>> [  265.480172] RAX: 015fffff80090018 RBX: ffff8801cbd3bde8 RCX: ffffffffffffff9c
>> [  265.480172] RDX: ffffffffffffffff RSI: 0000000000000008 RDI: ffff8800bffd2000
>> [  265.480172] RBP: ffff8801cbd3bcb8 R08: 0000000000000000 R09: 0000000000000000
>> [  265.480172] R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0002856740
>> [  265.480172] R13: ffffea0002d50000 R14: 00007ff915000000 R15: 00007ff930e48fff
>> [  265.480172] FS:  00007ff934899700(0000) GS:ffff88014d400000(0000) knlGS:0000000000000000
>> [  265.480172] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [  265.480172] CR2: 00007ff93428a000 CR3: 000000010babe000 CR4: 00000000000006e0
>> [  265.480172] Stack:
>> [  265.480172]  00000000000004dd ffff8801ccbfbb60 ffff8801cbd3bcb8 ffff8801cbb15540
>> [  265.480172]  00007ff915000000 00007ff930e49000 ffff8801cbd3bde8 00007ff930e48fff
>> [  265.480172]  ffff8801cbd3bd48 ffffffff812885b6 ffff88005f5d20c0 00007ff915200000
>> [  265.480172] Call Trace:
>> [  265.480172]  [<ffffffff812885b6>] unmap_page_range+0x2c6/0x410
>> [  265.480172]  [<ffffffff81288801>] unmap_single_vma+0x101/0x120
>> [  265.480172]  [<ffffffff81288881>] unmap_vmas+0x61/0xa0
>> [  265.480172]  [<ffffffff8128f730>] exit_mmap+0xd0/0x170
>> [  265.480172]  [<ffffffff81138860>] mmput+0x70/0xe0
>> [  265.480172]  [<ffffffff8113c89d>] exit_mm+0x18d/0x1a0
>> [  265.480172]  [<ffffffff811ea355>] ? acct_collect+0x175/0x1b0
>> [  265.480172]  [<ffffffff8113ed0f>] do_exit+0x26f/0x520
>> [  265.480172]  [<ffffffff8113f069>] do_group_exit+0xa9/0xe0
>> [  265.480172]  [<ffffffff8113f0b7>] SyS_exit_group+0x17/0x20
>> [  265.480172]  [<ffffffff845f10d0>] tracesys+0xdd/0xe2
>> [  265.480172] Code: 0f 0b 66 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f
>> 44 00 00 48 8b 03 f0 48 81 80 50 03 00 00 00 fe ff ff 49 8b 45 00 f6
>> c4 40 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 48 8b 03
>> f0 48
>> [  265.480172] RIP  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0x1f0
>> [  265.480172]  RSP <ffff8801cbd3bc78>
>> 
>> Reported-by: Sasha Levin <sasha.levin@oracle.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/huge_memory.c | 13 ++++++++++++-
>>  1 file changed, 12 insertions(+), 1 deletion(-)
>> 
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 7de1bf8..d1e0c80 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1414,6 +1414,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>>  {
>>  	spinlock_t *ptl;
>>  	int ret = 0;
>> +	unsigned long flags;
>>  
>>  	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
>>  		struct page *page;
>> @@ -1426,6 +1427,15 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>>  		 * operations.
>>  		 */
>>  		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
>> +		page = pmd_page(orig_pmd);
>> +		flags = compound_lock_irqsave(page);
>> +		if (unlikely(!PageHead(page))) {
>> +			/*
>> +			 * __split_huge_page_refcount run before us
>> +			 */
>> +			compound_unlock_irqrestore(page, flags);
>> +			return ret;
>> +		}
>>  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
>>  		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
>>  		if (is_huge_zero_pmd(orig_pmd)) {
>> @@ -1433,7 +1443,6 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>>  			spin_unlock(ptl);
>>  			put_huge_zero_page();
>>  		} else {
>> -			page = pmd_page(orig_pmd);
>>  			page_remove_rmap(page);
>>  			VM_BUG_ON(page_mapcount(page) < 0);
>>  			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
>> @@ -1442,6 +1451,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>>  			spin_unlock(ptl);
>>  			tlb_remove_page(tlb, page);
>>  		}
>> +		compound_unlock_irqrestore(page, flags);
>> +
>>  		pte_free(tlb->mm, pgtable);
>>  		ret = 1;
>>  	}
>> -- 
>> 1.8.3.2
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
>-- 
> Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

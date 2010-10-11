Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 96F916B0071
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 13:35:17 -0400 (EDT)
Received: by wwa36 with SMTP id 36so3377736wwa.26
        for <linux-mm@kvack.org>; Mon, 11 Oct 2010 10:35:12 -0700 (PDT)
Message-ID: <4CB34A1A.3030003@gmail.com>
Date: Mon, 11 Oct 2010 19:32:10 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14(16] pramfs: memory protection
References: <4CB1EBA2.8090409@gmail.com> <87aamm3si1.fsf@basil.nowhere.org>
In-Reply-To: <87aamm3si1.fsf@basil.nowhere.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Embedded <linux-embedded@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Tim Bird <tim.bird@am.sony.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Il 10/10/2010 18:46, Andi Kleen ha scritto:
> This won't work at all on x86 because you don't handle large 
> pages.
> 
> And it doesn't work on x86-64 because the first 2GB are double
> mapped (direct and kernel text mapping)
> 
> Thirdly I expect it won't either on architectures that map
> the direct mapping with special registers (like IA64 or MIPS)

Andi, what do you think to use the already implemented follow_pte
instead? 

int writeable_kernel_pte_range(unsigned long address, unsigned long size,
							      unsigned int rw)
{

	unsigned long addr = address & PAGE_MASK;
	unsigned long end = address + size;
	unsigned long start = addr;
	int ret = -EINVAL;
	pte_t *ptep, pte;
	spinlock_t *lock = &init_mm.page_table_lock;

	do {
		ret = follow_pte(&init_mm, addr, &ptep, &lock);
		if (ret)
			goto out;
		pte = *ptep;
		if (pte_present(pte)) {
			  pte = rw ? pte_mkwrite(pte) : pte_wrprotect(pte);
			  *ptep = pte;
		}
		pte_unmap_unlock(ptep, lock);
		addr += PAGE_SIZE;
	} while (addr && (addr < end));

	ret = 0;

out:
	flush_tlb_kernel_range(start, end);
	return ret;
}


> 
> I'm not sure this is very useful anyways. It doesn't protect
> against stray DMA and it doesn't protect against writes through
> broken user PTEs.
> 
> -Andi
> 

It's a way to have more protection against kernel bug, for a 
in-memory fs can be important. However this option can be 
enabled/disabled at fs level.

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

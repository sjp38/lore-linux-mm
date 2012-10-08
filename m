Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id F154C6B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 01:17:59 -0400 (EDT)
Message-ID: <50726354.60803@cn.fujitsu.com>
Date: Mon, 08 Oct 2012 13:23:32 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/10] memory-hotplug : remove page table of x86_64 architecture
References: <506E43E0.70507@jp.fujitsu.com> <506E4799.30407@jp.fujitsu.com> <m2d30tvatv.fsf@firstfloor.org>
In-Reply-To: <m2d30tvatv.fsf@firstfloor.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 10/08/2012 12:37 PM, Andi Kleen Wrote:
> Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> writes:
>> +			}
>> +
>> +			/*
>> +			 * We use 2M page, but we need to remove part of them,
>> +			 * so split 2M page to 4K page.
>> +			 */
>> +			pte = alloc_low_page(&pte_phys);
> 
> What happens when the allocation fails?
> 
> alloc_low_page seems to be buggy there too, it would __pa a NULL 
> pointer.

Yes, it will cause kernek panicked in __pa() if CONFI_DEBUG_VIRTUAL is set.
Otherwise, it will return a NULL pointer. I will update this patch to deal
with NULL pointer.

> 
>> +		if (pud_large(*pud)) {
>> +			if ((addr & ~PUD_MASK) == 0 && next <= end) {
>> +				set_pud(pud, __pud(0));
>> +				pages++;
>> +				continue;
>> +			}
>> +
>> +			/*
>> +			 * We use 1G page, but we need to remove part of them,
>> +			 * so split 1G page to 2M page.
>> +			 */
>> +			pmd = alloc_low_page(&pmd_phys);
> 
> Same here
> 
>> +			__split_large_page((pte_t *)pud, addr, (pte_t *)pmd);
>> +
>> +			spin_lock(&init_mm.page_table_lock);
>> +			pud_populate(&init_mm, pud, __va(pmd_phys));
>> +			spin_unlock(&init_mm.page_table_lock);
>> +		}
>> +
>> +		pmd = map_low_page(pmd_offset(pud, 0));
>> +		phys_pmd_remove(pmd, addr, end);
>> +		unmap_low_page(pmd);
>> +		__flush_tlb_all();
>> +	}
>> +	__flush_tlb_all();
> 
> This doesn't flush the other CPUs doesn't it?

How to flush the other CPU's tlb? use on_each_cpu() to run __flush_tlb_all()
on each online cpu?

Thanks
Wen Congyang

> 
> -Andi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

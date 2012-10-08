Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id BE55D6B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 00:37:01 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 8/10] memory-hotplug : remove page table of x86_64 architecture
References: <506E43E0.70507@jp.fujitsu.com> <506E4799.30407@jp.fujitsu.com>
Date: Sun, 07 Oct 2012 21:37:00 -0700
In-Reply-To: <506E4799.30407@jp.fujitsu.com> (Yasuaki Ishimatsu's message of
	"Fri, 5 Oct 2012 11:36:09 +0900")
Message-ID: <m2d30tvatv.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> writes:
> +			}
> +
> +			/*
> +			 * We use 2M page, but we need to remove part of them,
> +			 * so split 2M page to 4K page.
> +			 */
> +			pte = alloc_low_page(&pte_phys);

What happens when the allocation fails?

alloc_low_page seems to be buggy there too, it would __pa a NULL 
pointer.

> +		if (pud_large(*pud)) {
> +			if ((addr & ~PUD_MASK) == 0 && next <= end) {
> +				set_pud(pud, __pud(0));
> +				pages++;
> +				continue;
> +			}
> +
> +			/*
> +			 * We use 1G page, but we need to remove part of them,
> +			 * so split 1G page to 2M page.
> +			 */
> +			pmd = alloc_low_page(&pmd_phys);

Same here

> +			__split_large_page((pte_t *)pud, addr, (pte_t *)pmd);
> +
> +			spin_lock(&init_mm.page_table_lock);
> +			pud_populate(&init_mm, pud, __va(pmd_phys));
> +			spin_unlock(&init_mm.page_table_lock);
> +		}
> +
> +		pmd = map_low_page(pmd_offset(pud, 0));
> +		phys_pmd_remove(pmd, addr, end);
> +		unmap_low_page(pmd);
> +		__flush_tlb_all();
> +	}
> +	__flush_tlb_all();

This doesn't flush the other CPUs doesn't it?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

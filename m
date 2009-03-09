Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5A06B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 13:00:35 -0400 (EDT)
Message-ID: <49B54B2A.9090408@nokia.com>
Date: Mon, 09 Mar 2009 19:00:26 +0200
From: Aaro Koskinen <aaro.koskinen@nokia.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/2] mm: tlb: Add range to tlb_start_vma() and tlb_end_vma()
References: <49B511E9.8030405@nokia.com> <1236603597-1646-1-git-send-email-Aaro.Koskinen@nokia.com> <Pine.LNX.4.64.0903091352430.28665@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0903091352430.28665@blonde.anvils>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ext Hugh Dickins <hugh@veritas.com>, "linux-arm-kernel@lists.arm.linux.org.uk" <linux-arm-kernel@lists.arm.linux.org.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello,

Hugh Dickins wrote:
> On Mon, 9 Mar 2009, Aaro Koskinen wrote:
>> Pass the range to be teared down with tlb_start_vma() and
>> tlb_end_vma(). This allows architectures doing per-VMA handling to flush
>> only the needed range instead of the full VMA region.
[...]
>>  static unsigned long unmap_page_range(struct mmu_gather *tlb,
>>  				struct vm_area_struct *vma,
>> -				unsigned long addr, unsigned long end,
>> +				unsigned long range_start, unsigned long end,
>>  				long *zap_work, struct zap_details *details)
>>  {
>>  	pgd_t *pgd;
>>  	unsigned long next;
>> +	unsigned long addr = range_start;
>> +	unsigned long range_end;
>>  
>>  	if (details && !details->check_mapping && !details->nonlinear_vma)
>>  		details = NULL;
>>  
>>  	BUG_ON(addr >= end);
>> -	tlb_start_vma(tlb, vma);
>> +	BUG_ON(*zap_work <= 0);
>> +	range_end = addr + min(end - addr, (unsigned long)*zap_work);
>> +	tlb_start_vma(tlb, vma, range_start, range_end);
>>  	pgd = pgd_offset(vma->vm_mm, addr);
>>  	do {
>>  		next = pgd_addr_end(addr, end);
>> @@ -917,7 +921,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
>>  		next = zap_pud_range(tlb, vma, pgd, addr, next,
>>  						zap_work, details);
>>  	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
>> -	tlb_end_vma(tlb, vma);
>> +	tlb_end_vma(tlb, vma, range_start, range_end);
>>  
>>  	return addr;
>>  }
> 
> Sorry, I don't like this second-guessing of zap_work at all (okay,
> we all hate zap_work, and would love to rework the tlb mmu_gather
> stuff to be preemptible, but the file truncation case has so far
> discouraged us).
> 
> Take a look at the levels below, in particular zap_pte_range(),
> and you'll see that zap_work is just an approximate cap upon the
> amount of work being done while zapping, and is decremented by
> wildly different amounts if a pte (or swap entry) is there or not.
> 
> So the range_end you calculate will usually be misleadingly
> different from the actual end of the range.

You are right. Somehow I assumed it would simply define the maximum 
range in bytes, but I now realize it does not. So the range calculation 
is totally wrong. For tlb_end_vma() the range end would be available in 
addr, though, but that is probably irrelevant because of what you said:

> I don't see that you need to change the interface and other arches
> at all.  What prevents ARM from noting the first and last addresses
> freed in its struct mmu_gather when tlb_remove_tlb_entry() is called
> (see arch/um/include/asm/tlb.h for an example of that), then using
> that in its tlb_end_vma() TLB flushing?

This would probably work, thanks for pointing it out. I should have 
taken a better look of the full API, not just what was implemented in ARM.

So, there's a new ARM-only patch draft below based on this idea, adding 
also linux-arm-kernel again.

> Admittedly you won't know the end for cache flusing in tlb_start_vma(),
> but you haven't mentioned that one as a problem, and I expect you can
> devise (ARM-specific) optimizations to avoid repetition there too.

Yes, the execution time of tlb_start_vma() does not depend on the range 
size, so that is a lesser problem.

Thanks,

A.

---

From: Aaro Koskinen <Aaro.Koskinen@nokia.com>
Subject: [RFC PATCH] [ARM] Flush only the needed range when unmapping VMA

Signed-off-by: Aaro Koskinen <Aaro.Koskinen@nokia.com>
---
  arch/arm/include/asm/tlb.h |   25 ++++++++++++++++++++++---
  1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 857f1df..2729fb9 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -36,6 +36,8 @@
  struct mmu_gather {
  	struct mm_struct	*mm;
  	unsigned int		fullmm;
+	unsigned long		range_start;
+	unsigned long		range_end;
  };

  DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
@@ -47,6 +49,8 @@ tlb_gather_mmu(struct mm_struct *mm, unsigned int 
full_mm_flush)

  	tlb->mm = mm;
  	tlb->fullmm = full_mm_flush;
+	tlb->range_start = TASK_SIZE;
+	tlb->range_end = 0;

  	return tlb;
  }
@@ -63,7 +67,19 @@ tlb_finish_mmu(struct mmu_gather *tlb, unsigned long 
start, unsigned long end)
  	put_cpu_var(mmu_gathers);
  }

-#define tlb_remove_tlb_entry(tlb,ptep,address)	do { } while (0)
+/*
+ * Memorize the range for the TLB flush.
+ */
+static inline void
+tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long 
addr)
+{
+	if (!tlb->fullmm) {
+		if (addr < tlb->range_start)
+			tlb->range_start = addr;
+		if (addr + PAGE_SIZE > tlb->range_end)
+			tlb->range_end = addr + PAGE_SIZE;
+	}
+}

  /*
   * In the case of tlb vma handling, we can optimise these away in the
@@ -80,8 +96,11 @@ tlb_start_vma(struct mmu_gather *tlb, struct 
vm_area_struct *vma)
  static inline void
  tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
  {
-	if (!tlb->fullmm)
-		flush_tlb_range(vma, vma->vm_start, vma->vm_end);
+	if (!tlb->fullmm && tlb->range_end > 0) {
+		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
+		tlb->range_start = TASK_SIZE;
+		tlb->range_end = 0;
+	}
  }

  #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

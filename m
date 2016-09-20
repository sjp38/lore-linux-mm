Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7991C6B025E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 03:59:08 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t204so18317913ywt.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 00:59:08 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id k3si23395680qkc.77.2016.09.20.00.59.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 00:59:07 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm/vmalloc: correct a few logic error in
 __insert_vmap_area()
References: <57E0D0F2.1060707@zoho.com>
 <20160920165441.76e5a01b@roar.ozlabs.ibm.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57E0EC00.6070700@zoho.com>
Date: Tue, 20 Sep 2016 15:57:52 +0800
MIME-Version: 1.0
In-Reply-To: <20160920165441.76e5a01b@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 09/20/2016 02:54 PM, Nicholas Piggin wrote:
> On Tue, 20 Sep 2016 14:02:26 +0800
> zijun_hu <zijun_hu@zoho.com> wrote:
> 
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> correct a few logic error in __insert_vmap_area() since the else if
>> condition is always true and meaningless
>>
>> avoid endless loop under [un]mapping improper ranges whose boundary
>> are not aligned to page
>>
>> correct lazy_max_pages() return value if the number of online cpus
>> is power of 2
>>
>> improve performance for pcpu_get_vm_areas() via optimizing vmap_areas
>> overlay checking algorithm and finding near vmap_areas by list_head
>> other than rbtree
>>
>> simplify /proc/vmallocinfo implementation via seq_file helpers
>> for list_head
>>
>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
>> Signed-off-by: zijun_hu <zijun_hu@zoho.com>
> 
> Could you submit each of these changes as a separate patch? Would you
> consider using capitalisation and punctuation in the changelog?
>
thanks for your advisement
i will follow it and split this patch to smaller patches finally

> Did you measure any performance improvements, or do you have a workload
> where vmalloc shows up in profiles?
>
don't have measurement in practice, but i am sure there are
performance improvements for pcpu_get_vm_areas() theoretically
due to below reasons:
1) the counter of vmap_area overlay checkup loop is reduced to half
2) the previous and next vmap_area of one on list_head are just the
   nearest ones due to address sorted vmap_areas on list_head, so no
   walk and compare is needed
> 
>> @@ -108,6 +108,9 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
>>  	unsigned long next;
>>  
>>  	BUG_ON(addr >= end);
>> +	WARN_ON(!PAGE_ALIGNED(addr | end));
> 
> I prefer to avoid mixing bitwise and arithmetic operations unless it's
> necessary. Gcc should be able to optimise
> 
> WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end))
> 
i agree with you, i will apply your suggestion finally
>> +	addr = round_down(addr, PAGE_SIZE);
> 
> I don't know if it's really necessary to relax the API like this for
> internal vmalloc.c functions. If garbage is detected here, it's likely
> due to a bug, and I'm not sure that rounding it would solve the problem.
> 
> For API functions perhaps it's reasonable -- in such cases you should
> consider using WARN_ON_ONCE() or similar.
> 
actually, another patch for API function within /lib/ioremap.c used the 
way as pointed by you as below, i am not sure which is better, perhaps i
will exchange each other

Subject: [PATCH 2/3] lib/ioremap.c: avoid endless loop under ioremapping
improper ranges

for ioremap_page_range(), endless loop maybe happen if either of parameter
addr and end is not page aligned, in order to fix this issue and hint range
parameter requirements BUG_ON() checkup are performed firstly

for ioremap_pte_range(), loop end condition is optimized due to lack of
relevant macro pte_addr_end()

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 lib/ioremap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 86c8911..0058cc8 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
 		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, addr < end);
 	return 0;
 }
 
@@ -129,6 +129,7 @@ int ioremap_page_range(unsigned long addr,
 	int err;
 
 	BUG_ON(addr >= end);
+	BUG_ON(!PAGE_ALIGNED(addr | end));
 
 	start = addr;
 	phys_addr -= addr;

> Thanks,
> Nick
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

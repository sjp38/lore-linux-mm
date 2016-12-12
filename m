Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2653D6B0261
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 04:54:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so234690390pgq.7
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 01:54:41 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id s136si42708199pgc.65.2016.12.12.01.54.39
        for <linux-mm@kvack.org>;
        Mon, 12 Dec 2016 01:54:40 -0800 (PST)
Subject: Re: [PATCH] arm64: mm: Fix NOMAP page initialization
References: <1481307042-29773-1-git-send-email-rrichter@cavium.com>
 <83d6e6d0-cfb3-ec8b-241b-ec6a50dc2aa9@huawei.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <9168b603-04aa-4302-3197-00f17fb336bd@huawei.com>
Date: Mon, 12 Dec 2016 17:53:02 +0800
MIME-Version: 1.0
In-Reply-To: <83d6e6d0-cfb3-ec8b-241b-ec6a50dc2aa9@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <rrichter@cavium.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will
 Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, James Morse <james.morse@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>

hi Robert,

On 2016/12/12 11:12, Yisheng Xie wrote:
> hi Robert,
> 
> On 2016/12/10 2:10, Robert Richter wrote:
>> On ThunderX systems with certain memory configurations we see the
>> following BUG_ON():
>>
>>  kernel BUG at mm/page_alloc.c:1848!
>>
>> This happens for some configs with 64k page size enabled. The BUG_ON()
>> checks if start and end page of a memmap range belongs to the same
>> zone.
>>
>> The BUG_ON() check fails if a memory zone contains NOMAP regions. In
>> this case the node information of those pages is not initialized. This
>> causes an inconsistency of the page links with wrong zone and node
>> information for that pages. NOMAP pages from node 1 still point to the
>> mem zone from node 0 and have the wrong nid assigned.
>>
> The patch can work for zone contains NOMAP regions.
> 
> However, if BIOS do not add WB/WT/WC attribute to a physical address range, the
> is_memory(md) will return false and this range will not be added to memblock.
>    efi_init
>       -> reserve_regions
>             if (is_memory(md)) {
>                 early_init_dt_add_memory_arch(paddr, size);
> 
>                 if (!is_usable_memory(md))
>                     memblock_mark_nomap(paddr, size);
>             }
> 
> Then BUG_ON() check will also fails. Any idea about it?
> 
It seems that memblock_is_memory() is also too strict for early_pfn_valid,
so what about this patch, which use common pfn_valid as early_pfn_valid
when CONFIG_HAVE_ARCH_PFN_VALID=y:
------------
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0f088f3..9d596f3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1200,7 +1200,17 @@ static inline int pfn_present(unsigned long pfn)
 #define pfn_to_nid(pfn)                (0)
 #endif

+#ifdef CONFIG_HAVE_ARCH_PFN_VALID
+static inline int early_pfn_valid(unsigned long pfn)
+{
+       if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+               return 0;
+       return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
+}
+#define early_pfn_valid early_pfn_valid
+#else
 #define early_pfn_valid(pfn)   pfn_valid(pfn)
+#endif
 void sparse_init(void);
 #else
 #define sparse_init()  do {} while (0)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

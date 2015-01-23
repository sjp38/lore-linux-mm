Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 029DB6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 19:33:24 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id b16so3939644igk.1
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:33:23 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ro9si498883igb.51.2015.01.22.16.33.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 16:33:23 -0800 (PST)
Message-ID: <54C196D0.6040900@codeaurora.org>
Date: Thu, 22 Jan 2015 16:33:20 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv2] mm: Don't offset memmap for flatmem
References: <1421804273-29947-1-git-send-email-lauraa@codeaurora.org>	<1421888500-24364-1-git-send-email-lauraa@codeaurora.org> <20150122162021.aa861aeb53c22206a19ebbcb@linux-foundation.org>
In-Reply-To: <20150122162021.aa861aeb53c22206a19ebbcb@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, ssantosh@kernel.org, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, linux-mm@kvack.org, Kumar Gala <galak@codeaurora.org>

On 1/22/2015 4:20 PM, Andrew Morton wrote:
> On Wed, 21 Jan 2015 17:01:40 -0800 Laura Abbott <lauraa@codeaurora.org> wrote:
>
>> Srinivas Kandagatla reported bad page messages when trying to
>> remove the bottom 2MB on an ARM based IFC6410 board
>>
>> BUG: Bad page state in process swapper  pfn:fffa8
>> page:ef7fb500 count:0 mapcount:0 mapping:  (null) index:0x0
>> flags: 0x96640253(locked|error|dirty|active|arch_1|reclaim|mlocked)
>> page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
>> bad because of flags:
>> flags: 0x200041(locked|active|mlocked)
>> Modules linked in:
>> CPU: 0 PID: 0 Comm: swapper Not tainted 3.19.0-rc3-00007-g412f9ba-dirty #816
>> Hardware name: Qualcomm (Flattened Device Tree)
>> [<c0218280>] (unwind_backtrace) from [<c0212be8>] (show_stack+0x20/0x24)
>> [<c0212be8>] (show_stack) from [<c0af7124>] (dump_stack+0x80/0x9c)
>> [<c0af7124>] (dump_stack) from [<c0301570>] (bad_page+0xc8/0x128)
>> [<c0301570>] (bad_page) from [<c03018a8>] (free_pages_prepare+0x168/0x1e0)
>> [<c03018a8>] (free_pages_prepare) from [<c030369c>] (free_hot_cold_page+0x3c/0x174)
>> [<c030369c>] (free_hot_cold_page) from [<c0303828>] (__free_pages+0x54/0x58)
>> [<c0303828>] (__free_pages) from [<c030395c>] (free_highmem_page+0x38/0x88)
>> [<c030395c>] (free_highmem_page) from [<c0f62d5c>] (mem_init+0x240/0x430)
>> [<c0f62d5c>] (mem_init) from [<c0f5db3c>] (start_kernel+0x1e4/0x3c8)
>> [<c0f5db3c>] (start_kernel) from [<80208074>] (0x80208074)
>> Disabling lock debugging due to kernel taint
>>
>> Removing the lower 2MB made the start of the lowmem zone to no longer
>> be page block aligned. IFC6410 uses CONFIG_FLATMEM where
>> alloc_node_mem_map allocates memory for the mem_map. alloc_node_mem_map
>> will offset for unaligned nodes with the assumption the pfn/page
>> translation functions will account for the offset. The functions for
>> CONFIG_FLATMEM do not offset however, resulting in overrunning
>> the memmap array. Just use the allocated memmap without any offset
>> when running with CONFIG_FLATMEM to avoid the overrun.
>>
>
> I don't think v2 addressed Vlastimil's review comment?
>

We're still adding the offset to node_mem_map and then subtracting it from
just mem_map. Did I miss another comment somewhere?


-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

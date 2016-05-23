Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F68E6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 14:35:19 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id dr7so20806925pac.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 11:35:19 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id xs13si53465307pac.140.2016.05.23.11.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 11:35:18 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id y69so67201011pfb.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 11:35:18 -0700 (PDT)
Subject: Re: [PATCH] mm: make CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on
 !FLATMEM explicitly
References: <1464022471-30545-1-git-send-email-yang.shi@linaro.org>
 <20160523182252.GD32715@dhcp22.suse.cz>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <400273a8-e764-53df-84d3-4ee4d4e22098@linaro.org>
Date: Mon, 23 May 2016 11:35:16 -0700
MIME-Version: 1.0
In-Reply-To: <20160523182252.GD32715@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/23/2016 11:22 AM, Michal Hocko wrote:
> On Mon 23-05-16 09:54:31, Yang Shi wrote:
>> Per the suggestion from Michal Hocko [1], CONFIG_DEFERRED_STRUCT_PAGE_INIT
>> should be incompatible with FLATMEM, make this explicitly in Kconfig.
>
> I guess the changelog could benefit from some clarification. What
> do you think about the following:
>
> "
> DEFERRED_STRUCT_PAGE_INIT requires some ordering wrt other
> initialization operations, e.g. page_ext_init has to happen after the
> whole memmap is initialized properly. For SPARSEMEM this requires to
> wait for page_alloc_init_late. Other memory models (e.g. flatmem) might
> have different initialization layouts (page_ext_init_flatmem). Currently
> DEFERRED_STRUCT_PAGE_INIT depends on MEMORY_HOTPLUG which in turn
> 	depends on SPARSEMEM || X86_64_ACPI_NUMA
> 	depends on ARCH_ENABLE_MEMORY_HOTPLUG
>
> and X86_64_ACPI_NUMA depends on NUMA which in turn disable FLATMEM
> memory model:
> config ARCH_FLATMEM_ENABLE
> 	def_bool y
> 	depends on X86_32 && !NUMA
>
> so FLATMEM is ruled out via dependency maze. Be explicit and disable
> FLATMEM for DEFERRED_STRUCT_PAGE_INIT so that we do not reintroduce
> subtle initialization bugs
> "

Thanks a lot. It sounds way better. Will address in V2.

Yang

>
>>
>> [1] http://lkml.kernel.org/r/20160523073157.GD2278@dhcp22.suse.cz
>>
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> ---
>>  mm/Kconfig | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 2664c11..22fa818 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -649,6 +649,7 @@ config DEFERRED_STRUCT_PAGE_INIT
>>  	default n
>>  	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>>  	depends on MEMORY_HOTPLUG
>> +	depends on !FLATMEM
>>  	help
>>  	  Ordinarily all struct pages are initialised during early boot in a
>>  	  single thread. On very large machines this can take a considerable
>> --
>> 2.0.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

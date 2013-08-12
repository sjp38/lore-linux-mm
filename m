Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 2FCAB6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:02:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Mon, 12 Aug 2013 22:51:11 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id BFEA12CE8051
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 23:01:54 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7CCjwuQ47120484
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 22:45:59 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7CD1rnk003791
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 23:01:53 +1000
Message-ID: <5208DCBC.7060205@linux.vnet.ibm.com>
Date: Mon, 12 Aug 2013 08:01:48 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Register bootmem pages at boot on powerpc
References: <52050ACE.4090001@linux.vnet.ibm.com> <52050B80.8010602@linux.vnet.ibm.com> <1376266763.32100.144.camel@pasglop>
In-Reply-To: <1376266763.32100.144.camel@pasglop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On 08/11/2013 07:19 PM, Benjamin Herrenschmidt wrote:
> On Fri, 2013-08-09 at 10:32 -0500, Nathan Fontenot wrote:
> 
>> +void register_page_bootmem_memmap(unsigned long section_nr,
>> +				  struct page *start_page, unsigned long size)
>> +{
>> +	WARN_ONCE(1, KERN_INFO
>> +		  "Sparse Vmemmap not fully supported for bootmem info nodes\n");
>> +}
>>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> 
> But SPARSEMEM_VMEMMAP is our default on ppc64 pseries ... and you are
> select'ing the new option, so it looks like we are missing something
> here...
> 
> Can you tell me a bit more, the above makes me nervous...

Ok, I agree. that message isn't quite right.

What I wanted to convey is that memory hotplug is not fully supported
on powerpc with SPARSE_VMEMMAP enabled.. Perhaps the message should read
"Memory hotplug is not fully supported for bootmem info nodes".

Thoughts?

-Nathan

> 
> Cheers,
> Ben.
> 
>> Index: powerpc/arch/powerpc/mm/mem.c
>> ===================================================================
>> --- powerpc.orig/arch/powerpc/mm/mem.c
>> +++ powerpc/arch/powerpc/mm/mem.c
>> @@ -297,12 +297,21 @@ void __init paging_init(void)
>>  }
>>  #endif /* ! CONFIG_NEED_MULTIPLE_NODES */
>>
>> +static void __init register_page_bootmem_info(void)
>> +{
>> +	int i;
>> +
>> +	for_each_online_node(i)
>> +		register_page_bootmem_info_node(NODE_DATA(i));
>> +}
>> +
>>  void __init mem_init(void)
>>  {
>>  #ifdef CONFIG_SWIOTLB
>>  	swiotlb_init(0);
>>  #endif
>>
>> +	register_page_bootmem_info();
>>  	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
>>  	set_max_mapnr(max_pfn);
>>  	free_all_bootmem();
>> Index: powerpc/mm/Kconfig
>> ===================================================================
>> --- powerpc.orig/mm/Kconfig
>> +++ powerpc/mm/Kconfig
>> @@ -183,7 +183,7 @@ config MEMORY_HOTPLUG_SPARSE
>>  config MEMORY_HOTREMOVE
>>  	bool "Allow for memory hot remove"
>>  	select MEMORY_ISOLATION
>> -	select HAVE_BOOTMEM_INFO_NODE if X86_64
>> +	select HAVE_BOOTMEM_INFO_NODE if (X86_64 || PPC64)
>>  	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>>  	depends on MIGRATION
>>
>>
>> _______________________________________________
>> Linuxppc-dev mailing list
>> Linuxppc-dev@lists.ozlabs.org
>> https://lists.ozlabs.org/listinfo/linuxppc-dev
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

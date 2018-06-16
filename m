Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4258D6B0005
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 04:04:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f65-v6so2409073wmd.2
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 01:04:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e6-v6sor974319wmh.3.2018.06.16.01.04.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Jun 2018 01:04:23 -0700 (PDT)
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
 <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
From: Jiri Slaby <jslaby@suse.cz>
Message-ID: <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
Date: Sat, 16 Jun 2018 10:04:21 +0200
MIME-Version: 1.0
In-Reply-To: <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, arbab@linux.vnet.ibm.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, mgorman@techsingularity.net

On 11/21/2017, 08:24 AM, Michal Hocko wrote:
> On Thu 16-11-17 20:46:01, Pavel Tatashin wrote:
>> There is no need to have ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT,
>> as all the page initialization code is in common code.
>>
>> Also, there is no need to depend on MEMORY_HOTPLUG, as initialization code
>> does not really use hotplug memory functionality. So, we can remove this
>> requirement as well.
>>
>> This patch allows to use deferred struct page initialization on all
>> platforms with memblock allocator.
>>
>> Tested on x86, arm64, and sparc. Also, verified that code compiles on
>> PPC with CONFIG_MEMORY_HOTPLUG disabled.
> 
> There is slight risk that we will encounter corner cases on some
> architectures with weird memory layout/topology

Which x86_32-pae seems to be. Many bad page state errors are emitted
during boot when this patch is applied:
BUG: Bad page state in process swapper  pfn:3c01c
page:f566c3f0 count:0 mapcount:1 mapping:00000000 index:0x0
flags: 0x0()
raw: 00000000 00000000 00000000 00000000 00000000 00000100 00000200 00000000
raw: 00000000
page dumped because: nonzero mapcount
Modules linked in:
CPU: 0 PID: 0 Comm: swapper Tainted: G    B
4.17.1-4.gdf028bb-pae #1 openSUSE Tumbleweed (unreleased)
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.0.0-prebuilt.qemu-project.org 04/01/2014
Call Trace:
 dump_stack+0x7d/0xbd
 bad_page.cold.111+0x90/0xc7
 free_pages_check_bad+0x52/0x70
 free_pcppages_bulk+0x37d/0x570
 free_unref_page_commit+0x9a/0xc0
 free_unref_page+0x6a/0xa0
 __free_pages+0x17/0x30
 free_highmem_page+0x1e/0x50
 add_highpages_with_active_regions+0xd6/0x113
 set_highmem_pages_init+0x67/0x7d
 mem_init+0x23/0x1d9
 start_kernel+0x1c2/0x437
 i386_start_kernel+0x98/0x9c
 startup_32_smp+0x164/0x168

free_pages_check_bad expects mapcount == -1, but it is 1 with this patch.

Reverting the patch makes the BUGs go away -- the config diff is then:
@@ -617,7 +617,7 @@
 # CONFIG_PGTABLE_MAPPING is not set
 # CONFIG_ZSMALLOC_STAT is not set
 CONFIG_GENERIC_EARLY_IOREMAP=y
-CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
+CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
 # CONFIG_IDLE_PAGE_TRACKING is not set
 CONFIG_FRAME_VECTOR=y
 # CONFIG_PERCPU_STATS is not set

>> --- a/arch/powerpc/Kconfig
>> +++ b/arch/powerpc/Kconfig
>> @@ -148,7 +148,6 @@ config PPC
>>  	select ARCH_MIGHT_HAVE_PC_PARPORT
>>  	select ARCH_MIGHT_HAVE_PC_SERIO
>>  	select ARCH_SUPPORTS_ATOMIC_RMW
>> -	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>>  	select ARCH_USE_BUILTIN_BSWAP
>>  	select ARCH_USE_CMPXCHG_LOCKREF		if PPC64
>>  	select ARCH_WANT_IPC_PARSE_VERSION
>> diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
>> index 863a62a6de3c..525c2e3df6f5 100644
>> --- a/arch/s390/Kconfig
>> +++ b/arch/s390/Kconfig
>> @@ -108,7 +108,6 @@ config S390
>>  	select ARCH_INLINE_WRITE_UNLOCK_IRQRESTORE
>>  	select ARCH_SAVE_PAGE_KEYS if HIBERNATION
>>  	select ARCH_SUPPORTS_ATOMIC_RMW
>> -	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>>  	select ARCH_SUPPORTS_NUMA_BALANCING
>>  	select ARCH_USE_BUILTIN_BSWAP
>>  	select ARCH_USE_CMPXCHG_LOCKREF
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index df3276d6bfe3..00a5446de394 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -69,7 +69,6 @@ config X86
>>  	select ARCH_MIGHT_HAVE_PC_PARPORT
>>  	select ARCH_MIGHT_HAVE_PC_SERIO
>>  	select ARCH_SUPPORTS_ATOMIC_RMW
>> -	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>>  	select ARCH_SUPPORTS_NUMA_BALANCING	if X86_64
>>  	select ARCH_USE_BUILTIN_BSWAP
>>  	select ARCH_USE_QUEUED_RWLOCKS
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 9c4bdddd80c2..c6bd0309ce7a 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -639,15 +639,10 @@ config MAX_STACK_SIZE_MB
>>  
>>  	  A sane initial value is 80 MB.
>>  
>> -# For architectures that support deferred memory initialisation
>> -config ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>> -	bool
>> -
>>  config DEFERRED_STRUCT_PAGE_INIT
>>  	bool "Defer initialisation of struct pages to kthreads"
>>  	default n
>> -	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>> -	depends on NO_BOOTMEM && MEMORY_HOTPLUG
>> +	depends on NO_BOOTMEM
>>  	depends on !FLATMEM
>>  	help
>>  	  Ordinarily all struct pages are initialised during early boot in a

thanks,
-- 
js
suse labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id C9F306B005D
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 06:10:59 -0500 (EST)
Message-ID: <50F7D456.9000904@cn.fujitsu.com>
Date: Thu, 17 Jan 2013 18:37:10 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/2] memory-hotplug: introduce CONFIG_HAVE_BOOTMEM_INFO_NODE
 and revert register_page_bootmem_info_node() when platform not support
References: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com> <1358324059-9608-2-git-send-email-linfeng@cn.fujitsu.com> <20130116141436.GE343@dhcp22.suse.cz>
In-Reply-To: <20130116141436.GE343@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, jbeulich@suse.com, dhowells@redhat.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, paul.gortmaker@windriver.com, laijs@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, jiang.liu@huawei.com, tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, michael@ellerman.id.au, gerald.schaefer@de.ibm.com, gregkh@linuxfoundation.org, x86@kernel.org, linux390@de.ibm.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

Hi Michal,

On 01/16/2013 10:14 PM, Michal Hocko wrote:
> On Wed 16-01-13 16:14:18, Lin Feng wrote:
> [...]
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 278e3ab..f8c5799 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -162,10 +162,18 @@ config MOVABLE_NODE
>>  	  Say Y here if you want to hotplug a whole node.
>>  	  Say N here if you want kernel to use memory on all nodes evenly.
>>  
>> +#
>> +# Only be set on architectures that have completely implemented memory hotplug
>> +# feature. If you are not sure, don't touch it.
>> +#
>> +config HAVE_BOOTMEM_INFO_NODE
>> +	def_bool n
>> +
>>  # eventually, we can have this option just 'select SPARSEMEM'
>>  config MEMORY_HOTPLUG
>>  	bool "Allow for memory hot-add"
>>  	select MEMORY_ISOLATION
>> +	select HAVE_BOOTMEM_INFO_NODE if X86_64
>>  	depends on SPARSEMEM || X86_64_ACPI_NUMA
>>  	depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
>>  	depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)
> 
> I am still not sure I understand the relation to MEMORY_HOTREMOVE.
> Is register_page_bootmem_info_node required/helpful even if
> !CONFIG_MEMORY_HOTREMOVE?
>From old kenrel's view register_page_bootmem_info_node() is defined in 
CONFIG_MEMORY_HOTPLUG_SPARSE, it registers some info for 
memory hotplug/remove. If we don't use MEMORY_HOTPLUG feature, this
function is empty, we don't need the info at all.
So this info is not required/helpful if !CONFIG_MEMORY_HOTREMOVE.
> 
> Also, now that I am thinking about that more, maybe it would
> be cleaner to put the select into arch/x86/Kconfig and do it
> same as ARCH_ENABLE_MEMORY_{HOTPLUG,HOTREMOVE} (and name it
> ARCH_HAVE_BOOTMEM_INFO_NODE).
> 
Maybe put it in mm/Kconfig is a better choice, because if one day someone implements
the register_page_bootmem_info_node() for other archs they will get some clues
here, that's it has been implemented on x86_64. 
But I'm not so sure...

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5CB606B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:16:49 -0500 (EST)
Message-ID: <4B969E6F.3010605@redhat.com>
Date: Tue, 09 Mar 2010 14:15:59 -0500
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH]: ACPI: Automatically online hot-added memory
References: <20100309141203.10037.62453.sendpatchset@prarit.bos.redhat.com> <20100309191004.GA20079@grease>
In-Reply-To: <20100309191004.GA20079@grease>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



Alex Chiang wrote:
> I think if you're going to poke into drivers/base/memory.c we
> should let the -mm guys know that you're creating a new
> interface.
>   

Absolutely -- I was just RFC'ing for now ;)

> The ACPI part looks fine to me.
>
> cc added.
>
>   

Thanks :)

P.

> /ac
>
> * Prarit Bhargava <prarit@redhat.com>:
>   
>> New sockets have on-die memory controllers.  This means that in certain
>> HW configurations the memory behind the socket comes and goes as the socket
>> is physically enabled and disabled.
>>
>> Since the cpu bringup code does on node memory allocations, the memory on the
>> added socket must be onlined first.
>>
>> Add a .config option to automatically online hot added memory, and enable it
>> in the acpi memory add path.
>>
>> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>>
>> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
>> index 93d2c79..dece6bd 100644
>> --- a/drivers/acpi/Kconfig
>> +++ b/drivers/acpi/Kconfig
>> @@ -350,6 +350,14 @@ config ACPI_HOTPLUG_MEMORY
>>  	  To compile this driver as a module, choose M here:
>>  	  the module will be called acpi_memhotplug.
>>  
>> +config ACPI_HOTPLUG_MEMORY_AUTO_ONLINE
>> +	bool "Automatically online hotplugged memory"
>> +	depends on ACPI_HOTPLUG_MEMORY
>> +	default n
>> +	help
>> +	  This forces memory that is brought into service by ACPI
>> +	  to be automatically onlined.
>> +
>>  config ACPI_SBS
>>  	tristate "Smart Battery System"
>>  	depends on X86
>> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
>> index 3597d73..9814c50 100644
>> --- a/drivers/acpi/acpi_memhotplug.c
>> +++ b/drivers/acpi/acpi_memhotplug.c
>> @@ -30,6 +30,7 @@
>>  #include <linux/init.h>
>>  #include <linux/types.h>
>>  #include <linux/memory_hotplug.h>
>> +#include <linux/memory.h>
>>  #include <acpi/acpi_drivers.h>
>>  
>>  #define ACPI_MEMORY_DEVICE_CLASS		"memory"
>> @@ -252,6 +253,19 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>>  		result = add_memory(node, info->start_addr, info->length);
>>  		if (result)
>>  			continue;
>> +#ifdef CONFIG_ACPI_HOTPLUG_MEMORY_AUTO_ONLINE
>> +		/*
>> +		 * New processors require memory to be online before cpus.
>> +		 * No notifications are required here as "we" are the only
>> +		 * ones who know about the new memory right now.
>> +		 */
>> +		result = online_pages(info->start_addr >> PAGE_SHIFT,
>> +				      info->length >> PAGE_SHIFT);
>> +		if (!result)
>> +			set_memory_state(info->start_addr, MEM_ONLINE);
>> +		else
>> +			printk("Memory online failed.\n");
>> +#endif
>>  		info->enabled = 1;
>>  		num_enabled++;
>>  	}
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 2f86915..fb465d5 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -510,6 +510,20 @@ int remove_memory_block(unsigned long node_id, struct mem_section *section,
>>  }
>>  
>>  /*
>> + * need an interface for the VM to mark sections on and offline when hot-adding
>> + * memory.
>> + */
>> +void set_memory_state(unsigned long addr, unsigned long state)
>> +{
>> +	struct mem_section *section;
>> +	struct memory_block *mem;
>> +
>> +	section = __pfn_to_section(addr >> PAGE_SHIFT);
>> +	mem = find_memory_block(section);
>> +	mem->state = state;
>> +}
>> +
>> +/*
>>   * need an interface for the VM to add new memory regions,
>>   * but without onlining it.
>>   */
>> diff --git a/include/linux/memory.h b/include/linux/memory.h
>> index 1adfe77..5d8d78c 100644
>> --- a/include/linux/memory.h
>> +++ b/include/linux/memory.h
>> @@ -112,6 +112,7 @@ extern int remove_memory_block(unsigned long, struct mem_section *, int);
>>  extern int memory_notify(unsigned long val, void *v);
>>  extern int memory_isolate_notify(unsigned long val, void *v);
>>  extern struct memory_block *find_memory_block(struct mem_section *);
>> +extern void set_memory_state(unsigned long, unsigned long);
>>  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>>  enum mem_add_context { BOOT, HOTPLUG };
>>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>     

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 627EA6B02A4
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:30:14 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GFM9Pb001162
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 09:22:09 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GFTxd1118234
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 09:30:09 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GFXFk6006324
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 09:33:15 -0600
Message-ID: <4C407AEC.9080504@austin.ibm.com>
Date: Fri, 16 Jul 2010 10:29:48 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] v2 Split the memory_block structure
References: <4C3F53D1.3090001@austin.ibm.com>	<4C3F557F.3000304@austin.ibm.com> <20100716090637.3654f91d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100716090637.3654f91d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

Thanks for taking a look a this Kame, answers below...

-Nathan

On 07/15/2010 07:06 PM, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Jul 2010 13:37:51 -0500
> Nathan Fontenot <nfont@austin.ibm.com> wrote:
> 
>> Split the memory_block struct into a memory_block
>> struct to cover each sysfs directory and a new memory_block_section
>> struct for each memory section covered by the sysfs directory.
>> This change allows for creation of memory sysfs directories that
>> can span multiple memory sections.
>>
>> This can be beneficial in that it can reduce the number of memory
>> sysfs directories created at boot.  This also allows different
>> architectures to define how many memory sections are covered by
>> a sysfs directory.
>>
>> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
>> ---
>>  drivers/base/memory.c  |  222 ++++++++++++++++++++++++++++++++++---------------
>>  include/linux/memory.h |   11 +-
>>  2 files changed, 167 insertions(+), 66 deletions(-)
>>
>> Index: linux-2.6/drivers/base/memory.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/base/memory.c	2010-07-15 08:48:41.000000000 -0500
>> +++ linux-2.6/drivers/base/memory.c	2010-07-15 09:55:54.000000000 -0500
>> @@ -28,6 +28,14 @@
>>  #include <asm/uaccess.h>
>>  
>>  #define MEMORY_CLASS_NAME	"memory"
>> +#define MIN_MEMORY_BLOCK_SIZE	(1 << SECTION_SIZE_BITS)
>> +
>> +static int sections_per_block;
>> +
>> +static inline int base_memory_block_id(int section_nr)
>> +{
>> +	return (section_nr / sections_per_block) * sections_per_block;
>> +}
>>  
>>  static struct sysdev_class memory_sysdev_class = {
>>  	.name = MEMORY_CLASS_NAME,
>> @@ -94,10 +102,9 @@
>>  }
>>  
>>  static void
>> -unregister_memory(struct memory_block *memory, struct mem_section *section)
>> +unregister_memory(struct memory_block *memory)
>>  {
>>  	BUG_ON(memory->sysdev.cls != &memory_sysdev_class);
>> -	BUG_ON(memory->sysdev.id != __section_nr(section));
>>  
>>  	/* drop the ref. we got in remove_memory_block() */
>>  	kobject_put(&memory->sysdev.kobj);
>> @@ -123,13 +130,20 @@
>>  static ssize_t show_mem_removable(struct sys_device *dev,
>>  			struct sysdev_attribute *attr, char *buf)
>>  {
>> +	struct memory_block *mem;
>> +	struct memory_block_section *mbs;
>>  	unsigned long start_pfn;
>> -	int ret;
>> -	struct memory_block *mem =
>> -		container_of(dev, struct memory_block, sysdev);
>> +	int ret = 1;
>> +
>> +	mem = container_of(dev, struct memory_block, sysdev);
>> +	mutex_lock(&mem->state_mutex);
>>  
>> -	start_pfn = section_nr_to_pfn(mem->phys_index);
>> -	ret = is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
>> +	list_for_each_entry(mbs, &mem->sections, next) {
>> +		start_pfn = section_nr_to_pfn(mbs->phys_index);
>> +		ret &= is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
>> +	}
>> +
>> +	mutex_unlock(&mem->state_mutex);
> 
> Hmm, this means memory cab be offlined the while memory block section. Right ?
> Please write this fact in patch description...
> And Documentaion/memory_hotplug.txt as "From user's perspective, memory section
> is not a unit of memory hotplug anymore".
> And descirbe about a new rule.

You are correct.  A memory block is removable only if all of the memory
sections contained within the memory block are removable.

I will include a documentation patch with v3 of the patches to explain this
and to explain that memory add/remove operations are done on a per memory
block basis.

> 
> 
>>  	return sprintf(buf, "%d\n", ret);
>>  }
>>  
>> @@ -182,16 +196,16 @@
>>   * OK to have direct references to sparsemem variables in here.
>>   */
>>  static int
>> -memory_block_action(struct memory_block *mem, unsigned long action)
>> +memory_block_action(struct memory_block_section *mbs, unsigned long action)
>>  {
>>  	int i;
>>  	unsigned long psection;
>>  	unsigned long start_pfn, start_paddr;
>>  	struct page *first_page;
>>  	int ret;
>> -	int old_state = mem->state;
>> +	int old_state = mbs->state;
>>  
>> -	psection = mem->phys_index;
>> +	psection = mbs->phys_index;
>>  	first_page = pfn_to_page(psection << PFN_SECTION_SHIFT);
>>  
>>  	/*
>> @@ -217,18 +231,18 @@
>>  			ret = online_pages(start_pfn, PAGES_PER_SECTION);
>>  			break;
>>  		case MEM_OFFLINE:
>> -			mem->state = MEM_GOING_OFFLINE;
>> +			mbs->state = MEM_GOING_OFFLINE;
>>  			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
>>  			ret = remove_memory(start_paddr,
>>  					    PAGES_PER_SECTION << PAGE_SHIFT);
>>  			if (ret) {
>> -				mem->state = old_state;
>> +				mbs->state = old_state;
>>  				break;
>>  			}
>>  			break;
>>  		default:
>>  			WARN(1, KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
>> -					__func__, mem, action, action);
>> +					__func__, mbs, action, action);
>>  			ret = -EINVAL;
>>  	}
>>  
>> @@ -238,19 +252,34 @@
> 
> And please check quilt's diff option.
> Usual patche in ML shows a function name in any changes, as
> @@ -241,6 +293,8 @@ static int memory_block_change_state(str
> 
> Maybe "-p" option is lacked..

sorry about that.  I'm just using the default options with quilt.  I'll
play around with it to why this is happening.

> 
> 
>>  static int memory_block_change_state(struct memory_block *mem,
>>  		unsigned long to_state, unsigned long from_state_req)
>>  {
>> +	struct memory_block_section *mbs;
>>  	int ret = 0;
>> +
>>  	mutex_lock(&mem->state_mutex);
>>  
>> -	if (mem->state != from_state_req) {
>> -		ret = -EINVAL;
>> -		goto out;
>> +	list_for_each_entry(mbs, &mem->sections, next) {
>> +		if (mbs->state != from_state_req)
>> +			continue;
>> +
>> +		ret = memory_block_action(mbs, to_state);
>> +		if (ret)
>> +			break;
>> +	}
>> +
>> +	if (ret) {
>> +		list_for_each_entry(mbs, &mem->sections, next) {
>> +			if (mbs->state == from_state_req)
>> +				continue;
>> +
>> +			if (memory_block_action(mbs, to_state))
>> +				printk(KERN_ERR "Could not re-enable memory "
>> +				       "section %lx\n", mbs->phys_index);
> 
> Why re-enable only ? online->fail->offline never happens ?
> If so, please add comment at least.

This should handle both conditions.  If we fail to move all of the memory
sections to the 'to_state', it puts all of the memory sections back to the
'from_state_req'.

> BTW, is it guaranteed that all sections under a block has same state after
> boot ?

Yes, during boot all memory sections are marked online.

> 
>> +		}
>>  	}
>>  
>> -	ret = memory_block_action(mem, to_state);
>>  	if (!ret)
>>  		mem->state = to_state;
>>  
>> -out:
>>  	mutex_unlock(&mem->state_mutex);
>>  	return ret;
>>  }
>> @@ -260,20 +289,15 @@
>>  		struct sysdev_attribute *attr, const char *buf, size_t count)
>>  {
>>  	struct memory_block *mem;
>> -	unsigned int phys_section_nr;
>>  	int ret = -EINVAL;
>>  
>>  	mem = container_of(dev, struct memory_block, sysdev);
>> -	phys_section_nr = mem->phys_index;
>> -
>> -	if (!present_section_nr(phys_section_nr))
>> -		goto out;
>>
> I'm sorry but I couldn't remember why this check was necessary...

Not sure either, it appears that it is there to ensure that the memory
section we are trying to act on is actually present.

> 
> 
>  
>>  	if (!strncmp(buf, "online", min((int)count, 6)))
>>  		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
>>  	else if(!strncmp(buf, "offline", min((int)count, 7)))
>>  		ret = memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE);
>> -out:
>> +
>>  	if (ret)
>>  		return ret;
>>  	return count;
>> @@ -435,39 +459,6 @@
>>  	return 0;
>>  }
>>  
>> -static int add_memory_block(int nid, struct mem_section *section,
>> -			unsigned long state, enum mem_add_context context)
>> -{
>> -	struct memory_block *mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>> -	unsigned long start_pfn;
>> -	int ret = 0;
>> -
>> -	if (!mem)
>> -		return -ENOMEM;
>> -
>> -	mem->phys_index = __section_nr(section);
>> -	mem->state = state;
>> -	mutex_init(&mem->state_mutex);
>> -	start_pfn = section_nr_to_pfn(mem->phys_index);
>> -	mem->phys_device = arch_get_memory_phys_device(start_pfn);
>> -
>> -	ret = register_memory(mem, section);
>> -	if (!ret)
>> -		ret = mem_create_simple_file(mem, phys_index);
>> -	if (!ret)
>> -		ret = mem_create_simple_file(mem, state);
>> -	if (!ret)
>> -		ret = mem_create_simple_file(mem, phys_device);
>> -	if (!ret)
>> -		ret = mem_create_simple_file(mem, removable);
>> -	if (!ret) {
>> -		if (context == HOTPLUG)
>> -			ret = register_mem_sect_under_node(mem, nid);
>> -	}
>> -
>> -	return ret;
>> -}
>> -
> 
> I don't say strongly but this kind of move-code should be done in another patch.

ok,  I will move the code move piece to a differnet patch.

> 
> 
>>  /*
>>   * For now, we have a linear search to go find the appropriate
>>   * memory_block corresponding to a particular phys_index. If
>> @@ -482,12 +473,13 @@
>>  	struct sys_device *sysdev;
>>  	struct memory_block *mem;
>>  	char name[sizeof(MEMORY_CLASS_NAME) + 9 + 1];
>> +	int block_id = base_memory_block_id(__section_nr(section));
>>  
>>  	/*
>>  	 * This only works because we know that section == sysdev->id
>>  	 * slightly redundant with sysdev_register()
>>  	 */
>> -	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, __section_nr(section));
>> +	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, block_id);
>>  
>>  	kobj = kset_find_obj(&memory_sysdev_class.kset, name);
>>  	if (!kobj)
>> @@ -499,18 +491,98 @@
>>  	return mem;
>>  }
>>  
>> +static int add_mem_block_section(struct memory_block *mem,
>> +				 int section_nr, unsigned long state)
>> +{
>> +	struct memory_block_section *mbs;
>> +
>> +	mbs = kzalloc(sizeof(*mbs), GFP_KERNEL);
>> +	if (!mbs)
>> +		return -ENOMEM;
>> +
>> +	mbs->phys_index = section_nr;
>> +	mbs->state = state;
>> +
>> +	list_add(&mbs->next, &mem->sections);
>> +	return 0;
>> +}
> 
> Doesn't this "sections" need to be sorted ? Hmm.

We could, but I cannot think of anything we gain by sorting it.

> 
> 
>> +
>> +static int add_memory_block(int nid, struct mem_section *section,
>> +			unsigned long state, enum mem_add_context context)
>> +{
>> +	struct memory_block *mem;
>> +	int ret = 0;
>> +
>> +	mem = find_memory_block(section);
>> +	if (!mem) {
>> +		unsigned long start_pfn;
>> +
>> +		mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>> +		if (!mem)
>> +			return -ENOMEM;
>> +
>> +		mem->state = state;
>> +		mutex_init(&mem->state_mutex);
>> +		start_pfn = section_nr_to_pfn(__section_nr(section));
>> +		mem->phys_device = arch_get_memory_phys_device(start_pfn);
>> +		INIT_LIST_HEAD(&mem->sections);
>> +
>> +		mutex_lock(&mem->state_mutex);
>> +
>> +		ret = register_memory(mem, section);
>> +		if (!ret)
>> +			ret = mem_create_simple_file(mem, phys_index);
>> +		if (!ret)
>> +			ret = mem_create_simple_file(mem, state);
>> +		if (!ret)
>> +			ret = mem_create_simple_file(mem, phys_device);
>> +		if (!ret)
>> +			ret = mem_create_simple_file(mem, removable);
>> +		if (!ret) {
>> +			if (context == HOTPLUG)
>> +				ret = register_mem_sect_under_node(mem, nid);
>> +		}
>> +	} else {
>> +		kobject_put(&mem->sysdev.kobj);
>> +		mutex_lock(&mem->state_mutex);
>> +	}
>> +
>> +	if (!ret)
>> +		ret = add_mem_block_section(mem, __section_nr(section), state);
>> +
>> +	mutex_unlock(&mem->state_mutex);
>> +	return ret;
>> +}
>> +
>>  int remove_memory_block(unsigned long node_id, struct mem_section *section,
>>  		int phys_device)
>>  {
>>  	struct memory_block *mem;
>> +	struct memory_block_section *mbs, *tmp;
>> +	int section_nr = __section_nr(section);
>>  
>>  	mem = find_memory_block(section);
>> -	unregister_mem_sect_under_nodes(mem);
>> -	mem_remove_simple_file(mem, phys_index);
>> -	mem_remove_simple_file(mem, state);
>> -	mem_remove_simple_file(mem, phys_device);
>> -	mem_remove_simple_file(mem, removable);
>> -	unregister_memory(mem, section);
>> +	mutex_lock(&mem->state_mutex);
>> +
>> +	/* remove the specified section */
>> +	list_for_each_entry_safe(mbs, tmp, &mem->sections, next) {
>> +		if (mbs->phys_index == section_nr) {
>> +			list_del(&mbs->next);
>> +			kfree(mbs);
>> +		}
>> +	}
>> +
>> +	mutex_unlock(&mem->state_mutex);
>> +
>> +	if (list_empty(&mem->sections)) {
>> +		unregister_mem_sect_under_nodes(mem);
>> +		mem_remove_simple_file(mem, phys_index);
>> +		mem_remove_simple_file(mem, state);
>> +		mem_remove_simple_file(mem, phys_device);
>> +		mem_remove_simple_file(mem, removable);
>> +		unregister_memory(mem);
>> +		kfree(mem);
>> +	}
>>  
>>  	return 0;
>>  }
>> @@ -532,6 +604,24 @@
>>  	return remove_memory_block(0, section, 0);
>>  }
>>  
>> +u32 __weak memory_block_size(void)
>> +{
>> +	return MIN_MEMORY_BLOCK_SIZE;
>> +}
>> +
>> +static u32 get_memory_block_size(void)
>> +{
>> +	u32 blk_sz;
>> +
>> +	blk_sz = memory_block_size();
>> +
>> +	/* Validate blk_sz is a power of 2 and not less than section size */
>> +	if ((blk_sz & (blk_sz - 1)) || (blk_sz < MIN_MEMORY_BLOCK_SIZE))
>> +		blk_sz = MIN_MEMORY_BLOCK_SIZE;
>> +
>> +	return blk_sz;
>> +}
>> +
>>  /*
>>   * Initialize the sysfs support for memory devices...
>>   */
>> @@ -540,12 +630,16 @@
>>  	unsigned int i;
>>  	int ret;
>>  	int err;
>> +	int block_sz;
>>  
>>  	memory_sysdev_class.kset.uevent_ops = &memory_uevent_ops;
>>  	ret = sysdev_class_register(&memory_sysdev_class);
>>  	if (ret)
>>  		goto out;
>>  
>> +	block_sz = get_memory_block_size();
>> +	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
>> +
>>  	/*
>>  	 * Create entries for memory sections that were found
>>  	 * during boot and have been initialized
>> Index: linux-2.6/include/linux/memory.h
>> ===================================================================
>> --- linux-2.6.orig/include/linux/memory.h	2010-07-15 08:48:41.000000000 -0500
>> +++ linux-2.6/include/linux/memory.h	2010-07-15 09:54:06.000000000 -0500
>> @@ -19,9 +19,15 @@
>>  #include <linux/node.h>
>>  #include <linux/compiler.h>
>>  #include <linux/mutex.h>
>> +#include <linux/list.h>
>>  
>> -struct memory_block {
>> +struct memory_block_section {
>> +	unsigned long state;
>>  	unsigned long phys_index;
>> +	struct list_head next;
>> +};
>> +
>> +struct memory_block {
>>  	unsigned long state;
>>  	/*
>>  	 * This serializes all state change requests.  It isn't
>> @@ -34,6 +40,7 @@
>>  	void *hw;			/* optional pointer to fw/hw data */
>>  	int (*phys_callback)(struct memory_block *);
>>  	struct sys_device sysdev;
>> +	struct list_head sections;
>>  };
>>  
>>  int arch_get_memory_phys_device(unsigned long start_pfn);
>> @@ -113,7 +120,7 @@
>>  extern int remove_memory_block(unsigned long, struct mem_section *, int);
>>  extern int memory_notify(unsigned long val, void *v);
>>  extern int memory_isolate_notify(unsigned long val, void *v);
>> -extern struct memory_block *find_memory_block(unsigned long);
>> +extern struct memory_block *find_memory_block(struct mem_section *);
>>  extern int memory_is_hidden(struct mem_section *);
>>  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>>  enum mem_add_context { BOOT, HOTPLUG };
>>
> 
> Okay, please go ahead. But my 1st impression is that IBM should increase ppc's
> SECTION_SIZE ;)
> 
> Thanks,
> -Kame
> 
> 
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

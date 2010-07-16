Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0298B6B02A4
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:15:29 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GH120u024286
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:01:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GHFO0G110606
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:15:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GHFNSr001753
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 14:15:24 -0300
Subject: Re: [PATCH 1/5] v2 Split the memory_block structure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C3F557F.3000304@austin.ibm.com>
References: <4C3F53D1.3090001@austin.ibm.com>
	 <4C3F557F.3000304@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 16 Jul 2010 10:15:21 -0700
Message-ID: <1279300521.9207.222.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-15 at 13:37 -0500, Nathan Fontenot wrote:
> @@ -123,13 +130,20 @@
>  static ssize_t show_mem_removable(struct sys_device *dev,
>  			struct sysdev_attribute *attr, char *buf)
>  {
> +	struct memory_block *mem;
> +	struct memory_block_section *mbs;
>  	unsigned long start_pfn;
> -	int ret;
> -	struct memory_block *mem =
> -		container_of(dev, struct memory_block, sysdev);
> +	int ret = 1;
> +
> +	mem = container_of(dev, struct memory_block, sysdev);
> +	mutex_lock(&mem->state_mutex);
> 
> -	start_pfn = section_nr_to_pfn(mem->phys_index);
> -	ret = is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
> +	list_for_each_entry(mbs, &mem->sections, next) {
> +		start_pfn = section_nr_to_pfn(mbs->phys_index);
> +		ret &= is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
> +	}
> +
> +	mutex_unlock(&mem->state_mutex);
>  	return sprintf(buf, "%d\n", ret);
>  }

Now that the "state_mutex" is getting used for other stuff, should we
just make it "mutex"?

> @@ -182,16 +196,16 @@
>   * OK to have direct references to sparsemem variables in here.
>   */
>  static int
> -memory_block_action(struct memory_block *mem, unsigned long action)
> +memory_block_action(struct memory_block_section *mbs, unsigned long action)
>  {
>  	int i;
>  	unsigned long psection;
>  	unsigned long start_pfn, start_paddr;
>  	struct page *first_page;
>  	int ret;
> -	int old_state = mem->state;
> +	int old_state = mbs->state;
> 
> -	psection = mem->phys_index;
> +	psection = mbs->phys_index;
>  	first_page = pfn_to_page(psection << PFN_SECTION_SHIFT);
> 
>  	/*
> @@ -217,18 +231,18 @@
>  			ret = online_pages(start_pfn, PAGES_PER_SECTION);
>  			break;
>  		case MEM_OFFLINE:
> -			mem->state = MEM_GOING_OFFLINE;
> +			mbs->state = MEM_GOING_OFFLINE;
>  			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
>  			ret = remove_memory(start_paddr,
>  					    PAGES_PER_SECTION << PAGE_SHIFT);
>  			if (ret) {
> -				mem->state = old_state;
> +				mbs->state = old_state;
>  				break;
>  			}
>  			break;
>  		default:
>  			WARN(1, KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
> -					__func__, mem, action, action);
> +					__func__, mbs, action, action);
>  			ret = -EINVAL;
>  	}
> 
> @@ -238,19 +252,34 @@
>  static int memory_block_change_state(struct memory_block *mem,
>  		unsigned long to_state, unsigned long from_state_req)
>  {
> +	struct memory_block_section *mbs;
>  	int ret = 0;
> +
>  	mutex_lock(&mem->state_mutex);
> 
> -	if (mem->state != from_state_req) {
> -		ret = -EINVAL;
> -		goto out;
> +	list_for_each_entry(mbs, &mem->sections, next) {
> +		if (mbs->state != from_state_req)
> +			continue;
> +
> +		ret = memory_block_action(mbs, to_state);
> +		if (ret)
> +			break;
> +	}
> +
> +	if (ret) {
> +		list_for_each_entry(mbs, &mem->sections, next) {
> +			if (mbs->state == from_state_req)
> +				continue;
> +
> +			if (memory_block_action(mbs, to_state))
> +				printk(KERN_ERR "Could not re-enable memory "
> +				       "section %lx\n", mbs->phys_index);
> +		}
>  	}

Please just use a goto here.  It's nicer looking, and much more in line
with what's there already.

...
> ===================================================================
> --- linux-2.6.orig/include/linux/memory.h	2010-07-15 08:48:41.000000000 -0500
> +++ linux-2.6/include/linux/memory.h	2010-07-15 09:54:06.000000000 -0500
> @@ -19,9 +19,15 @@
>  #include <linux/node.h>
>  #include <linux/compiler.h>
>  #include <linux/mutex.h>
> +#include <linux/list.h>
> 
> -struct memory_block {
> +struct memory_block_section {
> +	unsigned long state;
>  	unsigned long phys_index;
> +	struct list_head next;
> +};
> +
> +struct memory_block {
>  	unsigned long state;
>  	/*
>  	 * This serializes all state change requests.  It isn't
> @@ -34,6 +40,7 @@
>  	void *hw;			/* optional pointer to fw/hw data */
>  	int (*phys_callback)(struct memory_block *);
>  	struct sys_device sysdev;
> +	struct list_head sections;
>  };

It looks like we have state in both the memory_block and
memory_block_section.  That seems a bit confusing to me.  This also
looks like it would permit non-contiguous memory_block_sections in a
memory_block.  Is that what you intended?

If the memory_block's state was inferred to be the same as each
memory_block_section, couldn't we just keep a start and end phys_index
in the memory_block, and get away from having memory_block_sections at
all?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

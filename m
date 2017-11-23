Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81ED76B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 11:28:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 11so9738028wrb.18
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:28:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h90si3315149edd.454.2017.11.23.08.28.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 08:28:38 -0800 (PST)
Date: Thu, 23 Nov 2017 17:28:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] stackdepot: interface to check entries and size of
 stackdepot.
Message-ID: <20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
References: <CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcas5p1.samsung.com>
 <1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, jkosina@suse.cz, pombredanne@nexb.com, jpoimboe@redhat.com, akpm@linux-foundation.org, vbabka@suse.cz, guptap@codeaurora.org, vinmenon@codeaurora.org, a.sahrawat@samsung.com, pankaj.m@samsung.com, lalit.mohan@samsung.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vaneet Narang <v.narang@samsung.com>

On Wed 22-11-17 16:17:41, Maninder Singh wrote:
> This patch provides interface to check all the stack enteries
> saved in stackdepot so far as well as memory consumed by stackdepot.
> 
> 1) Take current depot_index and offset to calculate end address for one
> 	iteration of (/sys/kernel/debug/depot_stack/depot_entries).
> 
> 2) Fill end marker in every slab to point its end, and then use it while
> 	traversing all the slabs of stackdepot.
> 
> "debugfs code inspired from page_onwer's way of printing BT"
> 
> checked on ARM and x86_64.
> $cat /sys/kernel/debug/depot_stack/depot_size
> Memory consumed by Stackdepot:208 KB
> 
> $ cat /sys/kernel/debug/depot_stack/depot_entries
> stack count 1 backtrace
>  init_page_owner+0x1e/0x210
>  start_kernel+0x310/0x3cd
>  secondary_startup_64+0xa5/0xb0
>  0xffffffffffffffff

Why do we need this? Who is goging to use this information and what for?
I haven't looked at the code but just the diffstat looks like this
should better have a _very_ good justification to be considered for
merging. To be honest with you I have hard time imagine how this can be
useful other than debugging stack depot...

> Signed-off-by: Vaneet Narang <v.narang@samsung.com>
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> ---
>  include/linux/stackdepot.h |   13 +++
>  include/linux/stacktrace.h |    6 ++
>  lib/stackdepot.c           |  183 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_owner.c            |    6 --
>  4 files changed, 202 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/stackdepot.h b/include/linux/stackdepot.h
> index 7978b3e..dd95b11 100644
> --- a/include/linux/stackdepot.h
> +++ b/include/linux/stackdepot.h
> @@ -23,6 +23,19 @@
>  
>  typedef u32 depot_stack_handle_t;
>  
> +/*
> + * structure to store markers which
> + * will be used while printing entries
> + * stored in stackdepot.
> + */
> +struct depot_stack_data {
> +	int print_offset;
> +	int print_counter;
> +	int print_index;
> +	unsigned long end_marker;
> +	void *end_address;
> +};
> +
>  struct stack_trace;
>  
>  depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags);
> diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
> index ba29a06..1cfd27d 100644
> --- a/include/linux/stacktrace.h
> +++ b/include/linux/stacktrace.h
> @@ -4,6 +4,12 @@
>  
>  #include <linux/types.h>
>  
> +/*
> + * TODO: teach PAGE_OWNER_STACK_DEPTH (__dump_page_owner and save_stack)
> + * to use off stack temporal storage
> + */
> +#define PAGE_OWNER_STACK_DEPTH (16)
> +
>  struct task_struct;
>  struct pt_regs;
>  
> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> index f87d138..3067fcb 100644
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -39,6 +39,8 @@
>  #include <linux/stackdepot.h>
>  #include <linux/string.h>
>  #include <linux/types.h>
> +#include <linux/debugfs.h>
> +#include <linux/uaccess.h>
>  
>  #define DEPOT_STACK_BITS (sizeof(depot_stack_handle_t) * 8)
>  
> @@ -111,6 +113,7 @@ static bool init_stack_slab(void **prealloc)
>  	int required_size = offsetof(struct stack_record, entries) +
>  		sizeof(unsigned long) * size;
>  	struct stack_record *stack;
> +	void *address;
>  
>  	required_size = ALIGN(required_size, 1 << STACK_ALLOC_ALIGN);
>  
> @@ -119,6 +122,17 @@ static bool init_stack_slab(void **prealloc)
>  			WARN_ONCE(1, "Stack depot reached limit capacity");
>  			return NULL;
>  		}
> +
> +		/*
> +		 * write POSION_END if any space left in
> +		 * current slab to represent its end.
> +		 * later used while printing all the stacks.
> +		 */
> +		if (depot_offset < STACK_ALLOC_SIZE) {
> +			address = stack_slabs[depot_index] + depot_offset;
> +			memset(address, POISON_END, sizeof(unsigned long));
> +		}
> +
>  		depot_index++;
>  		depot_offset = 0;
>  		/*
> @@ -285,3 +299,172 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
>  	return retval;
>  }
>  EXPORT_SYMBOL_GPL(depot_save_stack);
> +
> +#define DEPOT_SIZE 64
> +
> +static ssize_t read_depot_stack_size(struct file *file, char __user *buf, size_t count, loff_t *ppos)
> +{
> +	char kbuf[DEPOT_SIZE];
> +	ssize_t ret = 0;
> +	unsigned long size = depot_index * (1 << STACK_ALLOC_ORDER) * PAGE_SIZE;
> +
> +	ret = snprintf(kbuf, count, "Memory consumed by Stackdepot:%lu KB\n", size >> 10);
> +	if (ret >= count)
> +		return -ENOMEM;
> +
> +	return simple_read_from_buffer(buf, count, ppos, kbuf, ret);
> +}
> +
> +static ssize_t print_depot_stack(char __user *buf, size_t count, struct stack_trace *trace, loff_t *ppos)
> +{
> +	char *kbuf;
> +	int ret = 0;
> +
> +	kbuf = kvmalloc(count, GFP_KERNEL);
> +	if (!kbuf)
> +		return -ENOMEM;
> +
> +	ret = snprintf(kbuf, count, "stack count %d backtrace\n", (int)*ppos);
> +	ret += snprint_stack_trace(kbuf + ret, count - ret, trace, 0);
> +	ret += snprintf(kbuf + ret, count - ret, "\n");
> +
> +	if (ret >= count) {
> +		ret = -ENOMEM;
> +		goto err;
> +	}
> +
> +	if (copy_to_user(buf, kbuf, ret))
> +		ret = -EFAULT;
> +
> +err:
> +	kvfree(kbuf);
> +	return ret;
> +}
> +
> +/*
> + * read_depot_stack()
> + *
> + * function to print all the entries present
> + * in depot_stack database currently in system.
> + */
> +static ssize_t read_depot_stack(struct file *file, char __user *buf, size_t count, loff_t *ppos)
> +{
> +	struct stack_record *stack;
> +	void *address;
> +	struct depot_stack_data *debugfs_data;
> +
> +	debugfs_data  = (struct depot_stack_data *)file->private_data;
> +
> +	if (!debugfs_data)
> +		return -EINVAL;
> +
> +	while (debugfs_data->print_counter <= debugfs_data->print_index) {
> +		unsigned long entries[PAGE_OWNER_STACK_DEPTH];
> +		struct stack_trace trace = {
> +			.nr_entries = 0,
> +			.entries = entries,
> +			.max_entries = PAGE_OWNER_STACK_DEPTH,
> +			.skip = 0
> +		};
> +
> +		address = stack_slabs[debugfs_data->print_counter] + debugfs_data->print_offset;
> +		if (address == debugfs_data->end_address)
> +			break;
> +
> +		if (*((unsigned long *)address) == debugfs_data->end_marker) {
> +			debugfs_data->print_counter++;
> +			debugfs_data->print_offset = 0;
> +			continue;
> +		}
> +
> +		stack = address;
> +		trace.nr_entries = trace.max_entries = stack->size;
> +		trace.entries = stack->entries;
> +
> +		debugfs_data->print_offset += offsetof(struct stack_record, entries) +
> +				(stack->size * sizeof(unsigned long));
> +		debugfs_data->print_offset = ALIGN(debugfs_data->print_offset, 1 << STACK_ALLOC_ALIGN);
> +		if (debugfs_data->print_offset >= STACK_ALLOC_SIZE) {
> +			debugfs_data->print_counter++;
> +			debugfs_data->print_offset = 0;
> +		}
> +
> +		*ppos = *ppos + 1; /* one stack found, print it */
> +		return print_depot_stack(buf, count, &trace, ppos);
> +	}
> +
> +	return 0;
> +}
> +
> +int read_depot_open(struct inode *inode, struct file *file)
> +{
> +	struct depot_stack_data *debugfs_data;
> +	unsigned long flags;
> +
> +	debugfs_data  = kzalloc(sizeof(struct depot_stack_data), GFP_KERNEL);
> +	if (!debugfs_data)
> +		return -ENOMEM;
> +	/*
> +	 * First time depot_stack/depot_entries is called.
> +	 * (/sys/kernel/debug/depot_stack/depot_entries)
> +	 * initialise print depot_index and stopping address.
> +	 */
> +	memset(&(debugfs_data->end_marker), POISON_END, sizeof(unsigned long));
> +
> +	spin_lock_irqsave(&depot_lock, flags);
> +	debugfs_data->print_index = depot_index;
> +	debugfs_data->end_address = stack_slabs[depot_index] + depot_offset;
> +	spin_unlock_irqrestore(&depot_lock, flags);
> +
> +	file->private_data = debugfs_data;
> +	return 0;
> +}
> +
> +int read_depot_release(struct inode *inode, struct file *file)
> +{
> +	void *debugfs_data = file->private_data;
> +
> +	kfree(debugfs_data);
> +	return 0;
> +}
> +
> +static const struct file_operations proc_depot_stack_operations = {
> +	.open       = read_depot_open,
> +	.read		= read_depot_stack,
> +	.release    = read_depot_release,
> +};
> +
> +static const struct file_operations proc_depot_stack_size_operations = {
> +	.read		= read_depot_stack_size,
> +};
> +
> +static int __init depot_stack_init(void)
> +{
> +	struct dentry *dentry, *dentry_root;
> +
> +	dentry_root = debugfs_create_dir("depot_stack", NULL);
> +
> +	if (!dentry_root) {
> +		pr_warn("debugfs 'depot_stack' dir creation failed\n");
> +		return -ENOMEM;
> +	}
> +
> +	dentry = debugfs_create_file("depot_entries", 0400, dentry_root,
> +			NULL, &proc_depot_stack_operations);
> +
> +	if (IS_ERR(dentry))
> +		goto err;
> +
> +	dentry = debugfs_create_file("depot_size", 0400, dentry_root,
> +			NULL, &proc_depot_stack_size_operations);
> +
> +	if (IS_ERR(dentry))
> +		goto err;
> +
> +	return 0;
> +
> +err:
> +	debugfs_remove_recursive(dentry_root);
> +	return PTR_ERR(dentry);
> +}
> +late_initcall(depot_stack_init)
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 4f44b95..341b326 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -13,12 +13,6 @@
>  
>  #include "internal.h"
>  
> -/*
> - * TODO: teach PAGE_OWNER_STACK_DEPTH (__dump_page_owner and save_stack)
> - * to use off stack temporal storage
> - */
> -#define PAGE_OWNER_STACK_DEPTH (16)
> -
>  struct page_owner {
>  	unsigned int order;
>  	gfp_t gfp_mask;
> -- 
> 1.7.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

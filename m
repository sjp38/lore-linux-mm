Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp06.au.ibm.com (8.13.8/8.13.6) with ESMTP id kAALUJ4Y6983830
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:30:21 -0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAA9WkcW239294
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:32:51 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAA9TJ0Q022075
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:29:19 +1100
Message-ID: <45544665.3020105@in.ibm.com>
Date: Fri, 10 Nov 2006 14:59:09 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/8] RSS controller accounting
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com> <20061109193600.21437.74220.sendpatchset@balbir.in.ibm.com> <4554412C.3070904@openvz.org>
In-Reply-To: <4554412C.3070904@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@openvz.org>
Cc: Linux MM <linux-mm@kvack.org>, dev@openvz.org, ckrm-tech@lists.sourceforge.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Pavel Emelianov wrote:
> Balbir Singh wrote:
>> Account RSS usage of a task and the associated container. The definition
>> of RSS was debated and discussed in the following thread
>>
>> 	http://lkml.org/lkml/2006/10/10/130
>>
>>
>> The code tracks all resident pages (including shared pages) as RSS. This patch
>> can easily adapt to the definition of RSS that will be agreed upon. This
>> implementation provides a proof of concept RSS controller.
>>
>> The accounting is inspired from Rohit Seth's container patches.
>>
>> TODO's
>>
>> 1. Merge file_rss and anon_rss tracking with the current rss tracking to
>>    maximize code reuse
>> 2. Add/remove RSS tracking as the definition of RSS evolves
>>
>>
>> Signed-off-by: Balbir Singh <balbir@in.ibm.com>
>> ---
>>
> 
> [snip]
> 
>> --- linux-2.6.19-rc2/kernel/res_group/memctlr.c~container-memctlr-acct	2006-11-09 21:46:22.000000000 +0530
>> +++ linux-2.6.19-rc2-balbir/kernel/res_group/memctlr.c	2006-11-09 21:47:06.000000000 +0530
>> @@ -37,6 +37,8 @@ static struct resource_group *root_rgrou
>>  static const char version[] = "0.01";
>>  static struct memctlr *memctlr_root;
>>  
>> +#define MEMCTLR_MAGIC	0xdededede
>> +
>>  struct mem_counter {
>>  	atomic_long_t	rss;
>>  };
>> @@ -49,6 +51,7 @@ struct memctlr {
>>  	/* Statistics */
>>  	int successes;
>>  	int failures;
>> +	int magic;
> 
> What is this magic for? Is it just for debugging?
> 

Yes

> [snip]
> 
>> +static inline struct memctlr *get_memctlr_from_page(struct page *page)
>> +{
>> +	struct resource_group *rgroup;
>> +	struct memctlr *res;
>> +
>> +	/*
>> +	 * Is the resource groups infrastructure initialized?
>> +	 */
>> +	if (!memctlr_root)
>> +		return NULL;
>> +
>> +	rcu_read_lock();
>> +	rgroup = (struct resource_group *)rcu_dereference(current->container);
>> +	rcu_read_unlock();
>> +
>> +	res = get_memctlr(rgroup);
>> +	if (!res)
>> +		return NULL;
>> +
>> +	BUG_ON(res->magic != MEMCTLR_MAGIC);
>> +	return res;
>> +}
> 
> I don't see how page passed to this function is involved into
> 'struct memctlr *res' determining. Could you comment this?
> 

Yeah, from page is a misnomer. We just use the current task task.
I'll fix the naming convention


> [snip]
> 
>> --- linux-2.6.19-rc2/mm/rmap.c~container-memctlr-acct	2006-11-09 21:46:22.000000000 +0530
>> +++ linux-2.6.19-rc2-balbir/mm/rmap.c	2006-11-09 21:46:22.000000000 +0530
>> @@ -537,6 +537,7 @@ void page_add_anon_rmap(struct page *pag
>>  	if (atomic_inc_and_test(&page->_mapcount))
>>  		__page_set_anon_rmap(page, vma, address);
>>  	/* else checking page index and mapping is racy */
>> +	memctlr_inc_rss(page);
>>  }
>>  
>>  /*
>> @@ -553,6 +554,7 @@ void page_add_new_anon_rmap(struct page 
>>  {
>>  	atomic_set(&page->_mapcount, 0); /* elevate count by 1 (starts at -1) */
>>  	__page_set_anon_rmap(page, vma, address);
>> +	memctlr_inc_rss(page);
>>  }
>>  
>>  /**
>> @@ -565,6 +567,7 @@ void page_add_file_rmap(struct page *pag
>>  {
>>  	if (atomic_inc_and_test(&page->_mapcount))
>>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
>> +	memctlr_inc_rss(page);
> 
> Consider a task maps one file page 100 times in different places
> and touches 'all of them'. In this case I see that you'll get
> 100 in rss counter while real rss will be just 1.
> 

Hmmm... something for me to think about. Depending on how we define
RSS, the code for accounting should be easy to add & modify depending
on how we define RSS. But you bring up a very good point.

>>  }
>>  
>>  /**
>> @@ -596,8 +599,9 @@ void page_remove_rmap(struct page *page)
>>  		if (page_test_and_clear_dirty(page))
>>  			set_page_dirty(page);
>>  		__dec_zone_page_state(page,
>> -				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
>> +				PageAnon(page) ?  NR_ANON_PAGES : NR_FILE_MAPPED);
> 
> What is this extra space after a question-mark for?

This is again something I changed and looks my undo was not very good.
Please ignore it, I'll remove it from the diff.

> 
>>  	}
>> +	memctlr_dec_rss(page, mm);
>>  }
>>  
>>  /*
>> diff -puN include/linux/rmap.h~container-memctlr-acct include/linux/rmap.h
>> --- linux-2.6.19-rc2/include/linux/rmap.h~container-memctlr-acct	2006-11-09 21:46:22.000000000 +0530
>> +++ linux-2.6.19-rc2-balbir/include/linux/rmap.h	2006-11-09 21:46:22.000000000 +0530
>> @@ -8,6 +8,7 @@
>>  #include <linux/slab.h>
>>  #include <linux/mm.h>
>>  #include <linux/spinlock.h>
>> +#include <linux/memctlr.h>
>>  
>>  /*
>>   * The anon_vma heads a list of private "related" vmas, to scan if
>> @@ -84,6 +85,7 @@ void page_remove_rmap(struct page *);
>>  static inline void page_dup_rmap(struct page *page)
>>  {
>>  	atomic_inc(&page->_mapcount);
>> +	memctlr_inc_rss(page);
>>  }
> 
> I'm not sure this is correct. page_dup_rmap() happens in the context
> of forking process and thus you'll increment rss counter on current.
> But this must be incremented at new task's counter, mustn't it?

This is fixed in the next patch container-memctlr-task-migration.
Thanks for spotting it.

-- 
	Thanks,
	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

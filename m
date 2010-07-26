Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E26C600044
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 15:10:46 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6QIqPJc021386
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 14:52:25 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6QJAXMF313618
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 15:10:33 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6QJAX64001455
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 16:10:33 -0300
Message-ID: <4C4DDDA7.2000302@austin.ibm.com>
Date: Mon, 26 Jul 2010 14:10:31 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] v3 Allow memory_block to span multiple memory sections
References: <4C451BF5.50304@austin.ibm.com>	 <4C451E1C.8070907@austin.ibm.com> <1279653481.9785.4.camel@nimitz>
In-Reply-To: <1279653481.9785.4.camel@nimitz>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On 07/20/2010 02:18 PM, Dave Hansen wrote:
> On Mon, 2010-07-19 at 22:55 -0500, Nathan Fontenot wrote:
>> +static int add_memory_section(int nid, struct mem_section *section,
>> +                       unsigned long state, enum mem_add_context context)
>> +{
>> +       struct memory_block *mem;
>> +       int ret = 0;
>> +
>> +       mem = find_memory_block(section);
>> +       if (mem) {
>> +               atomic_inc(&mem->section_count);
>> +               kobject_put(&mem->sysdev.kobj);
>> +       } else
>> +               ret = init_memory_block(&mem, section, state);
>> +
>>         if (!ret) {
>> -               if (context == HOTPLUG)
>> +               if (context == HOTPLUG &&
>> +                   atomic_read(&mem->section_count) == sections_per_block)
>>                         ret = register_mem_sect_under_node(mem, nid);
>>         } 
> 
> I think the atomic_inc() can race with the atomic_dec_and_test() in
> remove_memory_block().
> 
> Thread 1 does:
> 
> 	mem = find_memory_block(section);
> 
> Thread 2 does 
> 
> 	atomic_dec_and_test(&mem->section_count);
> 
> and destroys the memory block,  Thread 1 runs again:
> 	
>        if (mem) {
>                atomic_inc(&mem->section_count);
>                kobject_put(&mem->sysdev.kobj);
>        } else
> 
> but now mem got destroyed by Thread 2.  You probably need to change
> find_memory_block() to itself take a reference, and to use
> atomic_inc_unless().
> 

I'm not sure I like that for a couple of reasons.  I think there may still be a
path through the find_memory_block() code that this race condition can occur.
We could take a time sslice after the kobject_get and before getting the
memory_block pointer.

The second reason is that the node sysfs code calls find_memory_block() and it
may be a bit kludgy to have callers of find_memory_block have to reduce the
section_count after using it.

With the way the memory_block structs are kept, retrieved via a kobject_get()
call instead maintained on a local list, there may not be a solution that is
foolproof without changing this.

-Nathan 
> -- Dave
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

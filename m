Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 347C76B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 23:10:02 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6O30KS0020359
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 21:00:20 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6O39xbv078186
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 21:09:59 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6O39x8b015102
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 21:09:59 -0600
Message-ID: <4C4A5985.6000206@austin.ibm.com>
Date: Fri, 23 Jul 2010 22:09:57 -0500
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

You're right but I think the fix you suggested will narrow the window for the
race condition, not eliminate it.  We could still take a time splice in
find_memory_block prior to the container_of() calls to get the memory
block pointer and end up de-referencing a invalid kobject o sysdev pointer.

I think if we want to eliminate this we may need to have lock that protects
access to any of the memory_block structures.  This would need to be taken
any time find_memory_block is called and released when use of the memory_block
returned is finished.  If we're going to fix this we should eliminate the
window completely instead of just closing it further.

If we add a lock should I submit it as part of this patchset? or submit it
as a follow-on?

-Nathan 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

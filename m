Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDCF6B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:06:33 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8SHpQ48030561
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 13:51:26 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8SI6UcG377132
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:06:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8SI6TVv023169
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:06:30 -0400
Message-ID: <4CA22EA2.8060307@austin.ibm.com>
Date: Tue, 28 Sep 2010 13:06:26 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] v2 Allow memory block to span multiple memory sections
References: <4CA0EBEB.1030204@austin.ibm.com>	 <4CA0EFAA.8050000@austin.ibm.com> <1285631707.19976.3385.camel@nimitz>
In-Reply-To: <1285631707.19976.3385.camel@nimitz>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 09/27/2010 06:55 PM, Dave Hansen wrote:
> On Mon, 2010-09-27 at 14:25 -0500, Nathan Fontenot wrote:
>> +static inline int base_memory_block_id(int section_nr)
>> +{
>> +       return section_nr / sections_per_block;
>> +}
> ...
>> -       mutex_lock(&mem_sysfs_mutex);
>> -
>> -       mem->phys_index = __section_nr(section);
>> +       scn_nr = __section_nr(section);
>> +       mem->phys_index = base_memory_block_id(scn_nr) * sections_per_block; 
> 
> I'm really regretting giving this variable such a horrid name.  I suck.
> 
> I think this is correct now:
> 
> 	mem->phys_index = base_memory_block_id(scn_nr) * sections_per_block;
> 	mem->phys_index = section_nr / sections_per_block * sections_per_block;
> 	mem->phys_index = section_nr
> 
> Since it gets exported to userspace this way:
> 
>> +static ssize_t show_mem_start_phys_index(struct sys_device *dev,
>>                         struct sysdev_attribute *attr, char *buf)
>>  {
>>         struct memory_block *mem =
>>                 container_of(dev, struct memory_block, sysdev);
>> -       return sprintf(buf, "%08lx\n", mem->phys_index / sections_per_block);
>> +       unsigned long phys_index;
>> +
>> +       phys_index = mem->start_phys_index / sections_per_block;
>> +       return sprintf(buf, "%08lx\n", phys_index);
>> +}
> 
> The only other thing I'd say is that we need to put phys_index out of
> its misery and call it what it is now: a section number.  I think it's
> OK to call them "start/end_section_nr", at least inside the kernel.  I
> intentionally used "phys_index" terminology in sysfs so that we _could_
> eventually do this stuff and break the relationship between sections and
> the sysfs dirs, but I think keeping the terminology around inside the
> kernel is confusing now.

Yes, it took me a couple o looks to get the phys_index <-> section number
correlation.  I think changing the kernel names to start/end_section_number
is a good idea.

-Nathan

> 
> -- Dave
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

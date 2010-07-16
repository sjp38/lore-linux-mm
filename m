Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DF4466B02A6
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:40:19 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GFRicx014874
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:27:44 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GFeGtf1499180
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:40:16 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GFeFZI006915
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 12:40:15 -0300
Message-ID: <4C407D5E.7060702@austin.ibm.com>
Date: Fri, 16 Jul 2010 10:40:14 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] v2 Update sysfs node routines for new sysfs memory
 directories
References: <4C3F53D1.3090001@austin.ibm.com>	<4C3F5628.6030809@austin.ibm.com> <20100716091239.69f40e47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100716091239.69f40e47.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On 07/15/2010 07:12 PM, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Jul 2010 13:40:40 -0500
> Nathan Fontenot <nfont@austin.ibm.com> wrote:
> 
>> Update the node sysfs directory routines that create
>> links to the memory sysfs directories under each node.
>> This update makes the node code aware that a memory sysfs
>> directory can cover multiple memory sections.
>>
>> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 
> Shouldn't "static int link_mem_sections(int nid)" be update ?
> It does
>  for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>         register..
> 

No, although the name 'link_mem_sections' does imply that it should.  The
range of start_pfn..end_pfn examined in this routine is the range of pfn's
covered by the entire node, not a memory_block.

-Nathan

> Thanks,
> -Kame
> 
> 
>> ---
>>  drivers/base/node.c |   12 ++++++++----
>>  1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> Index: linux-2.6/drivers/base/node.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/base/node.c	2010-07-15 09:54:06.000000000 -0500
>> +++ linux-2.6/drivers/base/node.c	2010-07-15 09:56:16.000000000 -0500
>> @@ -346,8 +346,10 @@
>>  		return -EFAULT;
>>  	if (!node_online(nid))
>>  		return 0;
>> -	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
>> -	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>> +
>> +	sect_start_pfn = section_nr_to_pfn(mem_blk->start_phys_index);
>> +	sect_end_pfn = section_nr_to_pfn(mem_blk->end_phys_index);
>> +	sect_end_pfn += PAGES_PER_SECTION - 1;
>>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>>  		int page_nid;
>>  
>> @@ -383,8 +385,10 @@
>>  	if (!unlinked_nodes)
>>  		return -ENOMEM;
>>  	nodes_clear(*unlinked_nodes);
>> -	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
>> -	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>> +
>> +	sect_start_pfn = section_nr_to_pfn(mem_blk->start_phys_index);
>> +	sect_end_pfn = section_nr_to_pfn(mem_blk->end_phys_index);
>> +	sect_end_pfn += PAGES_PER_SECTION - 1;
>>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>>  		int nid;
>>  
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

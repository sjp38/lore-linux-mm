Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BBCCC6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:00:26 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 9 Jul 2012 08:00:25 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 15B5F38C805A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 07:59:44 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q69BxhHU428076
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 07:59:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q69Bxerm010571
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 08:59:40 -0300
Date: Mon, 9 Jul 2012 19:59:35 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] mm/sparse: remove index_init_lock
Message-ID: <20120709115935.GA19355@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341544178-7245-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341544178-7245-3-git-send-email-shangw@linux.vnet.ibm.com>
 <20120709111304.GA4627@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120709111304.GA4627@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, akpm@linux-foundation.org

On Mon, Jul 09, 2012 at 01:13:04PM +0200, Michal Hocko wrote:
>On Fri 06-07-12 11:09:38, Gavin Shan wrote:
>> Apart from call to sparse_index_init() during boot stage, the function
>> is mainly used for hotplug case as follows and protected by hotplug
>
>mainly? Who are the others?
>

The function can possibilly be called during hotplug as well as boot stage
as follows. The others means "boot stage" here :-)

sparse_index_init
memory_present
sparse_memory_present_with_active_regions


>> mutex "mem_hotplug_mutex". So we needn't the spinlock in sparse_index_init().
>
>I think you are right but the changelog should be more convincing. It
>would be also good to mention the origin motivation for the lock (I
>couldn't find it in the history - Dave?).
>

Copy Dave's changelog for the original patch again.

---
sparse_index_init() is designed to be safe if two copies of it race.  It
uses "index_init_lock" to ensure that, even in the case of a race, only
one CPU will manage to do:

mem_section[root] = section;

However, in the case where two copies of sparse_index_init() _do_ race,
which is probablly caused by making online for multiple memory sections
that depend on same entry of array mem_section[] simultaneously from
different CPUs. 
---

Michal, How about the following changelog?

---

sparse_index_init() is designed to be safe if two copies of it race.  It
uses "index_init_lock" to ensure that, even in the case of a race, only
one CPU will manage to do:

mem_section[root] = section;

On the other hand, sparse_index_init() is possiblly called during system
boot stage and hotplug path as follows. We need't lock during system boot
stage to protect "mem_section[root]" and the function has been protected by
hotplug mutex "mem_hotplug_mutex" as well in hotplug case. So we needn't the
spinklock in the function.

---


Thanks,
Gavin

>> 
>> 	sparse_index_init
>> 	sparse_add_one_section
>> 	__add_section
>> 	__add_pages
>> 	arch_add_memory
>> 	add_memory
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> ---
>>  mm/sparse.c |   14 +-------------
>>  1 file changed, 1 insertion(+), 13 deletions(-)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 8b8edfb..4437c6c 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -77,7 +77,6 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>>  
>>  static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  {
>> -	static DEFINE_SPINLOCK(index_init_lock);
>>  	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
>>  	struct mem_section *section;
>>  	int ret = 0;
>> @@ -88,20 +87,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  	section = sparse_index_alloc(nid);
>>  	if (!section)
>>  		return -ENOMEM;
>> -	/*
>> -	 * This lock keeps two different sections from
>> -	 * reallocating for the same index
>> -	 */
>> -	spin_lock(&index_init_lock);
>> -
>> -	if (mem_section[root]) {
>> -		ret = -EEXIST;
>> -		goto out;
>> -	}
>>  
>>  	mem_section[root] = section;
>> -out:
>> -	spin_unlock(&index_init_lock);
>> +
>>  	return ret;
>>  }
>>  #else /* !SPARSEMEM_EXTREME */
>> -- 
>> 1.7.9.5
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>-- 
>Michal Hocko
>SUSE Labs
>SUSE LINUX s.r.o.
>Lihovarska 1060/12
>190 00 Praha 9    
>Czech Republic
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

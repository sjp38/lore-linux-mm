Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC25F6B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:56:50 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id c18so2926048itd.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:56:50 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g126si10000096ioa.124.2017.12.19.11.56.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 11:56:47 -0800 (PST)
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface for
 freeing rcu structures
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219193039.GB6515@bombadil.infradead.org>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <24c9f1c0-58d4-5d27-8795-d211693455dd@oracle.com>
Date: Tue, 19 Dec 2017 11:56:30 -0800
MIME-Version: 1.0
In-Reply-To: <20171219193039.GB6515@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org



On 12/19/2017 11:30 AM, Matthew Wilcox wrote:
> On Tue, Dec 19, 2017 at 09:52:27AM -0800, rao.shoaib@oracle.com wrote:
>> @@ -129,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
>>   
>>   	for (i = 0; i < nr; i++) {
>>   		void *x = p[i] = kmem_cache_alloc(s, flags);
>> +
>>   		if (!x) {
>>   			__kmem_cache_free_bulk(s, i, p);
>>   			return 0;
> Don't mix whitespace changes with significant patches.
OK.
>
>> +/* Main RCU function that is called to free RCU structures */
>> +static void
>> +__rcu_bulk_free(struct rcu_head *head, rcu_callback_t func, int cpu, bool lazy)
>> +{
>> +	unsigned long offset;
>> +	void *ptr;
>> +	struct rcu_bulk_free *rbf;
>> +	struct rcu_bulk_free_container *rbfc = NULL;
>> +
>> +	rbf = this_cpu_ptr(&cpu_rbf);
>> +
>> +	if (unlikely(!rbf->rbf_init)) {
>> +		spin_lock_init(&rbf->rbf_lock);
>> +		rbf->rbf_cpu = smp_processor_id();
>> +		rbf->rbf_init = true;
>> +	}
>> +
>> +	/* hold lock to protect against other cpu's */
>> +	spin_lock_bh(&rbf->rbf_lock);
> Are you sure we can't call kfree_rcu() from interrupt context?
I thought about it, but the interrupts are off due to acquiring the 
lock. No ?
>
>> +		rbfc = rbf->rbf_container;
>> +		rbfc->rbfc_entries = 0;
>> +
>> +		if (rbf->rbf_list_head != NULL)
>> +			__rcu_bulk_schedule_list(rbf);
> You've broken RCU.  Consider this scenario:
>
> Thread 1	Thread 2		Thread 3
> kfree_rcu(a)	
> 		schedule()
> schedule()	
> 		gets pointer to b
> kfree_rcu(b)	
> 					processes rcu callbacks
> 		uses b
>
> Thread 3 will free a and also free b, so thread 2 is going to use freed
> memory and go splat.  You can't batch up memory to be freed without
> taking into account the grace periods.
The code does not change the grace period at all. In fact it adds to the 
grace period.
The free's are accumulated in an array, when a certain limit/time is 
reached the frees are submitted
to RCU for freeing. So the grace period is maintained starting from the 
time of the last free.

In case the memory allocation fails the code uses a list that is also 
submitted to RCU for freeing.
>
> It might make sense for RCU to batch up all the memory it's going to free
> in a single grace period, and hand it all off to slub at once, but that's
> not what you've done here.
I am kind of doing that but not on a per grace period but on a per cpu 
basis.
>
>
> I've been doing a lot of thinking about this because I really want a
> way to kfree_rcu() an object without embedding a struct rcu_head in it.
> But I see no way to do that today; even if we have an external memory
> allocation to point to the object to be freed, we have to keep track of
> the grace periods.
I am not sure I understand. If you had external memory you can easily do 
that.
I am exactly doing that, the only reason the RCU structure is needed is 
to get the pointer to the object being freed.

Shoaib


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

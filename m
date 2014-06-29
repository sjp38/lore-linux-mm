Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id ED0386B0036
	for <linux-mm@kvack.org>; Sun, 29 Jun 2014 15:38:12 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so7022621pdj.14
        for <linux-mm@kvack.org>; Sun, 29 Jun 2014 12:38:12 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ka6si20654068pbc.153.2014.06.29.12.38.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jun 2014 12:38:12 -0700 (PDT)
Message-ID: <53B06B22.9090203@codeaurora.org>
Date: Sun, 29 Jun 2014 12:38:10 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv3 2/5] lib/genalloc.c: Add genpool range check function
References: <1402969165-7526-1-git-send-email-lauraa@codeaurora.org> <1402969165-7526-3-git-send-email-lauraa@codeaurora.org> <20140620093856.GM25104@arm.com>
In-Reply-To: <20140620093856.GM25104@arm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: David Riley <davidriley@chromium.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 6/20/2014 2:38 AM, Will Deacon wrote:
> On Tue, Jun 17, 2014 at 02:39:22AM +0100, Laura Abbott wrote:
>> After allocating an address from a particular genpool,
>> there is no good way to verify if that address actually
>> belongs to a genpool. Introduce addr_in_gen_pool which
>> will return if an address plus size falls completely
>> within the genpool range.
>>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>> ---
>>  include/linux/genalloc.h |  3 +++
>>  lib/genalloc.c           | 29 +++++++++++++++++++++++++++++
>>  2 files changed, 32 insertions(+)
>>
>> diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
>> index 3cd0934..1ccaab4 100644
>> --- a/include/linux/genalloc.h
>> +++ b/include/linux/genalloc.h
>> @@ -121,6 +121,9 @@ extern struct gen_pool *devm_gen_pool_create(struct device *dev,
>>  		int min_alloc_order, int nid);
>>  extern struct gen_pool *dev_get_gen_pool(struct device *dev);
>>  
>> +bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
>> +			size_t size);
>> +
>>  #ifdef CONFIG_OF
>>  extern struct gen_pool *of_get_named_gen_pool(struct device_node *np,
>>  	const char *propname, int index);
>> diff --git a/lib/genalloc.c b/lib/genalloc.c
>> index 9758529..66edf93 100644
>> --- a/lib/genalloc.c
>> +++ b/lib/genalloc.c
>> @@ -403,6 +403,35 @@ void gen_pool_for_each_chunk(struct gen_pool *pool,
>>  EXPORT_SYMBOL(gen_pool_for_each_chunk);
>>  
>>  /**
>> + * addr_in_gen_pool - checks if an address falls within the range of a pool
>> + * @pool:	the generic memory pool
>> + * @start:	start address
>> + * @size:	size of the region
>> + *
>> + * Check if the range of addresses falls within the specified pool. Takes
>> + * the rcu_read_lock for the duration of the check.
>> + */
>> +bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
>> +			size_t size)
>> +{
>> +	bool found = false;
>> +	unsigned long end = start + size;
>> +	struct gen_pool_chunk *chunk;
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(chunk, &(pool)->chunks, next_chunk) {
>> +		if (start >= chunk->start_addr && start <= chunk->end_addr) {
> 
> Why do you need to check start against the end of the chunk? Is that in case
> of overflow?
> 

Yes, this provides an extra check for overflow and also matches similar logic for
gen_pool_virt_to_phys.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

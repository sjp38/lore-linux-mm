Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 97A7F6B0038
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 05:27:43 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id va2so23296573obc.6
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 02:27:43 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id je9si1574248oeb.10.2015.02.20.02.27.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 02:27:42 -0800 (PST)
Message-ID: <54E70C10.5050102@oracle.com>
Date: Fri, 20 Feb 2015 05:27:28 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/3] mm: cma: allocation trigger
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com> <1423780008-16727-3-git-send-email-sasha.levin@oracle.com> <54E61F91.9080506@partner.samsung.com>
In-Reply-To: <54E61F91.9080506@partner.samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, m.szyprowski@samsung.com, lauraa@codeaurora.org

Stefan, Andrew,

I ended up cherry-picking and older patch here by mistake. Joonsoo pointed
it out but I didn't have time to address it yet since I'm travelling and
they got pulled in to mmotm in the meanwhile.

I'll send out patches to add documentation and fix the issues raised here
early next week. Sorry for the delay and the noise.


Thanks,
Sasha

On 02/19/2015 12:38 PM, Stefan Strogin wrote:
> Hi,
> 
> On 13/02/15 01:26, Sasha Levin wrote:
>> Provides a userspace interface to trigger a CMA allocation.
>>
>> Usage:
>>
>> 	echo [pages] > alloc
>>
>> This would provide testing/fuzzing access to the CMA allocation paths.
>>
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> ---
>>  mm/cma.c       |    6 ++++++
>>  mm/cma.h       |    4 ++++
>>  mm/cma_debug.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>>  3 files changed, 64 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
>> index 3a25413..5bd6863 100644
>> --- a/mm/cma_debug.c
>> +++ b/mm/cma_debug.c
>> @@ -23,8 +32,48 @@ static int cma_debugfs_get(void *data, u64 *val)
>>  
>>  DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
>>  
>> -static void cma_debugfs_add_one(struct cma *cma, int idx)
>> +static void cma_add_to_cma_mem_list(struct cma *cma, struct cma_mem *mem)
>> +{
>> +	spin_lock(&cma->mem_head_lock);
>> +	hlist_add_head(&mem->node, &cma->mem_head);
>> +	spin_unlock(&cma->mem_head_lock);
>> +}
>> +
>> +static int cma_alloc_mem(struct cma *cma, int count)
>> +{
>> +	struct cma_mem *mem;
>> +	struct page *p;
>> +
>> +	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>> +	if (!mem) 
>> +		return -ENOMEM;
>> +
>> +	p = cma_alloc(cma, count, CONFIG_CMA_ALIGNMENT);
> 
> If CONFIG_DMA_CMA (and therefore CONFIG_CMA_ALIGNMENT) isn't configured
> then building fails.
>> mm/cma_debug.c: In function a??cma_alloc_mema??:
>> mm/cma_debug.c:223:28: error: a??CONFIG_CMA_ALIGNMENTa?? undeclared (first use in this function)
>>   p = cma_alloc(cma, count, CONFIG_CMA_ALIGNMENT);
>>                             ^
> 
> Also, could you please fix the whitespace errors in your patches?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

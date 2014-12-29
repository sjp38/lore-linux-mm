Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 900CC6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:09:54 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so22197590wid.0
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:09:54 -0800 (PST)
Received: from mail-wg0-x243.google.com (mail-wg0-x243.google.com. [2a00:1450:400c:c00::243])
        by mx.google.com with ESMTPS id y6si59212628wiv.12.2014.12.29.06.09.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 06:09:53 -0800 (PST)
Received: by mail-wg0-f67.google.com with SMTP id k14so418882wgh.10
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:09:53 -0800 (PST)
Message-ID: <54A160B6.5030605@gmail.com>
Date: Mon, 29 Dec 2014 15:09:58 +0100
From: Stefan Strogin <stefan.strogin@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com> <xa1tzjaaz9f9.fsf@mina86.com>
In-Reply-To: <xa1tzjaaz9f9.fsf@mina86.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Stefan Strogin <stefan.strogin@gmail.com>

Thanks for review MichaA?,

On 12/26/2014 07:02 PM, Michal Nazarewicz wrote:
> On Fri, Dec 26 2014, "Stefan I. Strogin" <s.strogin@partner.samsung.com> wrote:
>> /proc/cmainfo contains a list of currently allocated CMA buffers for every
>> CMA area when CONFIG_CMA_DEBUG is enabled.
>>
>> Format is:
>>
>> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID>\
>> 		(<command name>), latency <allocation latency> us
>>   <stack backtrace when the buffer had been allocated>
>>
>> Signed-off-by: Stefan I. Strogin <s.strogin@partner.samsung.com>
>> ---
>>   mm/cma.c | 202 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 202 insertions(+)
>>
>> diff --git a/mm/cma.c b/mm/cma.c
>> index a85ae28..ffaea26 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -347,6 +372,86 @@ err:
>>   	return ret;
>>   }
>>
>> +#ifdef CONFIG_CMA_DEBUG
>> +/**
>> + * cma_buffer_list_add() - add a new entry to a list of allocated buffers
>> + * @cma:     Contiguous memory region for which the allocation is performed.
>> + * @pfn:     Base PFN of the allocated buffer.
>> + * @count:   Number of allocated pages.
>> + * @latency: Nanoseconds spent to allocate the buffer.
>> + *
>> + * This function adds a new entry to the list of allocated contiguous memory
>> + * buffers in a CMA area. It uses the CMA area specificated by the device
>> + * if available or the default global one otherwise.
>> + */
>> +static int cma_buffer_list_add(struct cma *cma, unsigned long pfn,
>> +			       int count, s64 latency)
>> +{
>> +	struct cma_buffer *cmabuf;
>> +	struct stack_trace trace;
>> +
>> +	cmabuf = kmalloc(sizeof(struct cma_buffer), GFP_KERNEL);
>
> 	cmabuf = kmalloc(sizeof *cmabuf, GFP_KERNEL);

	cmabuf = kmalloc(sizeof(*cmabuf), GFP_KERNEL);

>
>> +	if (!cmabuf)
>> +		return -ENOMEM;
>> +
>> +	trace.nr_entries = 0;
>> +	trace.max_entries = ARRAY_SIZE(cmabuf->trace_entries);
>> +	trace.entries = &cmabuf->trace_entries[0];
>> +	trace.skip = 2;
>> +	save_stack_trace(&trace);
>> +
>> +	cmabuf->pfn = pfn;
>> +	cmabuf->count = count;
>> +	cmabuf->pid = task_pid_nr(current);
>> +	cmabuf->nr_entries = trace.nr_entries;
>> +	get_task_comm(cmabuf->comm, current);
>> +	cmabuf->latency = (unsigned int) div_s64(latency, NSEC_PER_USEC);
>> +
>> +	mutex_lock(&cma->list_lock);
>> +	list_add_tail(&cmabuf->list, &cma->buffers_list);
>> +	mutex_unlock(&cma->list_lock);
>> +
>> +	return 0;
>> +}
>> +
>> +/**
>> + * cma_buffer_list_del() - delete an entry from a list of allocated buffers
>> + * @cma:   Contiguous memory region for which the allocation was performed.
>> + * @pfn:   Base PFN of the released buffer.
>> + *
>> + * This function deletes a list entry added by cma_buffer_list_add().
>> + */
>> +static void cma_buffer_list_del(struct cma *cma, unsigned long pfn)
>> +{
>> +	struct cma_buffer *cmabuf;
>> +
>> +	mutex_lock(&cma->list_lock);
>> +
>> +	list_for_each_entry(cmabuf, &cma->buffers_list, list)
>> +		if (cmabuf->pfn == pfn) {
>> +			list_del(&cmabuf->list);
>> +			kfree(cmabuf);
>> +			goto out;
>> +		}
>
> You do not have guarantee that CMA deallocations will match allocations
> exactly.  User may allocate CMA region and then free it chunks.  I'm not
> saying that the debug code must handle than case but at least I would
> like to see a comment describing this shortcoming.

Thanks, I'll fix it. If a number of released pages is less than there
were allocated then the list entry shouldn't be deleted, but it's fields
should be updated.

>
>> @@ -361,11 +466,15 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>>   	unsigned long mask, offset, pfn, start = 0;
>>   	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>   	struct page *page = NULL;
>> +	struct timespec ts1, ts2;
>> +	s64 latency;
>>   	int ret;
>>
>>   	if (!cma || !cma->count)
>>   		return NULL;
>>
>> +	getnstimeofday(&ts1);
>> +
>
> If CMA_DEBUG is disabled, you waste time on measuring latency.  Either
> use #ifdef or IS_ENABLED, e.g.:
>
> 	if (IS_ENABLED(CMA_DEBUG))
> 		getnstimeofday(&ts1);

Obviously! :)

>
>> @@ -413,6 +522,19 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>>   		start = bitmap_no + mask + 1;
>>   	}
>>
>> +	getnstimeofday(&ts2);
>> +	latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
>> +
>> +	if (page) {
>
> 	if (IS_ENABLED(CMA_DEBUG) && page) {
> 		getnstimeofday(&ts2);
> 		latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
>
>> +		ret = cma_buffer_list_add(cma, pfn, count, latency);
>
> You could also change cma_buffer_list_add to take ts1 as an argument
> instead of latency and then latency calculating would be hidden inside
> of that function.  Initialising ts1 should still be guarded with
> IS_ENABLED of course.

	if (IS_ENABLED(CMA_DEBUG) && page) {
		getnstimeofday(&ts2);
		latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);

It seem to me this variant is better readable, thanks.

>
>> +		if (ret) {
>> +			pr_warn("%s(): cma_buffer_list_add() returned %d\n",
>> +				__func__, ret);
>> +			cma_release(cma, page, count);
>> +			page = NULL;
>
> Harsh, but ok, if you want.

Excuse me, maybe you could suggest how to make a nicer fallback?
Or sure OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

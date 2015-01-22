Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9F52D6B0073
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:36:01 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so2480511pab.4
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:36:01 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id xe5si12741963pab.185.2015.01.22.07.35.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 22 Jan 2015 07:36:00 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=windows-1252
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIL00B5X4UNPF60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jan 2015 15:39:59 +0000 (GMT)
Content-transfer-encoding: 8BIT
Message-id: <54C118D9.9040007@partner.samsung.com>
Date: Thu, 22 Jan 2015 18:35:53 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: Re: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com>
 <20141230043814.GB4588@js1304-P5Q-DELUXE>
In-reply-to: <20141230043814.GB4588@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

Hello Joonsoo,

On 30/12/14 07:38, Joonsoo Kim wrote:
> On Fri, Dec 26, 2014 at 05:39:03PM +0300, Stefan I. Strogin wrote:
>> /proc/cmainfo contains a list of currently allocated CMA buffers for every
>> CMA area when CONFIG_CMA_DEBUG is enabled.
> Hello,
>
> I think that providing these information looks useful, but, we need better
> implementation. As Laura said, it is better to use debugfs. And,
> instead of re-implementing the wheel, how about using tracepoint
> to print these information? See below comments.

Excuse me for a long delay. I've tried to give a detailed answer here:
https://lkml.org/lkml/2015/1/21/362
Do you mean by <<the re-implemented wheel>> seq_print_stack_trace()? If so
then it was thought to show an owner of each allocated buffer. I used a
similar way as in page_owner: saving stack_trace for each allocation. Do
you think we can use tracepoints instead?


>
>> Format is:
>>
>> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID>\
>> 		(<command name>), latency <allocation latency> us
>>  <stack backtrace when the buffer had been allocated>
>>
>> Signed-off-by: Stefan I. Strogin <s.strogin@partner.samsung.com>
>> ---
>>  mm/cma.c | 202 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 202 insertions(+)
>>
>> diff --git a/mm/cma.c b/mm/cma.c
>> index a85ae28..ffaea26 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -34,6 +34,10 @@
>>  #include <linux/cma.h>
>>  #include <linux/highmem.h>
>>  #include <linux/io.h>
>> +#include <linux/list.h>
>> +#include <linux/proc_fs.h>
>> +#include <linux/uaccess.h>
>> +#include <linux/time.h>
>>  
>>  struct cma {
>>  	unsigned long	base_pfn;
>> @@ -41,8 +45,25 @@ struct cma {
>>  	unsigned long	*bitmap;
>>  	unsigned int order_per_bit; /* Order of pages represented by one bit */
>>  	struct mutex	lock;
>> +#ifdef CONFIG_CMA_DEBUG
>> +	struct list_head buffers_list;
>> +	struct mutex	list_lock;
>> +#endif
>>  };
>>  
>> +#ifdef CONFIG_CMA_DEBUG
>> +struct cma_buffer {
>> +	unsigned long pfn;
>> +	unsigned long count;
>> +	pid_t pid;
>> +	char comm[TASK_COMM_LEN];
>> +	unsigned int latency;
>> +	unsigned long trace_entries[16];
>> +	unsigned int nr_entries;
>> +	struct list_head list;
>> +};
>> +#endif
>> +
>>  static struct cma cma_areas[MAX_CMA_AREAS];
>>  static unsigned cma_area_count;
>>  static DEFINE_MUTEX(cma_mutex);
>> @@ -132,6 +153,10 @@ static int __init cma_activate_area(struct cma *cma)
>>  	} while (--i);
>>  
>>  	mutex_init(&cma->lock);
>> +#ifdef CONFIG_CMA_DEBUG
>> +	INIT_LIST_HEAD(&cma->buffers_list);
>> +	mutex_init(&cma->list_lock);
>> +#endif
>>  	return 0;
>>  
>>  err:
>> @@ -347,6 +372,86 @@ err:
>>  	return ret;
>>  }
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
>> +
> Is there more elegant way to find buffer? This linear search overhead
> would change system behaviour if there are lots of buffers.
>
>> +	pr_err("%s(pfn %lu): couldn't find buffers list entry\n",
>> +	       __func__, pfn);
>> +
>> +out:
>> +	mutex_unlock(&cma->list_lock);
>> +}
>> +#else
>> +static int cma_buffer_list_add(struct cma *cma, unsigned long pfn,
>> +			       int count, s64 latency)
>> +{
>> +	return 0;
>> +}
>> +
>> +static void cma_buffer_list_del(struct cma *cma, unsigned long pfn)
>> +{
>> +}
>> +#endif /* CONFIG_CMA_DEBUG */
>> +
>>  /**
>>   * cma_alloc() - allocate pages from contiguous area
>>   * @cma:   Contiguous memory region for which the allocation is performed.
>> @@ -361,11 +466,15 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>>  	unsigned long mask, offset, pfn, start = 0;
>>  	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>  	struct page *page = NULL;
>> +	struct timespec ts1, ts2;
>> +	s64 latency;
>>  	int ret;
>>  
>>  	if (!cma || !cma->count)
>>  		return NULL;
>>  
>> +	getnstimeofday(&ts1);
>> +
>>  	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
>>  		 count, align);
>>  
>> @@ -413,6 +522,19 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>>  		start = bitmap_no + mask + 1;
>>  	}
>>  
>> +	getnstimeofday(&ts2);
>> +	latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
>> +
>> +	if (page) {
>> +		ret = cma_buffer_list_add(cma, pfn, count, latency);
>> +		if (ret) {
>> +			pr_warn("%s(): cma_buffer_list_add() returned %d\n",
>> +				__func__, ret);
>> +			cma_release(cma, page, count);
>> +			page = NULL;
>> +		}
> So, we would fail to allocate CMA memory if we can't allocate buffer
> for debugging. I don't think it makes sense. With tracepoint,
> we don't need to allocate buffer in runtime.
>
> Thanks.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

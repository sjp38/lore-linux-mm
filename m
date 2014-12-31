Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id CF67A6B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 20:14:46 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id fl12so4444288pdb.11
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 17:14:46 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id be3si38664941pdb.96.2014.12.30.17.14.43
        for <linux-mm@kvack.org>;
        Tue, 30 Dec 2014 17:14:45 -0800 (PST)
Message-ID: <54A34E01.2050405@lge.com>
Date: Wed, 31 Dec 2014 10:14:41 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com> <xa1tzjaaz9f9.fsf@mina86.com> <54A160B6.5030605@gmail.com>
In-Reply-To: <54A160B6.5030605@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <stefan.strogin@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>



2014-12-29 i??i?? 11:09i?? Stefan Strogin i?'(e??) i?' e,?:
> Thanks for review MichaA?,
>
> On 12/26/2014 07:02 PM, Michal Nazarewicz wrote:
>> On Fri, Dec 26 2014, "Stefan I. Strogin" <s.strogin@partner.samsung.com> wrote:
>>> /proc/cmainfo contains a list of currently allocated CMA buffers for every
>>> CMA area when CONFIG_CMA_DEBUG is enabled.
>>>
>>> Format is:
>>>
>>> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID>\
>>>         (<command name>), latency <allocation latency> us
>>>   <stack backtrace when the buffer had been allocated>
>>>
>>> Signed-off-by: Stefan I. Strogin <s.strogin@partner.samsung.com>
>>> ---
>>>   mm/cma.c | 202 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>>   1 file changed, 202 insertions(+)
>>>
>>> diff --git a/mm/cma.c b/mm/cma.c
>>> index a85ae28..ffaea26 100644
>>> --- a/mm/cma.c
>>> +++ b/mm/cma.c
>>> @@ -347,6 +372,86 @@ err:
>>>       return ret;
>>>   }
>>>
>>> +#ifdef CONFIG_CMA_DEBUG
>>> +/**
>>> + * cma_buffer_list_add() - add a new entry to a list of allocated buffers
>>> + * @cma:     Contiguous memory region for which the allocation is performed.
>>> + * @pfn:     Base PFN of the allocated buffer.
>>> + * @count:   Number of allocated pages.
>>> + * @latency: Nanoseconds spent to allocate the buffer.
>>> + *
>>> + * This function adds a new entry to the list of allocated contiguous memory
>>> + * buffers in a CMA area. It uses the CMA area specificated by the device
>>> + * if available or the default global one otherwise.
>>> + */
>>> +static int cma_buffer_list_add(struct cma *cma, unsigned long pfn,
>>> +                   int count, s64 latency)
>>> +{
>>> +    struct cma_buffer *cmabuf;
>>> +    struct stack_trace trace;
>>> +
>>> +    cmabuf = kmalloc(sizeof(struct cma_buffer), GFP_KERNEL);
>>
>>     cmabuf = kmalloc(sizeof *cmabuf, GFP_KERNEL);
>
>      cmabuf = kmalloc(sizeof(*cmabuf), GFP_KERNEL);
>
>>
>>> +    if (!cmabuf)
>>> +        return -ENOMEM;
>>> +
>>> +    trace.nr_entries = 0;
>>> +    trace.max_entries = ARRAY_SIZE(cmabuf->trace_entries);
>>> +    trace.entries = &cmabuf->trace_entries[0];
>>> +    trace.skip = 2;
>>> +    save_stack_trace(&trace);
>>> +
>>> +    cmabuf->pfn = pfn;
>>> +    cmabuf->count = count;
>>> +    cmabuf->pid = task_pid_nr(current);
>>> +    cmabuf->nr_entries = trace.nr_entries;
>>> +    get_task_comm(cmabuf->comm, current);
>>> +    cmabuf->latency = (unsigned int) div_s64(latency, NSEC_PER_USEC);
>>> +
>>> +    mutex_lock(&cma->list_lock);
>>> +    list_add_tail(&cmabuf->list, &cma->buffers_list);
>>> +    mutex_unlock(&cma->list_lock);
>>> +
>>> +    return 0;
>>> +}

Is it ok if the information is too big?
I'm not sure but I remember that seq_printf has 4K limitation.

So I made seq_operations with seq_list_start/next functions.

EX)

static void *debug_seq_start(struct seq_file *s, loff_t *pos)
{
A>>       mutex_lock(&debug_lock);
A>>       return seq_list_start(&debug_list, *pos);
}	

static void debug_seq_stop(struct seq_file *s, void *data)
{
A>>       struct debug_header *header = data;

A>>       if (header == NULL || &header->head_list == &debug_list) {
A>>       A>>       seq_printf(s, "end of info");
A>>       }

A>>       mutex_unlock(&debug_lock);
}

static void *debug_seq_next(struct seq_file *s, void *data, loff_t *pos)
{
A>>       return seq_list_next(data, &debug_list, pos);
}

static int debug_seq_show(struct seq_file *sfile, void *data)
{
A>>       struct debug_header *header;
A>>       char *p;

A>>       header= list_entry(data,
A>>       A>>       A>>          struct debug_header,	
A>>       A>>       A>>          head_list);

A>>       seq_printf(sfile, "print info");
A>>       return 0;
}
static const struct seq_operations debug_seq_ops = {
A>>       .start = debug_seq_start,	
A>>       .next = debug_seq_next,	
A>>       .stop = debug_seq_stop,	
A>>       .show = debug_seq_show,	
};

>> You do not have guarantee that CMA deallocations will match allocations
>> exactly.  User may allocate CMA region and then free it chunks.  I'm not
>> saying that the debug code must handle than case but at least I would
>> like to see a comment describing this shortcoming.
>
> Thanks, I'll fix it. If a number of released pages is less than there
> were allocated then the list entry shouldn't be deleted, but it's fields
> should be updated.
>
>>
>>> @@ -361,11 +466,15 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>>>       unsigned long mask, offset, pfn, start = 0;
>>>       unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>>       struct page *page = NULL;
>>> +    struct timespec ts1, ts2;
>>> +    s64 latency;
>>>       int ret;
>>>
>>>       if (!cma || !cma->count)
>>>           return NULL;
>>>
>>> +    getnstimeofday(&ts1);
>>> +
>>
>> If CMA_DEBUG is disabled, you waste time on measuring latency.  Either
>> use #ifdef or IS_ENABLED, e.g.:
>>
>>     if (IS_ENABLED(CMA_DEBUG))
>>         getnstimeofday(&ts1);
>
> Obviously! :)
>
>>
>>> @@ -413,6 +522,19 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>>>           start = bitmap_no + mask + 1;
>>>       }
>>>
>>> +    getnstimeofday(&ts2);
>>> +    latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
>>> +
>>> +    if (page) {
>>
>>     if (IS_ENABLED(CMA_DEBUG) && page) {
>>         getnstimeofday(&ts2);
>>         latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
>>
>>> +        ret = cma_buffer_list_add(cma, pfn, count, latency);
>>
>> You could also change cma_buffer_list_add to take ts1 as an argument
>> instead of latency and then latency calculating would be hidden inside
>> of that function.  Initialising ts1 should still be guarded with
>> IS_ENABLED of course.
>
>      if (IS_ENABLED(CMA_DEBUG) && page) {
>          getnstimeofday(&ts2);
>          latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
>
> It seem to me this variant is better readable, thanks.
>
>>
>>> +        if (ret) {
>>> +            pr_warn("%s(): cma_buffer_list_add() returned %d\n",
>>> +                __func__, ret);
>>> +            cma_release(cma, page, count);
>>> +            page = NULL;
>>
>> Harsh, but ok, if you want.
>
> Excuse me, maybe you could suggest how to make a nicer fallback?
> Or sure OK?
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

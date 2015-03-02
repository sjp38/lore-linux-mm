Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BCE316B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 10:44:40 -0500 (EST)
Received: by pabli10 with SMTP id li10so15138313pab.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 07:44:40 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id pk2si8174773pdb.214.2015.03.02.07.44.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 02 Mar 2015 07:44:39 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKL00773D95KO60@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 02 Mar 2015 15:48:41 +0000 (GMT)
Content-transfer-encoding: 8BIT
Message-id: <54F48560.1090800@partner.samsung.com>
Date: Mon, 02 Mar 2015 18:44:32 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: Re: [PATCH v3 3/4] mm: cma: add list of currently allocated CMA
 buffers to debugfs
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
 <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com>
 <xa1toaojov0x.fsf@mina86.com>
In-reply-to: <xa1toaojov0x.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hi MichaA?,

Thank you for the answer.

On 25/02/15 00:32, Michal Nazarewicz wrote:
> On Tue, Feb 24 2015, Stefan Strogin <s.strogin@partner.samsung.com> wrote:
>> --- a/mm/cma.h
>> +++ b/mm/cma.h
>> @@ -11,8 +13,32 @@ struct cma {
>>  	struct hlist_head mem_head;
>>  	spinlock_t mem_head_lock;
>>  #endif
>> +#ifdef CONFIG_CMA_BUFFER_LIST
>> +	struct list_head buffer_list;
>> +	struct mutex	list_lock;
>> +#endif
>>  };
>>  
>> +#ifdef CONFIG_CMA_BUFFER_LIST
>> +struct cma_buffer {
>> +	unsigned long pfn;
>> +	unsigned long count;
>> +	pid_t pid;
>> +	char comm[TASK_COMM_LEN];
>> +#ifdef CONFIG_CMA_ALLOC_STACKTRACE
>> +	unsigned long trace_entries[16];
>> +	unsigned int nr_entries;
>> +#endif
>> +	struct list_head list;
>> +};
> 
> This structure is only ever used in cma_debug.c so is there a reason
> to define it in the header file?
> 

No, there isn't. Thanks. I'll move it to cma_debug.c

>> +
>> +extern int cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count);
>> +extern void cma_buffer_list_del(struct cma *cma, unsigned long pfn, int count);
>> +#else
>> +#define cma_buffer_list_add(cma, pfn, count) { }
>> +#define cma_buffer_list_del(cma, pfn, count) { }
>> +#endif /* CONFIG_CMA_BUFFER_LIST */
>> +
>>  extern struct cma cma_areas[MAX_CMA_AREAS];
>>  extern unsigned cma_area_count;
> 
> 
>> +#ifdef CONFIG_CMA_BUFFER_LIST
>> +static ssize_t cma_buffer_list_read(struct file *file, char __user *userbuf,
>> +				    size_t count, loff_t *ppos)
>> +{
>> +	struct cma *cma = file->private_data;
>> +	struct cma_buffer *cmabuf;
>> +	char *buf;
>> +	int ret, n = 0;
>> +#ifdef CONFIG_CMA_ALLOC_STACKTRACE
>> +	struct stack_trace trace;
>> +#endif
>> +
>> +	if (*ppos < 0 || !count)
>> +		return -EINVAL;
>> +
>> +	buf = vmalloc(count);
>> +	if (!buf)
>> +		return -ENOMEM;
>> +
>> +	mutex_lock(&cma->list_lock);
>> +	list_for_each_entry(cmabuf, &cma->buffer_list, list) {
>> +		n += snprintf(buf + n, count - n,
>> +			      "0x%llx - 0x%llx (%lu kB), allocated by pid %u (%s)\n",
>> +			      (unsigned long long)PFN_PHYS(cmabuf->pfn),
>> +			      (unsigned long long)PFN_PHYS(cmabuf->pfn +
>> +				      cmabuf->count),
>> +			      (cmabuf->count * PAGE_SIZE) >> 10, cmabuf->pid,
>> +			      cmabuf->comm);
>> +
>> +#ifdef CONFIG_CMA_ALLOC_STACKTRACE
>> +		trace.nr_entries = cmabuf->nr_entries;
>> +		trace.entries = &cmabuf->trace_entries[0];
>> +		n += snprint_stack_trace(buf + n, count - n, &trace, 0);
>> +		n += snprintf(buf + n, count - n, "\n");
>> +#endif
>> +	}
>> +	mutex_unlock(&cma->list_lock);
>> +
>> +	ret = simple_read_from_buffer(userbuf, count, ppos, buf, n);
>> +	vfree(buf);
>> +
>> +	return ret;
>> +}
> 
> So in practice user space must allocate buffer big enough to read the
> whole file into memory.  Calling read(2) with some count will never read
> anything past the first count bytes of the file.
> 

My fault. You are right.
I'm not sure how to do the output nice... I could use *ppos to point the
number of next list entry to read (like that is used in
read_page_owner()). But in this case the list could be changed before we
finish reading, it's bad.
Or we could use seq_files like in v1, iterating over buffer_list
entries. But seq_print_stack_trace() has to be added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

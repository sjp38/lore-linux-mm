Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3CE6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 17:13:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s7-v6so435596pfm.4
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 14:13:28 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id f59-v6si580299plf.500.2018.06.19.14.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 14:13:27 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180619100218.GN2458@hirez.programming.kicks-ass.net>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <f78924fc-ea81-9ddd-ebb2-28241d5721c8@linux.alibaba.com>
Date: Tue, 19 Jun 2018 14:13:05 -0700
MIME-Version: 1.0
In-Reply-To: <20180619100218.GN2458@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 6/19/18 3:02 AM, Peter Zijlstra wrote:
> On Tue, Jun 19, 2018 at 07:34:16AM +0800, Yang Shi wrote:
>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index fc41c05..e84f80c 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2686,6 +2686,141 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>>   	return __split_vma(mm, vma, addr, new_below);
>>   }
>>   
>> +/* Consider PUD size or 1GB mapping as large mapping */
>> +#ifdef HPAGE_PUD_SIZE
>> +#define LARGE_MAP_THRESH	HPAGE_PUD_SIZE
>> +#else
>> +#define LARGE_MAP_THRESH	(1 * 1024 * 1024 * 1024)
>> +#endif
>> +
>> +/* Unmap large mapping early with acquiring read mmap_sem */
>> +static int do_munmap_zap_early(struct mm_struct *mm, unsigned long start,
>> +			       size_t len, struct list_head *uf)
>> +{
>> +	unsigned long end = 0;
>> +	struct vm_area_struct *vma = NULL, *prev, *last, *tmp;
>> +	bool success = false;
>> +	int ret = 0;
>> +
>> +	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE - start)
>> +		return -EINVAL;
>> +
>> +	len = (PAGE_ALIGN(len));
>> +	if (len == 0)
>> +		return -EINVAL;
>> +
>> +	/* Just deal with uf in regular path */
>> +	if (unlikely(uf))
>> +		goto regular_path;
>> +
>> +	if (len >= LARGE_MAP_THRESH) {
>> +		down_read(&mm->mmap_sem);
>> +		vma = find_vma(mm, start);
>> +		if (!vma) {
>> +			up_read(&mm->mmap_sem);
>> +			return 0;
>> +		}
>> +
>> +		prev = vma->vm_prev;
>> +
>> +		end = start + len;
>> +		if (vma->vm_start > end) {
>> +			up_read(&mm->mmap_sem);
>> +			return 0;
>> +		}
>> +
>> +		if (start > vma->vm_start) {
>> +			int error;
>> +
>> +			if (end < vma->vm_end &&
>> +			    mm->map_count > sysctl_max_map_count) {
>> +				up_read(&mm->mmap_sem);
>> +				return -ENOMEM;
>> +			}
>> +
>> +			error = __split_vma(mm, vma, start, 0);
>> +			if (error) {
>> +				up_read(&mm->mmap_sem);
>> +				return error;
>> +			}
>> +			prev = vma;
>> +		}
>> +
>> +		last = find_vma(mm, end);
>> +		if (last && end > last->vm_start) {
>> +			int error = __split_vma(mm, last, end, 1);
>> +
>> +			if (error) {
>> +				up_read(&mm->mmap_sem);
>> +				return error;
>> +			}
>> +		}
>> +		vma = prev ? prev->vm_next : mm->mmap;
> Hold up, two things: you having to copy most of do_munmap() didn't seem
> to suggest a helper function? And second, since when are we allowed to

Yes, they will be extracted into a helper function in the next version.

May bad, I don't think it is allowed. We could reform this to:

acquire write mmap_sem
vma lookup (split vmas)
release write mmap_sem

acquire read mmap_sem
zap pages
release read mmap_sem

I'm supposed this is safe as what Michal said before.

Thanks,
Yang

> split VMAs under a read lock?

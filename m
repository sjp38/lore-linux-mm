Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E78086B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 02:11:59 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 2-v6so2118334plc.11
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 23:11:59 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id v23-v6si9452246plo.19.2018.08.15.23.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 23:11:58 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
 <20180815191606.GA4201@bombadil.infradead.org>
 <20180815210946.GA28919@bombadil.infradead.org>
 <78e658dd-bdb0-09ca-9af5-b523c7ff529f@linux.alibaba.com>
 <20180816024652.GA11808@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b286c2f8-d3a5-89f8-954b-608a26c28a22@linux.alibaba.com>
Date: Wed, 15 Aug 2018 23:11:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180816024652.GA11808@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/15/18 7:46 PM, Matthew Wilcox wrote:
> On Wed, Aug 15, 2018 at 02:54:13PM -0700, Yang Shi wrote:
>>
>> On 8/15/18 2:09 PM, Matthew Wilcox wrote:
>>> On Wed, Aug 15, 2018 at 12:16:06PM -0700, Matthew Wilcox wrote:
>>>> (not even compiled, and I can see a good opportunity for combining the
>>>> VM_LOCKED loop with the has_uprobes loop)
>>> I was rushing to get that sent earlier.  Here it is tidied up to
>>> actually compile.
>> Thanks for the example. Yes, I believe the code still can be compacted to
>> save some lines. However, the cover letter and the commit log of this patch
>> has elaborated the discussion in the earlier reviews about why we do it in
>> this way.
> You mean the other callers which need to hold mmap_sem write-locked for
> longer?  I hadn't really considered those; how about this?

Thanks. Yes, this is the other potential implementation. My rationale 
about a separate function for the optimized path is I would prefer 
optimize this step by step by starting with some relatively simple way, 
then add enhancement on top of it.

And, I would prefer keep the current implementation of do_munmap since 
it is called somewhere else and it might be called by the optimized path 
for some reason until we are confident enough that the optimization 
doesn't have regression.

This sounds like separate function vs an extra parameter. We do save 
some lines with extra parameter instead of a separate function.

Thanks,
Yang

>
>   mmap.c |   47 +++++++++++++++++++++++++++++------------------
>   1 file changed, 29 insertions(+), 18 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index de699523c0b7..06dc31d1da8c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2798,11 +2798,11 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>    * work.  This now handles partial unmappings.
>    * Jeremy Fitzhardinge <jeremy@goop.org>
>    */
> -int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
> -	      struct list_head *uf)
> +static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
> +	      struct list_head *uf, bool downgrade)
>   {
>   	unsigned long end;
> -	struct vm_area_struct *vma, *prev, *last;
> +	struct vm_area_struct *vma, *prev, *last, *tmp;
>   
>   	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
>   		return -EINVAL;
> @@ -2816,7 +2816,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>   	if (!vma)
>   		return 0;
>   	prev = vma->vm_prev;
> -	/* we have  start < vma->vm_end  */
> +	/* we have start < vma->vm_end  */
>   
>   	/* if it doesn't overlap, we have nothing.. */
>   	end = start + len;
> @@ -2873,18 +2873,22 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>   
>   	/*
>   	 * unlock any mlock()ed ranges before detaching vmas
> +	 * and check to see if there's any reason we might have to hold
> +	 * the mmap_sem write-locked while unmapping regions.
>   	 */
> -	if (mm->locked_vm) {
> -		struct vm_area_struct *tmp = vma;
> -		while (tmp && tmp->vm_start < end) {
> -			if (tmp->vm_flags & VM_LOCKED) {
> -				mm->locked_vm -= vma_pages(tmp);
> -				munlock_vma_pages_all(tmp);
> -			}
> -			tmp = tmp->vm_next;
> +	for (tmp = vma; tmp && tmp->vm_start < end; tmp = tmp->vm_next) {
> +		if (tmp->vm_flags & VM_LOCKED) {
> +			mm->locked_vm -= vma_pages(tmp);
> +			munlock_vma_pages_all(tmp);
>   		}
> +		if (tmp->vm_file &&
> +				has_uprobes(tmp, tmp->vm_start, tmp->vm_end))
> +			downgrade = false;
>   	}
>   
> +	if (downgrade)
> +		downgrade_write(&mm->mmap_sem);
> +
>   	/*
>   	 * Remove the vma's, and unmap the actual pages
>   	 */
> @@ -2896,7 +2900,13 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>   	/* Fix up all other VM information */
>   	remove_vma_list(mm, vma);
>   
> -	return 0;
> +	return downgrade ? 1 : 0;
> +}
> +
> +int do_unmap(struct mm_struct *mm, unsigned long start, size_t len,
> +		struct list_head *uf)
> +{
> +	return __do_munmap(mm, start, len, uf, false);
>   }
>   
>   int vm_munmap(unsigned long start, size_t len)
> @@ -2905,11 +2915,12 @@ int vm_munmap(unsigned long start, size_t len)
>   	struct mm_struct *mm = current->mm;
>   	LIST_HEAD(uf);
>   
> -	if (down_write_killable(&mm->mmap_sem))
> -		return -EINTR;
> -
> -	ret = do_munmap(mm, start, len, &uf);
> -	up_write(&mm->mmap_sem);
> +	down_write(&mm->mmap_sem);
> +	ret = __do_munmap(mm, start, len, &uf, true);
> +	if (ret == 1)
> +		up_read(&mm->mmap_sem);
> +	else
> +		up_write(&mm->mmap_sem);
>   	userfaultfd_unmap_complete(mm, &uf);
>   	return ret;
>   }

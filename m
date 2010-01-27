Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B28506B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:58:01 -0500 (EST)
Message-ID: <4B60A8AC.40708@redhat.com>
Date: Wed, 27 Jan 2010 15:57:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC -v2 PATCH -mm] change anon_vma linking to fix multi-process
 server scalability issue
References: <20100121133448.73BD.A69D9226@jp.fujitsu.com> <4B57E442.5060700@redhat.com> <20100122135809.6C11.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100122135809.6C11.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, minchan.kim@gmail.com, lwoodman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 01/22/2010 01:57 AM, KOSAKI Motohiro wrote:

>> @@ -240,6 +339,14 @@ vma_address(struct page *page, struct vm_area_struct *vma)
>>   		/* page should be within @vma mapping range */
>>   		return -EFAULT;
>>   	}
>> +	if (unlikely(vma->vm_flags&  VM_LOCK_RMAP))
>> +		/*
>> +		 * This VMA is being unlinked or not yet linked into the
>> +		 * VMA tree.  Do not try to follow this rmap.  This race
>> +		 * condition can result in page_referenced ignoring a
>> +		 * reference or try_to_unmap failing to unmap a page.
>> +		 */
>> +		return -EFAULT;
>>   	return address;
>>   }
>
> In this place, the task have anon_vma->lock, but don't have mmap_sem.
> But, VM_LOCK_RMAP changing point (i.e. vma_adjust()) is protected by mmap_sem.
>
> IOW, "if (vma->vm_flags&  VM_LOCK_RMAP)" return unstable value. Why can we use
> unstable value as "lock"?

I know the answer to this one. The VMA cannot be freed until the
anon_vmas have been unlinked.

That is serialized on the anon_vma->lock.  Either the pageout
code has that lock, or the VMA teardown code in mmap.c has it.

Either way they're protected from each other.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

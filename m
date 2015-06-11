Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 18F046B0038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 19:10:41 -0400 (EDT)
Received: by obbgp2 with SMTP id gp2so12507783obb.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 16:10:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h5si1361224oer.59.2015.06.11.16.10.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 16:10:39 -0700 (PDT)
Message-ID: <557A1546.3090300@oracle.com>
Date: Thu, 11 Jun 2015 16:09:58 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v4 PATCH 2/9] mm/hugetlb: expose hugetlb fault mutex for
 use by fallocate
References: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>	 <1434056500-2434-3-git-send-email-mike.kravetz@oracle.com> <1434062766.3165.103.camel@stgolabs.net>
In-Reply-To: <1434062766.3165.103.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On 06/11/2015 03:46 PM, Davidlohr Bueso wrote:
> On Thu, 2015-06-11 at 14:01 -0700, Mike Kravetz wrote:
>>   /* Forward declaration */
>>   static int hugetlb_acct_memory(struct hstate *h, long delta);
>> @@ -3324,7 +3324,8 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
>>   	unsigned long key[2];
>>   	u32 hash;
>>
>> -	if (vma->vm_flags & VM_SHARED) {
>> +	/* !vma implies this was called from hugetlbfs fallocate code */
>> +	if (!vma || vma->vm_flags & VM_SHARED) {
>
> That !vma is icky, and really no need for it: hugetlbfs_fallocate(), for
> example, already passes [pseudo]vma->vm_flags with VM_SHARED, and you
> say it yourself in the comment. Do you see any reason why we cannot just
> keep the vma->vm_flags & VM_SHARED check?
>
>> +/*
>> + * Interface for use by hugetlbfs fallocate code.  Faults must be
>> + * synchronized with page adds or deletes by fallocate.  fallocate
>> + * only deals with shared mappings.  See also hugetlb_fault_mutex_lock
>> + * and hugetlb_fault_mutex_unlock.
>> + */
>> +u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx)
>> +{
>> +	return fault_mutex_hash(NULL, NULL, NULL, mapping, idx, 0);
>> +}
>
> It strikes me that this too should be static inlined. But I really
> dislike the nil params thing, which should be addressed by my comment
> above.

In the previous RFC, I was trying not to make all the fault mutex data
global (so it could be accessed outside hugetlb.c).  That was the
original reason for the wrapper interfaces.  That may just be too ugly,
and does not buy us much.

Now that the mutex table is global for inlining, I might as well make
fault_mutex_hash() global.  I can then get rid of the wrappers.  However,
I'm guessing it would be a good idea to change the name(s) to something
hugetlb specific since they will be global.

-- 
Mike Kravetz

>
> Thanks,
> Davidlohr
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

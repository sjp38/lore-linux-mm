Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9E66B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:06:03 -0400 (EDT)
Received: by pacgb13 with SMTP id gb13so45719424pac.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 15:06:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z7si8251266pdm.46.2015.06.17.15.06.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 15:06:02 -0700 (PDT)
Message-ID: <5581EF1F.9000907@oracle.com>
Date: Wed, 17 Jun 2015 15:05:19 -0700
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

Ah, I did not recall all the users of this code until I went to change
it. The other user is truncate_hugapages() which will now be used for
fallocate hole punch.  Truncate like fallocate is an inode operation
and there is no specific vma.  I can create a pseudo-vma here as well
just to pass the flag.  I guess that would at least be consistent with
the other user.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

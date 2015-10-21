Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFFF6B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 21:02:48 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so27459684igb.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 18:02:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 190si2577281ioe.85.2015.10.20.18.02.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 18:02:47 -0700 (PDT)
Subject: Re: [PATCH v2 2/4] mm/hugetlb: Setup hugetlb_falloc during fallocate
 hole punch
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
 <1445385142-29936-3-git-send-email-mike.kravetz@oracle.com>
 <5626D84C.6060204@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5626E42E.7000402@oracle.com>
Date: Tue, 20 Oct 2015 18:02:38 -0700
MIME-Version: 1.0
In-Reply-To: <5626D84C.6060204@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>

On 10/20/2015 05:11 PM, Dave Hansen wrote:
> On 10/20/2015 04:52 PM, Mike Kravetz wrote:
>>  	if (hole_end > hole_start) {
>>  		struct address_space *mapping = inode->i_mapping;
>> +		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(hugetlb_falloc_waitq);
>> +		/*
>> +		 * Page faults on the area to be hole punched must be stopped
>> +		 * during the operation.  Initialize struct and have
>> +		 * inode->i_private point to it.
>> +		 */
>> +		struct hugetlb_falloc hugetlb_falloc = {
>> +			.waitq = &hugetlb_falloc_waitq,
>> +			.start = hole_start >> hpage_shift,
>> +			.end = hole_end >> hpage_shift
>> +		};
> ...
>> @@ -527,6 +550,12 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
>>  						hole_end  >> PAGE_SHIFT);
>>  		i_mmap_unlock_write(mapping);
>>  		remove_inode_hugepages(inode, hole_start, hole_end);
>> +
>> +		spin_lock(&inode->i_lock);
>> +		inode->i_private = NULL;
>> +		wake_up_all(&hugetlb_falloc_waitq);
>> +		spin_unlock(&inode->i_lock);
> 
> I see the shmem code doing something similar.  But, in the end, we're
> passing the stack-allocated 'hugetlb_falloc_waitq' over to the page
> faulting thread.  Is there something subtle that keeps
> 'hugetlb_falloc_waitq' from becoming invalid while the other task is
> sleeping?
> 
> That wake_up_all() obviously can't sleep, but it seems like the faulting
> thread's finish_wait() *HAS* to run before wake_up_all() can return.
> 

The 'trick' is noted in the comment in the shmem_fault code:

                        /*
                         * shmem_falloc_waitq points into the
shmem_fallocate()
                         * stack of the hole-punching task:
shmem_falloc_waitq
                         * is usually invalid by the time we reach here, but
                         * finish_wait() does not dereference it in that
case;
                         * though i_lock needed lest racing with
wake_up_all().
                         */

The faulting thread is removed from the waitq when awakened with
wake_up_all().  See the DEFINE_WAIT() and supporting code in the
faulting thread.  Because of this, when the faulting thread calls
finish_wait() it does not access the waitq that was/is on the stack.

At least I've convinced myself it works this way. :)

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
